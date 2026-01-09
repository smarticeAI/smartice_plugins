#!/bin/bash

# dev-ralph Stop Hook (v2 - Per-Item Verification)
# Implements per-item verification loop with compound learning
# Based on Geoffrey Huntley's Ralph Wiggum technique

set -euo pipefail

# Read hook input from stdin (advanced stop hook API)
HOOK_INPUT=$(cat)

# State and prompt files
RALPH_DIR=".ralph"
STATE_FILE="$RALPH_DIR/loop-state.json"
PROMPT_FILE="$RALPH_DIR/PROMPT.md"
PLAN_FILE="$RALPH_DIR/IMPLEMENTATION_PLAN.md"
LESSONS_FILE="$RALPH_DIR/lessons-learned.md"

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

# Read prompt file
if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "⚠️  dev-ralph: PROMPT.md not found" >&2
  rm "$STATE_FILE"
  exit 0
fi

PROMPT_TEXT=$(cat "$PROMPT_FILE")

# ============================================================
# COUNT ITEMS
# ============================================================

# Count completed and remaining items (handle missing file and ensure numeric)
if [[ -f "$PLAN_FILE" ]]; then
  COMPLETED_COUNT=$(grep -c '^\- \[x\]' "$PLAN_FILE" 2>/dev/null) || COMPLETED_COUNT=0
  REMAINING_COUNT=$(grep -c '^\- \[ \]' "$PLAN_FILE" 2>/dev/null) || REMAINING_COUNT=0
else
  COMPLETED_COUNT=0
  REMAINING_COUNT=0
fi

