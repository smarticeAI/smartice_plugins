#!/bin/bash

# setup-ralph-build.sh
# Validate checklist gate and initialize loop state for build phase

set -euo pipefail

RALPH_DIR=".ralph"
STATE_FILE="$RALPH_DIR/loop-state.json"
PROMPT_FILE="$RALPH_DIR/PROMPT.md"
PLAN_FILE="$RALPH_DIR/IMPLEMENTATION_PLAN.md"

# Parse arguments
VERBOSE=false
DRY_RUN=false

for arg in "$@"; do
  case $arg in
    -v|--verbose)
      VERBOSE=true
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
  esac
done

# Validation errors
ERRORS=()

# Check specs exist
if [[ ! -d "$RALPH_DIR/specs" ]] || [[ -z "$(ls -A $RALPH_DIR/specs 2>/dev/null)" ]]; then
  ERRORS+=("No specs found in $RALPH_DIR/specs/")
fi

# Check plan exists
if [[ ! -f "$PLAN_FILE" ]]; then
  ERRORS+=("No IMPLEMENTATION_PLAN.md found")
fi

# Check PROMPT.md exists
if [[ ! -f "$PROMPT_FILE" ]]; then
  ERRORS+=("No PROMPT.md found")
fi

# Report errors if any
if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo "❌ dev-ralph: Checklist gate failed"
  echo ""
  echo "Missing requirements:"
  for err in "${ERRORS[@]}"; do
    echo "   • $err"
  done
  echo ""
  echo "Run /ralph-plan to complete planning first."
  exit 1
fi

# Count items
SPEC_COUNT=$(ls -1 "$RALPH_DIR/specs" 2>/dev/null | wc -l | tr -d ' ')
PLAN_ITEMS=$(grep -c "^- " "$PLAN_FILE" 2>/dev/null || echo "0")

# Parse frontmatter from PROMPT.md
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$PROMPT_FILE" 2>/dev/null || echo "")
ITERATION_LIMIT=$(echo "$FRONTMATTER" | grep '^iteration_limit:' | sed 's/iteration_limit: *//' || echo "500")
RETRY_LIMIT=$(echo "$FRONTMATTER" | grep '^retry_limit:' | sed 's/retry_limit: *//' || echo "5")
COVERAGE_THRESHOLD=$(echo "$FRONTMATTER" | grep '^coverage_threshold:' | sed 's/coverage_threshold: *//' || echo "80")
VERBOSITY=$(echo "$FRONTMATTER" | grep '^verbosity:' | sed 's/verbosity: *//' || echo "normal")

# Default values if not found
ITERATION_LIMIT=${ITERATION_LIMIT:-500}
RETRY_LIMIT=${RETRY_LIMIT:-5}
COVERAGE_THRESHOLD=${COVERAGE_THRESHOLD:-80}
VERBOSITY=${VERBOSITY:-normal}

# Dry run mode
if [[ "$DRY_RUN" == "true" ]]; then
  echo "🔍 dev-ralph: Dry run mode"
  echo ""
  echo "Checklist gate: PASSED"
  echo ""
  echo "Would start with:"
  echo "  Specs: $SPEC_COUNT files"
  echo "  Plan items: $PLAN_ITEMS"
  echo "  Iteration limit: $ITERATION_LIMIT"
  echo "  Retry limit: $RETRY_LIMIT"
  echo "  Coverage threshold: ${COVERAGE_THRESHOLD}%"
  echo ""
  echo "Run without --dry-run to start the loop."
  exit 0
fi

# Create loop state
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat > "$STATE_FILE" << EOF
{
  "active": true,
  "phase": "implementation",
  "iteration": 1,
  "max_iterations": $ITERATION_LIMIT,
  "retry_count": 0,
  "retry_limit": $RETRY_LIMIT,
  "coverage_threshold": $COVERAGE_THRESHOLD,
  "started_at": "$TIMESTAMP",
  "current_task": null,
  "completed_tasks": [],
  "verification_triggered": false
}
EOF

echo "🚀 dev-ralph: Starting implementation loop"
echo "═══════════════════════════════════════════"
echo ""
echo "Configuration (from PROMPT.md):"
echo "  Iteration limit: $ITERATION_LIMIT"
echo "  Retry limit: $RETRY_LIMIT"
echo "  Coverage threshold: ${COVERAGE_THRESHOLD}%"
echo "  Verbosity: $VERBOSITY"
echo ""
echo "Plan: $PLAN_ITEMS items to implement"
echo "Specs: $SPEC_COUNT specifications loaded"
echo ""
echo "The Stop hook is now active. The loop will continue until:"
echo "  • <promise>VERIFIED_COMPLETE</promise> is output"
echo "  • Iteration limit is reached"
echo "  • /ralph-cancel is executed"
echo ""
echo "Starting iteration 1..."
echo ""
echo "─────────────────────────────────────────────"
echo ""

# Output the prompt to start the loop
cat "$PROMPT_FILE"
