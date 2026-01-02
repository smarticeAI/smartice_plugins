#!/bin/bash

# Unit tests for setup-ralph-build.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
SCRIPT="$PLUGIN_DIR/scripts/setup-ralph-build.sh"
FIXTURES="$SCRIPT_DIR/fixtures"

# Create temp directory for each test
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

cd "$TEMP_DIR"

# ============================================
# Test 1: Fails without .ralph/specs
# ============================================
test_fails_without_specs() {
  # Create partial structure (missing specs)
  mkdir -p .ralph
  echo "# Plan" > .ralph/IMPLEMENTATION_PLAN.md
  cat > .ralph/PROMPT.md << 'EOF'
---
iteration_limit: 500
---
# Prompt
EOF

  # Run script - should fail
  if bash "$SCRIPT" 2>&1; then
    echo "FAIL: Should have failed without specs"
    return 1
  fi

  return 0
}

# ============================================
# Test 2: Fails without IMPLEMENTATION_PLAN.md
# ============================================
test_fails_without_plan() {
  rm -rf .ralph
  mkdir -p .ralph/specs
  echo "# Spec" > .ralph/specs/feature.md
  cat > .ralph/PROMPT.md << 'EOF'
---
iteration_limit: 500
---
# Prompt
EOF

  # Run script - should fail
  if bash "$SCRIPT" 2>&1; then
    echo "FAIL: Should have failed without plan"
    return 1
  fi

  return 0
}

# ============================================
# Test 3: Fails without PROMPT.md
# ============================================
test_fails_without_prompt() {
  rm -rf .ralph
  mkdir -p .ralph/specs
  echo "# Spec" > .ralph/specs/feature.md
  echo "- Task 1" > .ralph/IMPLEMENTATION_PLAN.md

  # Run script - should fail
  if bash "$SCRIPT" 2>&1; then
    echo "FAIL: Should have failed without PROMPT.md"
    return 1
  fi

  return 0
}

# ============================================
# Test 4: Creates loop-state.json when valid
# ============================================
test_creates_state_file() {
  rm -rf .ralph
  mkdir -p .ralph/specs
  echo "# Spec" > .ralph/specs/feature.md
  echo "- Task 1" > .ralph/IMPLEMENTATION_PLAN.md
  cat > .ralph/PROMPT.md << 'EOF'
---
iteration_limit: 100
retry_limit: 3
coverage_threshold: 90
verbosity: verbose
---
# Prompt content
EOF

  # Run script
  bash "$SCRIPT" > /dev/null

  # Assert state file created
  [[ -f ".ralph/loop-state.json" ]] || { echo "FAIL: loop-state.json not created"; return 1; }

  # Verify JSON is valid and has expected fields
  cat .ralph/loop-state.json | python3 -c "
import json, sys
d = json.load(sys.stdin)
assert d['active'] == True, 'active should be True'
assert d['phase'] == 'implementation', 'phase should be implementation'
assert d['iteration'] == 1, 'iteration should be 1'
assert d['max_iterations'] == 100, 'max_iterations should be 100'
" || { echo "FAIL: Invalid state file content"; return 1; }

  return 0
}

# ============================================
# Test 5: Dry run does not create state file
# ============================================
test_dry_run() {
  rm -rf .ralph
  mkdir -p .ralph/specs
  echo "# Spec" > .ralph/specs/feature.md
  echo "- Task 1" > .ralph/IMPLEMENTATION_PLAN.md
  cat > .ralph/PROMPT.md << 'EOF'
---
iteration_limit: 500
---
# Prompt
EOF

  # Run with --dry-run
  OUTPUT=$(bash "$SCRIPT" --dry-run)

  # State file should NOT exist
  [[ ! -f ".ralph/loop-state.json" ]] || { echo "FAIL: State file created in dry-run"; return 1; }

  # Output should mention dry run
  echo "$OUTPUT" | grep -qi "dry run" || { echo "FAIL: Dry run not mentioned in output"; return 1; }

  return 0
}

# ============================================
# Test 6: Parses frontmatter config correctly
# ============================================
test_parses_frontmatter() {
  rm -rf .ralph
  mkdir -p .ralph/specs
  echo "# Spec" > .ralph/specs/feature.md
  echo "- Task 1" > .ralph/IMPLEMENTATION_PLAN.md
  cat > .ralph/PROMPT.md << 'EOF'
---
iteration_limit: 200
retry_limit: 10
coverage_threshold: 75
verbosity: minimal
---
# Custom prompt
EOF

  bash "$SCRIPT" > /dev/null

  # Check config was parsed
  cat .ralph/loop-state.json | python3 -c "
import json, sys
d = json.load(sys.stdin)
assert d['max_iterations'] == 200, f'max_iterations should be 200, got {d[\"max_iterations\"]}'
assert d['retry_limit'] == 10, f'retry_limit should be 10, got {d[\"retry_limit\"]}'
assert d['coverage_threshold'] == 75, f'coverage_threshold should be 75, got {d[\"coverage_threshold\"]}'
" || { echo "FAIL: Frontmatter not parsed correctly"; return 1; }

  return 0
}

# Run tests
echo "Testing setup-ralph-build.sh"

test_fails_without_specs
test_fails_without_plan
test_fails_without_prompt
test_creates_state_file
test_dry_run
test_parses_frontmatter

echo "All tests passed"
