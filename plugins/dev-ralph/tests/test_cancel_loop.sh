#!/bin/bash

# Unit tests for cancel-loop.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
SCRIPT="$PLUGIN_DIR/scripts/cancel-loop.sh"

# Create temp directory for each test
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

cd "$TEMP_DIR"

# ============================================
# Test 1: Reports no active loop when none exists
# ============================================
test_no_active_loop() {
  OUTPUT=$(bash "$SCRIPT")

  echo "$OUTPUT" | grep -qi "no active" || { echo "FAIL: Should report 'no active loop'"; return 1; }

  return 0
}

# ============================================
# Test 2: Deletes state file when canceling
# ============================================
test_deletes_state_file() {
  mkdir -p .ralph
  cat > .ralph/loop-state.json << 'EOF'
{
  "active": true,
  "phase": "implementation",
  "iteration": 5,
  "max_iterations": 500
}
EOF

  bash "$SCRIPT" > /dev/null

  [[ ! -f ".ralph/loop-state.json" ]] || { echo "FAIL: State file should be deleted"; return 1; }

  return 0
}

# ============================================
# Test 3: Preserves .ralph directory
# ============================================
test_preserves_ralph_directory() {
  mkdir -p .ralph/specs
  echo "# Spec" > .ralph/specs/feature.md
  echo "# Plan" > .ralph/IMPLEMENTATION_PLAN.md
  cat > .ralph/loop-state.json << 'EOF'
{
  "active": true,
  "phase": "implementation",
  "iteration": 3
}
EOF

  bash "$SCRIPT" > /dev/null

  # Directory and files should still exist
  [[ -d ".ralph" ]] || { echo "FAIL: .ralph directory should be preserved"; return 1; }
  [[ -f ".ralph/specs/feature.md" ]] || { echo "FAIL: Spec file should be preserved"; return 1; }
  [[ -f ".ralph/IMPLEMENTATION_PLAN.md" ]] || { echo "FAIL: Plan should be preserved"; return 1; }

  return 0
}

# ============================================
# Test 4: Reports iteration count
# ============================================
test_reports_iteration() {
  mkdir -p .ralph
  cat > .ralph/loop-state.json << 'EOF'
{
  "active": true,
  "phase": "verification",
  "iteration": 42,
  "max_iterations": 500
}
EOF

  OUTPUT=$(bash "$SCRIPT")

  echo "$OUTPUT" | grep -q "42" || { echo "FAIL: Should report iteration 42"; return 1; }
  echo "$OUTPUT" | grep -qi "verification" || { echo "FAIL: Should report phase"; return 1; }

  return 0
}

# ============================================
# Test 5: Checkpoint option (without git repo)
# ============================================
test_checkpoint_without_git() {
  mkdir -p .ralph
  cat > .ralph/loop-state.json << 'EOF'
{
  "active": true,
  "iteration": 10
}
EOF

  # Should handle no git repo gracefully
  OUTPUT=$(bash "$SCRIPT" --checkpoint 2>&1)

  # Should still cancel
  [[ ! -f ".ralph/loop-state.json" ]] || { echo "FAIL: State file should be deleted"; return 1; }

  return 0
}

# ============================================
# Test 6: Shows resume instructions
# ============================================
test_shows_resume_instructions() {
  mkdir -p .ralph
  cat > .ralph/loop-state.json << 'EOF'
{
  "active": true,
  "iteration": 5
}
EOF

  OUTPUT=$(bash "$SCRIPT")

  echo "$OUTPUT" | grep -q "ralph-build" || { echo "FAIL: Should mention /ralph-build to resume"; return 1; }

  return 0
}

# Run tests
echo "Testing cancel-loop.sh"

test_no_active_loop
test_deletes_state_file
test_preserves_ralph_directory
test_reports_iteration
test_checkpoint_without_git
test_shows_resume_instructions

echo "All tests passed"
