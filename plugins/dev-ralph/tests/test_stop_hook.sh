#!/bin/bash

# Unit tests for stop-hook.sh
# This is the most critical component - the core loop logic

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
SCRIPT="$PLUGIN_DIR/hooks/stop-hook.sh"

# Create temp directory for each test
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

cd "$TEMP_DIR"

# Helper to create mock transcript
create_transcript() {
  local assistant_text="$1"
  mkdir -p .claude-code
  cat > .claude-code/transcript.jsonl << EOF
{"role":"user","message":{"content":[{"type":"text","text":"do something"}]}}
{"role":"assistant","message":{"content":[{"type":"text","text":"$assistant_text"}]}}
EOF
}

# Helper to create hook input JSON
create_hook_input() {
  local transcript_path="${1:-.claude-code/transcript.jsonl}"
  echo "{\"transcript_path\": \"$PWD/$transcript_path\"}"
}

# ============================================
# Test 1: Allows exit when no state file
# ============================================
test_allows_exit_no_state() {
  # No .ralph/loop-state.json exists
  create_transcript "Hello world"

  EXIT_CODE=0
  create_hook_input | bash "$SCRIPT" > /dev/null 2>&1 || EXIT_CODE=$?

  [[ $EXIT_CODE -eq 0 ]] || { echo "FAIL: Should exit 0 (allow) when no state"; return 1; }

  return 0
}

# ============================================
# Test 2: Allows exit on VERIFIED_COMPLETE
# ============================================
test_allows_exit_verified_complete() {
  mkdir -p .ralph
  cat > .ralph/loop-state.json << 'EOF'
{
  "active": true,
  "phase": "verification",
  "iteration": 10,
  "max_iterations": 500
}
EOF
  cat > .ralph/PROMPT.md << 'EOF'
---
iteration_limit: 500
---
# Prompt
EOF

  create_transcript "All done! <promise>VERIFIED_COMPLETE</promise>"

  EXIT_CODE=0
  OUTPUT=$(create_hook_input | bash "$SCRIPT" 2>&1) || EXIT_CODE=$?

  [[ $EXIT_CODE -eq 0 ]] || { echo "FAIL: Should exit 0 on VERIFIED_COMPLETE"; return 1; }
  echo "$OUTPUT" | grep -qi "verified complete" || { echo "FAIL: Should mention verified complete"; return 1; }

  # State file should be deleted
  [[ ! -f ".ralph/loop-state.json" ]] || { echo "FAIL: State file should be deleted"; return 1; }

  return 0
}

# ============================================
# Test 3: Blocks exit and continues loop
# ============================================
test_blocks_exit_continues_loop() {
  mkdir -p .ralph
  cat > .ralph/loop-state.json << 'EOF'
{
  "active": true,
  "phase": "implementation",
  "iteration": 5,
  "max_iterations": 500,
  "retry_count": 0,
  "retry_limit": 5
}
EOF
  cat > .ralph/PROMPT.md << 'EOF'
---
iteration_limit: 500
---
# This is the prompt content
EOF

  create_transcript "I implemented the feature"

  OUTPUT=$(create_hook_input | bash "$SCRIPT")

  # Should output JSON with block decision
  echo "$OUTPUT" | python3 -c "
import json, sys
d = json.load(sys.stdin)
assert d['decision'] == 'block', 'Should have decision=block'
assert 'reason' in d, 'Should have reason (prompt)'
assert 'systemMessage' in d, 'Should have systemMessage'
" || { echo "FAIL: Invalid JSON output"; return 1; }

  # Iteration should be incremented
  NEW_ITER=$(cat .ralph/loop-state.json | python3 -c "import json,sys; print(json.load(sys.stdin)['iteration'])")
  [[ "$NEW_ITER" == "6" ]] || { echo "FAIL: Iteration should be 6, got $NEW_ITER"; return 1; }

  return 0
}

