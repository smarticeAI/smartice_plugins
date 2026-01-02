#!/bin/bash

# Integration tests for the hook flow
# Tests the complete lifecycle of the Stop hook across multiple invocations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
STOP_HOOK="$PLUGIN_DIR/hooks/stop-hook.sh"
SETUP_BUILD="$PLUGIN_DIR/scripts/setup-ralph-build.sh"
SETUP_PLAN="$PLUGIN_DIR/scripts/setup-ralph-plan.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Test tracking
PASSED=0
FAILED=0

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

log_pass() {
  echo -e "  ${GREEN}✓${NC} $1"
  ((PASSED++)) || true
}

log_fail() {
  echo -e "  ${RED}✗${NC} $1: $2"
  ((FAILED++)) || true
}

# Helper: Create mock transcript
create_transcript() {
  mkdir -p "$TEMP_DIR/.claude-code"
  cat > "$TEMP_DIR/.claude-code/transcript.jsonl" << EOF
{"role":"user","message":{"content":[{"type":"text","text":"continue"}]}}
{"role":"assistant","message":{"content":[{"type":"text","text":"$1"}]}}
EOF
}

# Helper: Invoke hook and get decision
invoke_and_get_decision() {
  local result
  result=$(echo "{\"transcript_path\": \"$TEMP_DIR/.claude-code/transcript.jsonl\"}" | bash "$STOP_HOOK" 2>/dev/null) || true
  if [[ -n "$result" ]]; then
    echo "$result" | jq -r '.decision // "allow"' 2>/dev/null || echo "allow"
  else
    echo "allow"
  fi
}

# Helper: Get state field
get_state() {
  local field="$1"
  jq -r ".$field" "$TEMP_DIR/.ralph/loop-state.json" 2>/dev/null || echo ""
}

# Helper: Setup .ralph directory
setup_ralph() {
  rm -rf "$TEMP_DIR/.ralph" "$TEMP_DIR/.claude-code"
  mkdir -p "$TEMP_DIR/.ralph/specs" "$TEMP_DIR/.ralph/stdlib"
  echo "# Feature" > "$TEMP_DIR/.ralph/specs/feature.md"
  echo "- Task 1" > "$TEMP_DIR/.ralph/IMPLEMENTATION_PLAN.md"
  cat > "$TEMP_DIR/.ralph/PROMPT.md" << 'EOF'
---
iteration_limit: 10
retry_limit: 3
---
# Test Prompt
EOF
  (cd "$TEMP_DIR" && bash "$SETUP_BUILD" > /dev/null 2>&1)
}

# ============================================================
echo "========================================"
echo "  dev-ralph Integration Tests"
echo "========================================"

# ============================================================
# Test 1: Full Loop Lifecycle
# ============================================================
echo ""
echo "Test 1: Full Loop Lifecycle"

setup_ralph
cd "$TEMP_DIR"

# Iteration 1: Working
create_transcript "Working on Task 1..."
DECISION=$(invoke_and_get_decision)
[[ "$DECISION" == "block" ]] && log_pass "Iter 1: blocked" || log_fail "Iter 1" "expected block, got $DECISION"

# Check iteration
ITER=$(get_state "iteration")
[[ "$ITER" == "2" ]] && log_pass "Iter incremented to 2" || log_fail "Iter count" "expected 2, got $ITER"

# Iteration 2: IMPLEMENTATION_COMPLETE
create_transcript "Done! <status>IMPLEMENTATION_COMPLETE</status>"
DECISION=$(invoke_and_get_decision)
PHASE=$(get_state "phase")
[[ "$PHASE" == "verification" ]] && log_pass "Phase -> verification" || log_fail "Phase" "expected verification, got $PHASE"

# Iteration 3: VERIFIED_COMPLETE
create_transcript "All checks pass! <promise>VERIFIED_COMPLETE</promise>"
DECISION=$(invoke_and_get_decision)
[[ ! -f "$TEMP_DIR/.ralph/loop-state.json" ]] && log_pass "Loop completed" || log_fail "Completion" "state file should be deleted"

# ============================================================
# Test 2: Verification Failure
# ============================================================
echo ""
echo "Test 2: Verification Failure Recovery"

setup_ralph
cd "$TEMP_DIR"

# IMPLEMENTATION_COMPLETE
create_transcript "<status>IMPLEMENTATION_COMPLETE</status>"
invoke_and_get_decision > /dev/null
PHASE=$(get_state "phase")
[[ "$PHASE" == "verification" ]] && log_pass "Entered verification" || log_fail "Enter verify" "got $PHASE"

