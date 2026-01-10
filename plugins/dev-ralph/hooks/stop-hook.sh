#!/bin/bash

# dev-ralph Stop Hook - Just tells Claude to read PROMPT.md again
# Based on Geoffrey Huntley's: while :; do cat PROMPT.md | amp ; done

set -euo pipefail

HOOK_INPUT=$(cat)

# Get project directory from hook input
PROJECT_DIR=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty')
if [[ -z "$PROJECT_DIR" ]]; then
  exit 0
fi

STATE_FILE="$PROJECT_DIR/.ralph/loop-state.json"

# No state = no loop
[[ ! -f "$STATE_FILE" ]] && exit 0

STATE=$(cat "$STATE_FILE")
[[ $(echo "$STATE" | jq -r '.active // false') != "true" ]] && exit 0

ITERATION=$(echo "$STATE" | jq -r '.iteration // 1')
MAX_ITERATIONS=$(echo "$STATE" | jq -r '.max_iterations // 500')

# Iteration limit
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "🛑 dev-ralph: Iteration limit reached."
  rm "$STATE_FILE"
  exit 0
fi

# Check for completion
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')
if [[ -f "$TRANSCRIPT_PATH" ]]; then
  if grep -q "<promise>VERIFIED_COMPLETE</promise>" "$TRANSCRIPT_PATH" 2>/dev/null; then
    echo "✅ dev-ralph: Complete!"
    rm "$STATE_FILE"
    exit 0
  fi
fi

# Increment and continue
NEXT=$((ITERATION + 1))
echo "$STATE" | jq --argjson i "$NEXT" '.iteration = $i' > "$STATE_FILE"

# Tell Claude to read PROMPT.md
jq -n '{
  "decision": "block",
  "reason": "Continue loop",
  "systemMessage": "Read .ralph/PROMPT.md and follow the instructions."
}'
