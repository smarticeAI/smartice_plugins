#!/bin/bash

# cancel-loop.sh
# Cancel active Ralph loop with optional git checkpoint

set -euo pipefail

RALPH_DIR=".ralph"
STATE_FILE="$RALPH_DIR/loop-state.json"

# Parse arguments
CHECKPOINT=false

for arg in "$@"; do
  case $arg in
    --checkpoint)
      CHECKPOINT=true
      ;;
  esac
done

# Check if loop is active
if [[ ! -f "$STATE_FILE" ]]; then
  echo "ℹ️  No active Ralph loop found"
  echo ""
  if [[ -d "$RALPH_DIR" ]]; then
    echo "The .ralph/ directory exists with your previous planning work."
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

# Read state before deletion
STATE=$(cat "$STATE_FILE")
ITERATION=$(echo "$STATE" | jq -r '.iteration // 1')
PHASE=$(echo "$STATE" | jq -r '.phase // "implementation"')

# Git checkpoint if requested
if [[ "$CHECKPOINT" == "true" ]]; then
  echo "Creating git checkpoint..."

  # Check if in git repo
  if git rev-parse --git-dir > /dev/null 2>&1; then
    git add -A
    COMMIT_MSG="Ralph checkpoint at iteration $ITERATION"

    if git diff --cached --quiet; then
      echo "No changes to commit."
    else
      COMMIT_HASH=$(git commit -m "$COMMIT_MSG" 2>&1 | grep -o '[a-f0-9]\{7,\}' | head -1 || echo "unknown")
      echo ""
      echo "Git checkpoint created:"
      echo "  Commit: $COMMIT_HASH"
      echo "  Message: $COMMIT_MSG"
    fi
  else
    echo "Warning: Not in a git repository. Skipping checkpoint."
  fi
  echo ""
fi

# Delete state file
rm "$STATE_FILE"

echo "🛑 Ralph loop cancelled"
if [[ "$CHECKPOINT" == "true" ]]; then
  echo "   (with checkpoint)"
fi
echo ""
echo "Stopped at iteration: $ITERATION"
echo "Phase: $PHASE"
echo ""
echo "The .ralph/ directory is preserved:"
echo "  • specs/ - Your specifications"
echo "  • IMPLEMENTATION_PLAN.md - Task list"
echo "  • stdlib/ - Code patterns"
echo "  • PROMPT.md - Loop configuration"
echo ""
echo "To resume: /ralph-build"
echo "To restart planning: /ralph-plan"