# Ensure numeric (strip any whitespace/non-digits)
COMPLETED_COUNT=${COMPLETED_COUNT//[^0-9]/}
REMAINING_COUNT=${REMAINING_COUNT//[^0-9]/}
COMPLETED_COUNT=${COMPLETED_COUNT:-0}
REMAINING_COUNT=${REMAINING_COUNT:-0}

TOTAL_ITEMS=$((COMPLETED_COUNT + REMAINING_COUNT))

# ============================================================
# SIGNAL DETECTION
# ============================================================

# Check for VERIFIED_COMPLETE (final exit condition)
if echo "$LAST_OUTPUT" | grep -q "<promise>VERIFIED_COMPLETE</promise>"; then
  echo "✅ dev-ralph: Verified complete after $ITERATION iterations!"
  echo "   $COMPLETED_COUNT/$TOTAL_ITEMS items implemented and verified."
  rm "$STATE_FILE"
  exit 0
fi

# Check for ITEM_COMPLETE (single item done, triggers per-item verification)
ITEM_COMPLETE=false
if echo "$LAST_OUTPUT" | grep -q "<item>COMPLETE</item>"; then
  ITEM_COMPLETE=true
fi

# Check for IMPLEMENTATION_COMPLETE (all items done, triggers final verification)
IMPL_COMPLETE=false
if echo "$LAST_OUTPUT" | grep -q "<status>IMPLEMENTATION_COMPLETE</status>"; then
  IMPL_COMPLETE=true
fi

# ============================================================
# GIT DIFF FEEDBACK (Compound Learning)
# ============================================================

CHANGES_SUMMARY=""
if git rev-parse --git-dir >/dev/null 2>&1; then
    CHANGES_SUMMARY=$(git diff --stat HEAD 2>/dev/null | tail -5 || echo "")
    if [[ -z "$CHANGES_SUMMARY" ]]; then
        CHANGES_SUMMARY=$(git status --short 2>/dev/null | head -5 || echo "")
    fi
fi

# ============================================================
# STALE DETECTION
# ============================================================

LAST_COMPLETED=$(echo "$STATE" | jq -r '.last_completed_count // 0')
STALE_COUNT=$(echo "$STATE" | jq -r '.stale_iterations // 0')

if [[ "$COMPLETED_COUNT" -eq "$LAST_COMPLETED" ]]; then
    STALE_COUNT=$((STALE_COUNT + 1))
else
    STALE_COUNT=0
fi

STALE_WARNING=""
if [[ $STALE_COUNT -ge 5 ]]; then
    STALE_WARNING="
⚠️ WARNING: No progress in $STALE_COUNT iterations.
   Consider: /ralph-cancel or asking developer for help."
fi

# ============================================================
# STATE MACHINE
# ============================================================

NEXT_ITERATION=$((ITERATION + 1))
NEW_STATE=""
SYSTEM_MSG=""

# ----------------------------------------------------------
# ITEM_COMPLETE: Per-item verification and continue
# ----------------------------------------------------------
if [[ "$ITEM_COMPLETE" == "true" ]]; then

  if [[ $REMAINING_COUNT -gt 0 ]]; then
    # More items remain - continue to next item
    NEW_STATE=$(echo "$STATE" | jq --argjson iter "$NEXT_ITERATION" --argjson completed "$COMPLETED_COUNT" '
      .iteration = $iter |
      .phase = "implementation" |
      .last_completed_count = $completed |
      .stale_iterations = 0
    ')

    SYSTEM_MSG="✅ dev-ralph: Item complete! (iteration $NEXT_ITERATION)

Progress: $COMPLETED_COUNT/$TOTAL_ITEMS items done | $REMAINING_COUNT remaining

**Per-item verification passed.** Now:
1. Run verification-auditor: Task(subagent_type=\"dev-ralph:verification-auditor\", prompt=\"Quick verification for completed item\")
2. Read verification feedback
3. Update .ralph/lessons-learned.md with learnings
4. Pick the NEXT unchecked item from IMPLEMENTATION_PLAN.md
5. Implement it fully
6. Output: <item>COMPLETE</item>

**Remember**: Read lessons-learned.md - previous iterations may have learned useful patterns!"

  else
    # No more items - all implementation done, trigger final verification
    NEW_STATE=$(echo "$STATE" | jq --argjson iter "$NEXT_ITERATION" --argjson completed "$COMPLETED_COUNT" '
      .iteration = $iter |
      .phase = "final_verification" |
      .last_completed_count = $completed |
      .stale_iterations = 0
    ')

    SYSTEM_MSG="🎉 dev-ralph: All items complete! (iteration $NEXT_ITERATION)

Progress: $COMPLETED_COUNT/$TOTAL_ITEMS items done | **ALL ITEMS IMPLEMENTED**

**Final verification phase:**
1. Run full verification: Task(subagent_type=\"dev-ralph:verification-auditor\", prompt=\"Final verification - all items complete\")
2. Read .ralph/verification-report.md
3. Update .ralph/lessons-learned.md with final learnings
4. If ALL checks pass: Output <promise>VERIFIED_COMPLETE</promise>
5. If ANY check fails: Fix issues and re-verify"
  fi

# ----------------------------------------------------------
# IMPLEMENTATION_COMPLETE: Legacy signal (redirect to final verification)
# ----------------------------------------------------------
elif [[ "$IMPL_COMPLETE" == "true" ]]; then
  # Treat as final verification trigger
  NEW_STATE=$(echo "$STATE" | jq --argjson iter "$NEXT_ITERATION" --argjson completed "$COMPLETED_COUNT" '
    .iteration = $iter |
    .phase = "final_verification" |
    .last_completed_count = $completed |
    .stale_iterations = 0
  ')

  SYSTEM_MSG="🔍 dev-ralph: Final verification triggered (iteration $NEXT_ITERATION)

Run full verification:
1. Task(subagent_type=\"dev-ralph:verification-auditor\", prompt=\"Final verification\")
2. Read .ralph/verification-report.md
3. Update lessons-learned.md
4. If ALL pass: <promise>VERIFIED_COMPLETE</promise>
5. If ANY fail: fix and re-verify"

# ----------------------------------------------------------
# FINAL_VERIFICATION phase: waiting for VERIFIED_COMPLETE
# ----------------------------------------------------------
elif [[ "$PHASE" == "final_verification" ]]; then
  # Still in final verification but no VERIFIED_COMPLETE - must have failed
  NEW_STATE=$(echo "$STATE" | jq --argjson iter "$NEXT_ITERATION" --argjson completed "$COMPLETED_COUNT" --argjson stale "$STALE_COUNT" '
    .iteration = $iter |
    .phase = "implementation" |
    .last_completed_count = $completed |
    .stale_iterations = $stale
  ')

  SYSTEM_MSG="🔄 dev-ralph: Verification failed, returning to implementation (iteration $NEXT_ITERATION)

Check .ralph/verification-report.md for issues.
Fix problems, then output <item>COMPLETE</item> when ready."

# ----------------------------------------------------------
# DEFAULT: Continue implementation (or trigger final verification if all done)
# ----------------------------------------------------------
else
  # Check if all items are already complete
  if [[ $REMAINING_COUNT -eq 0 ]] && [[ $COMPLETED_COUNT -gt 0 ]]; then
    # All items done - trigger final verification
    NEW_STATE=$(echo "$STATE" | jq --argjson iter "$NEXT_ITERATION" --argjson completed "$COMPLETED_COUNT" '
      .iteration = $iter |
      .phase = "final_verification" |
      .last_completed_count = $completed |
      .stale_iterations = 0
    ')

    SYSTEM_MSG="🎉 dev-ralph: All $COMPLETED_COUNT items complete! (iteration $NEXT_ITERATION)

**All items in IMPLEMENTATION_PLAN.md are checked [x].**

**Final verification phase:**
1. Run full verification: Task(subagent_type=\"dev-ralph:verification-auditor\", prompt=\"Final verification - all items complete\")
2. Read .ralph/verification-report.md
3. Update .ralph/lessons-learned.md with final learnings
4. If ALL checks pass: Output <promise>VERIFIED_COMPLETE</promise>
5. If ANY check fails: Fix issues and re-verify"
  else
    # Items remain - continue implementation
    NEW_STATE=$(echo "$STATE" | jq --argjson iter "$NEXT_ITERATION" --argjson completed "$COMPLETED_COUNT" --argjson stale "$STALE_COUNT" '
      .iteration = $iter |
      .last_completed_count = $completed |
      .stale_iterations = $stale
    ')

    SYSTEM_MSG="🔄 dev-ralph: Implementation iteration $NEXT_ITERATION / $MAX_ITERATIONS
Progress: $COMPLETED_COUNT/$TOTAL_ITEMS items | Retries: $RETRY_COUNT/$RETRY_LIMIT
${STALE_WARNING}

**Your task**: Implement ONE item at a time.
1. Pick the FIRST unchecked [ ] item from IMPLEMENTATION_PLAN.md
2. Implement it fully (no placeholders!)
3. Run type-check
4. Mark it [x] in IMPLEMENTATION_PLAN.md
5. Output: <item>COMPLETE</item>

**Remember**: Read .ralph/lessons-learned.md to avoid past mistakes."
  fi
fi

# ============================================================
# OUTPUT
# ============================================================

# Write updated state
echo "$NEW_STATE" > "$STATE_FILE"

# Build git changes section
GIT_CONTEXT=""
if [[ -n "$CHANGES_SUMMARY" ]]; then
    GIT_CONTEXT="
---
## Recent Changes
\`\`\`
${CHANGES_SUMMARY}
\`\`\`"
fi

FULL_CONTEXT="${PROMPT_TEXT}

---
${SYSTEM_MSG}
${GIT_CONTEXT}"

jq -n \
  --arg status "$SYSTEM_MSG" \
  --arg context "$FULL_CONTEXT" \
  '{
    "decision": "block",
    "reason": $status,
    "systemMessage": $context
  }'

exit 0