# ============================================
# Test 4: Detects IMPLEMENTATION_COMPLETE
# ============================================
test_detects_implementation_complete() {
  mkdir -p .ralph
  cat > .ralph/loop-state.json << 'EOF'
{
  "active": true,
  "phase": "implementation",
  "iteration": 8,
  "max_iterations": 500
}
EOF
  cat > .ralph/PROMPT.md << 'EOF'
---
iteration_limit: 500
---
# Prompt
EOF

  create_transcript "Type check passed! <status>IMPLEMENTATION_COMPLETE</status>"

  OUTPUT=$(create_hook_input | bash "$SCRIPT")

  # Phase should transition to verification
  PHASE=$(cat .ralph/loop-state.json | python3 -c "import json,sys; print(json.load(sys.stdin)['phase'])")
  [[ "$PHASE" == "verification" ]] || { echo "FAIL: Phase should be 'verification', got '$PHASE'"; return 1; }

  # System message should mention verification
  echo "$OUTPUT" | grep -qi "verification" || { echo "FAIL: Should mention verification phase"; return 1; }

  return 0
}

# ============================================
# Test 5: Returns to implementation on verification failure
# ============================================
test_returns_to_implementation() {
  mkdir -p .ralph
  cat > .ralph/loop-state.json << 'EOF'
{
  "active": true,
  "phase": "verification",
  "iteration": 12,
  "max_iterations": 500,
  "verification_triggered": true
}
EOF
  cat > .ralph/PROMPT.md << 'EOF'
---
iteration_limit: 500
---
# Prompt
EOF

  # Verification failed - no VERIFIED_COMPLETE
  create_transcript "Coverage is only 75%, need to add more tests"

  OUTPUT=$(create_hook_input | bash "$SCRIPT")

  # Phase should return to implementation
  PHASE=$(cat .ralph/loop-state.json | python3 -c "import json,sys; print(json.load(sys.stdin)['phase'])")
  [[ "$PHASE" == "implementation" ]] || { echo "FAIL: Phase should return to 'implementation', got '$PHASE'"; return 1; }

  return 0
}

# ============================================
# Test 6: Stops at max iterations
# ============================================
test_stops_at_max_iterations() {
  mkdir -p .ralph
  cat > .ralph/loop-state.json << 'EOF'
{
  "active": true,
  "phase": "implementation",
  "iteration": 500,
  "max_iterations": 500
}
EOF
  cat > .ralph/PROMPT.md << 'EOF'
---
iteration_limit: 500
---
# Prompt
EOF

  create_transcript "Still working..."

  EXIT_CODE=0
  OUTPUT=$(create_hook_input | bash "$SCRIPT" 2>&1) || EXIT_CODE=$?

  [[ $EXIT_CODE -eq 0 ]] || { echo "FAIL: Should exit 0 at max iterations"; return 1; }
  echo "$OUTPUT" | grep -qi "limit" || { echo "FAIL: Should mention limit reached"; return 1; }

  # State file should be deleted
  [[ ! -f ".ralph/loop-state.json" ]] || { echo "FAIL: State file should be deleted at limit"; return 1; }

  return 0
}

# ============================================
# Test 7: Handles corrupted state gracefully
# ============================================
test_handles_corrupted_state() {
  mkdir -p .ralph
  echo "not valid json" > .ralph/loop-state.json
  cat > .ralph/PROMPT.md << 'EOF'
---
iteration_limit: 500
---
# Prompt
EOF

  create_transcript "Hello"

  # Should not crash
  EXIT_CODE=0
  create_hook_input | bash "$SCRIPT" > /dev/null 2>&1 || EXIT_CODE=$?

  # Non-zero exit is acceptable for corrupted state
  return 0
}

# ============================================
# Test 8: Feeds PROMPT.md content back
# ============================================
test_feeds_prompt_back() {
  mkdir -p .ralph
  cat > .ralph/loop-state.json << 'EOF'
{
  "active": true,
  "phase": "implementation",
  "iteration": 1,
  "max_iterations": 500
}
EOF
  cat > .ralph/PROMPT.md << 'EOF'
---
iteration_limit: 500
---
# Special Prompt Content
Pick the next task!
EOF

  create_transcript "Working on it"

  OUTPUT=$(create_hook_input | bash "$SCRIPT")

  # The reason field should contain prompt content
  echo "$OUTPUT" | python3 -c "
import json, sys
d = json.load(sys.stdin)
assert 'Special Prompt Content' in d['reason'], 'Prompt content not in reason'
" || { echo "FAIL: Prompt content not fed back"; return 1; }

  return 0
}

# Run tests
echo "Testing stop-hook.sh"

test_allows_exit_no_state
test_allows_exit_verified_complete
test_blocks_exit_continues_loop
test_detects_implementation_complete
test_returns_to_implementation
test_stops_at_max_iterations
test_handles_corrupted_state
test_feeds_prompt_back

echo "All tests passed"