# Verification fails
create_transcript "Coverage too low, only 60%"
invoke_and_get_decision > /dev/null
PHASE=$(get_state "phase")
[[ "$PHASE" == "implementation" ]] && log_pass "Returned to impl" || log_fail "Return impl" "got $PHASE"

# ============================================================
# Test 3: Iteration Limit
# ============================================================
echo ""
echo "Test 3: Iteration Limit"

rm -rf "$TEMP_DIR/.ralph" "$TEMP_DIR/.claude-code"
mkdir -p "$TEMP_DIR/.ralph/specs"
echo "# Feature" > "$TEMP_DIR/.ralph/specs/feature.md"
echo "- Task" > "$TEMP_DIR/.ralph/IMPLEMENTATION_PLAN.md"
cat > "$TEMP_DIR/.ralph/PROMPT.md" << 'EOF'
---
iteration_limit: 3
---
# Prompt
EOF
(cd "$TEMP_DIR" && bash "$SETUP_BUILD" > /dev/null 2>&1)
cd "$TEMP_DIR"

# Run to limit
create_transcript "Working 1..."
invoke_and_get_decision > /dev/null

create_transcript "Working 2..."
invoke_and_get_decision > /dev/null

ITER=$(get_state "iteration")
[[ "$ITER" == "3" ]] && log_pass "At iteration 3" || log_fail "Iter" "expected 3, got $ITER"

# Should stop at limit
create_transcript "Working 3..."
invoke_and_get_decision > /dev/null

[[ ! -f "$TEMP_DIR/.ralph/loop-state.json" ]] && log_pass "Stopped at limit" || log_fail "Limit" "should stop"

# ============================================================
# Test 4: Gate Validation
# ============================================================
echo ""
echo "Test 4: Gate Validation"

rm -rf "$TEMP_DIR/.ralph"
mkdir -p "$TEMP_DIR/.ralph"
cd "$TEMP_DIR"

# No specs - should fail (capture and check)
OUTPUT=$(bash "$SETUP_BUILD" 2>&1) || true
if echo "$OUTPUT" | grep -qi "failed\|missing"; then
  log_pass "Fails without specs"
else
  log_fail "Gate" "should fail without specs"
fi

# Add specs but no plan
mkdir -p "$TEMP_DIR/.ralph/specs"
echo "# Spec" > "$TEMP_DIR/.ralph/specs/f.md"
OUTPUT=$(bash "$SETUP_BUILD" 2>&1) || true
if echo "$OUTPUT" | grep -qi "failed\|missing"; then
  log_pass "Fails without plan"
else
  log_fail "Gate" "should fail without plan"
fi

# ============================================================
# Test 5: Multiple Cycles
# ============================================================
echo ""
echo "Test 5: Multiple Impl/Verify Cycles"

setup_ralph
cd "$TEMP_DIR"

# Cycle 1
create_transcript "<status>IMPLEMENTATION_COMPLETE</status>"
invoke_and_get_decision > /dev/null
create_transcript "Verify fail 1"
invoke_and_get_decision > /dev/null
PHASE=$(get_state "phase")
[[ "$PHASE" == "implementation" ]] && log_pass "Cycle 1 complete" || log_fail "Cycle 1" "got $PHASE"

# Cycle 2
create_transcript "<status>IMPLEMENTATION_COMPLETE</status>"
invoke_and_get_decision > /dev/null
create_transcript "Verify fail 2"
invoke_and_get_decision > /dev/null
PHASE=$(get_state "phase")
[[ "$PHASE" == "implementation" ]] && log_pass "Cycle 2 complete" || log_fail "Cycle 2" "got $PHASE"

# Final success
create_transcript "<status>IMPLEMENTATION_COMPLETE</status>"
invoke_and_get_decision > /dev/null
create_transcript "<promise>VERIFIED_COMPLETE</promise>"
invoke_and_get_decision > /dev/null
[[ ! -f "$TEMP_DIR/.ralph/loop-state.json" ]] && log_pass "Final completion" || log_fail "Final" "state should be deleted"

# ============================================================
# Results
# ============================================================
echo ""
echo "========================================"
echo "  Results: $PASSED passed, $FAILED failed"
if [[ $FAILED -gt 0 ]]; then
  echo -e "  ${RED}Some tests failed${NC}"
  exit 1
else
  echo -e "  ${GREEN}All integration tests passed!${NC}"
  exit 0
fi
