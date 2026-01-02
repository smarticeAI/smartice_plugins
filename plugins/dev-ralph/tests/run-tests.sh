#!/bin/bash

# Test runner for dev-ralph plugin
# Runs all unit tests and reports results

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
TOTAL=0

# Test result tracking
run_test() {
  local test_name="$1"
  local test_file="$2"

  ((TOTAL++))

  echo -n "  $test_name... "

  if bash "$test_file" > /tmp/test-output-$$.txt 2>&1; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
  else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
    echo "    Output:"
    sed 's/^/    /' /tmp/test-output-$$.txt
  fi

  rm -f /tmp/test-output-$$.txt
}

echo "========================================"
echo "  dev-ralph Unit Tests"
echo "========================================"
echo ""

# Run each unit test file
for test_file in "$SCRIPT_DIR"/test_*.sh; do
  if [[ -f "$test_file" ]]; then
    test_name=$(basename "$test_file" .sh | sed 's/test_//')
    run_test "$test_name" "$test_file"
  fi
done

# Run integration tests if they exist
if [[ -d "$SCRIPT_DIR/integration" ]]; then
  echo ""
  echo "========================================"
  echo "  Integration Tests"
  echo "========================================"
  echo ""

  for test_file in "$SCRIPT_DIR"/integration/test_*.sh; do
    if [[ -f "$test_file" ]]; then
      test_name=$(basename "$test_file" .sh | sed 's/test_//')
      run_test "integration/$test_name" "$test_file"
    fi
  done
fi

echo ""
echo "========================================"
echo "  Results: $PASSED/$TOTAL passed"
if [[ $FAILED -gt 0 ]]; then
  echo -e "  ${RED}$FAILED tests failed${NC}"
  exit 1
else
  echo -e "  ${GREEN}All tests passed!${NC}"
  exit 0
fi
