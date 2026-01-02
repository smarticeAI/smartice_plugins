#!/bin/bash

# Unit tests for check-status.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
SCRIPT="$PLUGIN_DIR/scripts/check-status.sh"

# Create temp directory for each test
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

cd "$TEMP_DIR"

# ============================================
# Test 1: Shows "no active loop" when no state file
# ============================================
test_no_active_loop() {
  OUTPUT=$(bash "$SCRIPT")

  echo "$OUTPUT" | grep -qi "no active loop" || { echo "FAIL: Should show 'no active loop'"; return 1; }

  return 0
}

# ============================================
# Test 2: Shows status when loop is active
# ============================================
test_shows_active_status() {
  mkdir -p .ralph
  cat > .ralph/loop-state.json << 'EOF'
{
  "active": true,
  "phase": "implementation",
  "iteration": 5,
  "max_iterations": 500,
  "retry_count": 1,
  "retry_limit": 5,
  "coverage_threshold": 80,
  "started_at": "2026-01-02T10:00:00Z",
  "current_task": "Add authentication",
  "verification_triggered": false
}
EOF
  echo "- Task 1" > .ralph/IMPLEMENTATION_PLAN.md
  echo "- [x] Done task" >> .ralph/IMPLEMENTATION_PLAN.md

  OUTPUT=$(bash "$SCRIPT")

  # Check key status elements
  echo "$OUTPUT" | grep -q "Implementation" || { echo "FAIL: Should show phase"; return 1; }
  echo "$OUTPUT" | grep -q "5 / 500" || { echo "FAIL: Should show iteration"; return 1; }
  echo "$OUTPUT" | grep -q "1 / 5" || { echo "FAIL: Should show retry count"; return 1; }

  return 0
}

# ============================================
# Test 3: Shows verification phase correctly
# ============================================
test_shows_verification_phase() {
  mkdir -p .ralph
  cat > .ralph/loop-state.json << 'EOF'
{
  "active": true,
  "phase": "verification",
  "iteration": 10,
  "max_iterations": 500,
  "verification_triggered": true
}
EOF
  echo "- [x] Task 1" > .ralph/IMPLEMENTATION_PLAN.md

  OUTPUT=$(bash "$SCRIPT")

  echo "$OUTPUT" | grep -qi "verification" || { echo "FAIL: Should show verification phase"; return 1; }

  return 0
}

# ============================================
# Test 4: Shows plan progress
# ============================================
test_shows_plan_progress() {
  mkdir -p .ralph
  cat > .ralph/loop-state.json << 'EOF'
{
  "active": true,
  "phase": "implementation",
  "iteration": 3,
  "max_iterations": 500
}
EOF
  cat > .ralph/IMPLEMENTATION_PLAN.md << 'EOF'
# Implementation Plan

- [x] Task 1 completed
- [x] Task 2 completed
- Task 3 pending
- Task 4 pending
- Task 5 pending
EOF

  OUTPUT=$(bash "$SCRIPT")

  # Should show 2 completed out of 5
  echo "$OUTPUT" | grep -q "2/5" || { echo "FAIL: Should show 2/5 progress"; return 1; }

  return 0
}

# ============================================
# Test 5: Handles missing plan file gracefully
# ============================================
test_handles_missing_plan() {
  mkdir -p .ralph
  cat > .ralph/loop-state.json << 'EOF'
{
  "active": true,
  "phase": "implementation",
  "iteration": 1,
  "max_iterations": 500
}
EOF

  # No plan file - should still work
  OUTPUT=$(bash "$SCRIPT")

  echo "$OUTPUT" | grep -q "Implementation" || { echo "FAIL: Should still show phase"; return 1; }

  return 0
}

# Run tests
echo "Testing check-status.sh"

test_no_active_loop
test_shows_active_status
test_shows_verification_phase
test_shows_plan_progress
test_handles_missing_plan

echo "All tests passed"
