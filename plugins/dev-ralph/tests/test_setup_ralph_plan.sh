#!/bin/bash

# Unit tests for setup-ralph-plan.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
SCRIPT="$PLUGIN_DIR/scripts/setup-ralph-plan.sh"

# Create temp directory for each test
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

cd "$TEMP_DIR"

# ============================================
# Test 1: Creates .ralph directory structure
# ============================================
test_creates_directory_structure() {
  # Run script
  bash "$SCRIPT" > /dev/null

  # Assert directories exist
  [[ -d ".ralph" ]] || { echo "FAIL: .ralph not created"; return 1; }
  [[ -d ".ralph/specs" ]] || { echo "FAIL: .ralph/specs not created"; return 1; }
  [[ -d ".ralph/stdlib" ]] || { echo "FAIL: .ralph/stdlib not created"; return 1; }

  return 0
}

# ============================================
# Test 2: Outputs correct message
# ============================================
test_outputs_initialization_message() {
  # Run script and capture output
  OUTPUT=$(bash "$SCRIPT")

  # Assert output contains key phrases
  echo "$OUTPUT" | grep -q "Planning phase initialized" || { echo "FAIL: Missing 'initialized' message"; return 1; }
  echo "$OUTPUT" | grep -q "specs/" || { echo "FAIL: Missing 'specs/' in output"; return 1; }
  echo "$OUTPUT" | grep -q "stdlib/" || { echo "FAIL: Missing 'stdlib/' in output"; return 1; }

  return 0
}

# ============================================
# Test 3: Idempotent - can run multiple times
# ============================================
test_idempotent() {
  # Run twice
  bash "$SCRIPT" > /dev/null
  bash "$SCRIPT" > /dev/null

  # Should still work
  [[ -d ".ralph/specs" ]] || { echo "FAIL: Directory missing after second run"; return 1; }

  return 0
}

# Run tests
echo "Testing setup-ralph-plan.sh"

test_creates_directory_structure
test_outputs_initialization_message
test_idempotent

echo "All tests passed"
