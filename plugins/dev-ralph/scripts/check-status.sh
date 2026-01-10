#!/bin/bash

# check-status.sh
# Display current Ralph loop status

set -euo pipefail

RALPH_DIR=".ralph"
STATE_FILE="$RALPH_DIR/loop-state.json"
PLAN_FILE="$RALPH_DIR/IMPLEMENTATION_PLAN.md"

echo "Ralph Loop Status"
echo "═════════════════"
echo ""

# Check if loop is active
if [[ ! -f "$STATE_FILE" ]]; then
  echo "Status: No active loop"
  echo ""

  if [[ -d "$RALPH_DIR" ]]; then
    echo "The .ralph/ directory exists with previous planning work."
    echo ""
    echo "To start a new loop: /ralph-build"
    echo "To plan a new project: /ralph-plan"
  else
    echo "To start a new project:"
    echo "  1. Run /ralph-plan to create specs and plan"
    echo "  2. Run /ralph-build to start implementation"
  fi
  exit 0
fi

# Parse state
STATE=$(cat "$STATE_FILE")
ITERATION=$(echo "$STATE" | jq -r '.iteration // 1')
MAX_ITERATIONS=$(echo "$STATE" | jq -r '.max_iterations // 500')
STARTED_AT=$(echo "$STATE" | jq -r '.started_at // "unknown"')

echo "Status: ACTIVE"
echo "Iteration: $ITERATION / $MAX_ITERATIONS"
echo "Started: $STARTED_AT"
echo ""

# Parse implementation plan for progress
if [[ -f "$PLAN_FILE" ]]; then
  TOTAL=$(grep -c "^- " "$PLAN_FILE" 2>/dev/null || echo "0")
  COMPLETED=$(grep -c "^- \[x\]" "$PLAN_FILE" 2>/dev/null || echo "0")

  echo "Progress: $COMPLETED/$TOTAL items"
  echo ""

  # Show first 10 items
  ITEM_COUNT=0
  while IFS= read -r line; do
    if [[ "$line" =~ ^-\ \[x\] ]]; then
      echo "  [x] ${line#- \[x\] }"
    elif [[ "$line" =~ ^-\ \[\ \] ]]; then
      echo "  [ ] ${line#- \[ \] }"
    elif [[ "$line" =~ ^-\  ]]; then
      echo "  [ ] ${line#- }"
    fi
    ((ITEM_COUNT++))
    if [[ $ITEM_COUNT -ge 10 ]]; then
      REMAINING=$((TOTAL - ITEM_COUNT))
      if [[ $REMAINING -gt 0 ]]; then
        echo "  ... and $REMAINING more"
      fi
      break
    fi
  done < <(grep "^- " "$PLAN_FILE")
fi
