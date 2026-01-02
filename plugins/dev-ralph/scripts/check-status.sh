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
PHASE=$(echo "$STATE" | jq -r '.phase // "implementation"')
ITERATION=$(echo "$STATE" | jq -r '.iteration // 1')
MAX_ITERATIONS=$(echo "$STATE" | jq -r '.max_iterations // 500')
RETRY_COUNT=$(echo "$STATE" | jq -r '.retry_count // 0')
RETRY_LIMIT=$(echo "$STATE" | jq -r '.retry_limit // 5')
COVERAGE_THRESHOLD=$(echo "$STATE" | jq -r '.coverage_threshold // 80')
STARTED_AT=$(echo "$STATE" | jq -r '.started_at // "unknown"')
CURRENT_TASK=$(echo "$STATE" | jq -r '.current_task // "Not set"')
VERIFICATION_TRIGGERED=$(echo "$STATE" | jq -r '.verification_triggered // false')

# Capitalize phase for display (portable for macOS and Linux)
PHASE_DISPLAY=$(echo "$PHASE" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')

echo "Phase: $PHASE_DISPLAY"
echo "Iteration: $ITERATION / $MAX_ITERATIONS (limit)"
echo "Retries: $RETRY_COUNT / $RETRY_LIMIT"
echo ""

if [[ "$CURRENT_TASK" != "null" ]] && [[ "$CURRENT_TASK" != "Not set" ]]; then
  echo "Current Task: $CURRENT_TASK"
  echo ""
fi

# Parse implementation plan for progress
if [[ -f "$PLAN_FILE" ]]; then
  TOTAL=$(grep -c "^- " "$PLAN_FILE" 2>/dev/null || echo "0")
  COMPLETED=$(grep -c "^- \[x\]" "$PLAN_FILE" 2>/dev/null || echo "0")

  echo "Plan Progress: $COMPLETED/$TOTAL items"
  echo ""

  # Show plan items (first 10)
  ITEM_COUNT=0
  while IFS= read -r line; do
    if [[ "$line" =~ ^-\ \[x\] ]]; then
      echo "├── [x] ${line#- \[x\] }"
    elif [[ "$line" =~ ^-\ \[\ \] ]]; then
      echo "├── [ ] ${line#- \[ \] }"
    elif [[ "$line" =~ ^-\  ]]; then
      echo "├── [ ] ${line#- }"
    fi
    ((ITEM_COUNT++))
    if [[ $ITEM_COUNT -ge 10 ]]; then
      REMAINING=$((TOTAL - ITEM_COUNT))
      if [[ $REMAINING -gt 0 ]]; then
        echo "└── ... and $REMAINING more items"
      fi
      break
    fi
  done < <(grep "^- " "$PLAN_FILE")
  echo ""
fi

echo "Configuration:"
echo "  Coverage threshold: ${COVERAGE_THRESHOLD}%"
echo "  Started at: $STARTED_AT"
echo ""

# Verification status
if [[ "$VERIFICATION_TRIGGERED" == "true" ]]; then
  if [[ "$PHASE" == "verification" ]]; then
    echo "Verification Status: In progress"
  else
    echo "Verification Status: Returned to implementation (fixing issues)"
  fi
else
  echo "Verification Status: Not yet triggered"
fi

# Check for verification report
if [[ -f "$RALPH_DIR/verification-report.md" ]]; then
  echo ""
  echo "Latest verification report: .ralph/verification-report.md"
fi
