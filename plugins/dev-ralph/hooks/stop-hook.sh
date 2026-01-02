#!/bin/bash

# dev-ralph Stop Hook
# Implements two-phase completion: IMPLEMENTATION_COMPLETE → verification → VERIFIED_COMPLETE
# Based on Geoffrey Huntley's Ralph Wiggum technique with developer-agent collaboration

set -euo pipefail

# Read hook input from stdin (advanced stop hook API)
HOOK_INPUT=$(cat)

# State and prompt files
RALPH_DIR=".ralph"
STATE_FILE="$RALPH_DIR/loop-state.json"
PROMPT_FILE="$RALPH_DIR/PROMPT.md"

# If no active loop, allow exit
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# Parse state JSON
STATE=$(cat "$STATE_FILE")
ACTIVE=$(echo "$STATE" | jq -r '.active // false')

if [[ "$ACTIVE" != "true" ]]; then
  exit 0
fi

# Extract state values
PHASE=$(echo "$STATE" | jq -r '.phase // "implementation"')
ITERATION=$(echo "$STATE" | jq -r '.iteration // 1')
MAX_ITERATIONS=$(echo "$STATE" | jq -r '.max_iterations // 500')
RETRY_COUNT=$(echo "$STATE" | jq -r '.retry_count // 0')
RETRY_LIMIT=$(echo "$STATE" | jq -r '.retry_limit // 5')

# Validate numeric fields
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "⚠️  dev-ralph: State file corrupted (iteration: '$ITERATION')" >&2
  echo "   Stopping loop. Run /ralph-plan to start fresh." >&2
  rm "$STATE_FILE"
  exit 0
fi

if [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "⚠️  dev-ralph: State file corrupted (max_iterations: '$MAX_ITERATIONS')" >&2
  rm "$STATE_FILE"
  exit 0
fi

# Check iteration limit
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "🛑 dev-ralph: Iteration limit ($MAX_ITERATIONS) reached."
  echo "   Completed $ITERATION iterations."
  rm "$STATE_FILE"
  exit 0
fi

# Get transcript path from hook input
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')

if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  echo "⚠️  dev-ralph: Transcript file not found" >&2
  rm "$STATE_FILE"
  exit 0
fi

# Extract last assistant message from transcript
if ! grep -q '"role":"assistant"' "$TRANSCRIPT_PATH"; then
  echo "⚠️  dev-ralph: No assistant messages in transcript" >&2
  rm "$STATE_FILE"
  exit 0
fi

LAST_LINE=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1)
LAST_OUTPUT=$(echo "$LAST_LINE" | jq -r '
  .message.content |
  map(select(.type == "text")) |
  map(.text) |
  join("\n")
' 2>/dev/null || echo "")

if [[ -z "$LAST_OUTPUT" ]]; then
  echo "⚠️  dev-ralph: Could not extract assistant message" >&2
  rm "$STATE_FILE"
  exit 0
fi

# ============================================================
# TWO-PHASE COMPLETION LOGIC
# ============================================================

# Check for VERIFIED_COMPLETE (final exit condition)
if echo "$LAST_OUTPUT" | grep -q "<promise>VERIFIED_COMPLETE</promise>"; then
  echo "✅ dev-ralph: Verified complete after $ITERATION iterations!"
  echo "   All specs implemented and verified."
  rm "$STATE_FILE"
  exit 0
fi

# Check for IMPLEMENTATION_COMPLETE (triggers verification phase)
IMPL_COMPLETE=false
if echo "$LAST_OUTPUT" | grep -q "<status>IMPLEMENTATION_COMPLETE</status>"; then
  IMPL_COMPLETE=true
fi

# Read prompt file
if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "⚠️  dev-ralph: PROMPT.md not found" >&2
  rm "$STATE_FILE"
  exit 0
fi

PROMPT_TEXT=$(cat "$PROMPT_FILE")

# Build system message and update state based on phase
NEXT_ITERATION=$((ITERATION + 1))
NEW_STATE=""

if [[ "$PHASE" == "implementation" ]]; then
  if [[ "$IMPL_COMPLETE" == "true" ]]; then
    # Transition to verification phase
    NEW_STATE=$(echo "$STATE" | jq --argjson iter "$NEXT_ITERATION" '
      .iteration = $iter |
      .phase = "verification" |
      .verification_triggered = true
    ')
    SYSTEM_MSG="🔍 dev-ralph: Verification phase triggered (iteration $NEXT_ITERATION)

IMPLEMENTATION_COMPLETE detected. Now run verification:
1. Use the verification-auditor agent to audit the implementation
2. Check: type-check, lint, test coverage, no placeholders, all specs addressed
3. Write report to .ralph/verification-report.md
4. If ALL checks pass, output: <promise>VERIFIED_COMPLETE</promise>
5. If ANY check fails, return to implementation to fix issues"
  else
    # Continue implementation phase
    NEW_STATE=$(echo "$STATE" | jq --argjson iter "$NEXT_ITERATION" '.iteration = $iter')
    SYSTEM_MSG="🔄 dev-ralph: Implementation iteration $NEXT_ITERATION / $MAX_ITERATIONS
Phase: implementation | Retries: $RETRY_COUNT / $RETRY_LIMIT

Continue implementing. When done:
1. Run: bun run type-check
2. If passing, output: <status>IMPLEMENTATION_COMPLETE</status>"
  fi

elif [[ "$PHASE" == "verification" ]]; then
  # Verification phase but no VERIFIED_COMPLETE - verification failed
  # Return to implementation phase
  NEW_STATE=$(echo "$STATE" | jq --argjson iter "$NEXT_ITERATION" '
    .iteration = $iter |
    .phase = "implementation"
  ')
  SYSTEM_MSG="🔄 dev-ralph: Returning to implementation (iteration $NEXT_ITERATION)

Verification failed. Check .ralph/verification-report.md for issues.
Fix the problems, then output <status>IMPLEMENTATION_COMPLETE</status> when ready to verify again."
fi

# Write updated state
echo "$NEW_STATE" > "$STATE_FILE"

# Output JSON to block exit and feed prompt back
jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
