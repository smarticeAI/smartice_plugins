#!/bin/bash

# setup-ralph-build.sh (v3 - Simplified)
# Validate gate and initialize simple loop state

set -euo pipefail

RALPH_DIR=".ralph"
STATE_FILE="$RALPH_DIR/loop-state.json"
PROMPT_FILE="$RALPH_DIR/PROMPT.md"
PLAN_FILE="$RALPH_DIR/IMPLEMENTATION_PLAN.md"

# Parse arguments
DRY_RUN=false
for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=true
      ;;
  esac
done

# Validation
ERRORS=()

if [[ ! -d "$RALPH_DIR/specs" ]] || [[ -z "$(ls -A $RALPH_DIR/specs 2>/dev/null)" ]]; then
  ERRORS+=("No specs found in $RALPH_DIR/specs/")
fi

if [[ ! -f "$PLAN_FILE" ]]; then
  ERRORS+=("No IMPLEMENTATION_PLAN.md found")
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  ERRORS+=("No PROMPT.md found")
fi

if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo "❌ dev-ralph: Gate failed"
  echo ""
  for err in "${ERRORS[@]}"; do
    echo "   • $err"
  done
  echo ""
  echo "Run /ralph-plan first."
  exit 1
fi

# Count items
SPEC_COUNT=$(ls -1 "$RALPH_DIR/specs" 2>/dev/null | wc -l | tr -d ' ')
PLAN_ITEMS=$(grep -c "^- " "$PLAN_FILE" 2>/dev/null || echo "0")

# Parse iteration limit from PROMPT.md frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$PROMPT_FILE" 2>/dev/null || echo "")
ITERATION_LIMIT=$(echo "$FRONTMATTER" | grep '^iteration_limit:' | sed 's/iteration_limit: *//' | sed 's/#.*//' | tr -d ' ' || echo "500")
ITERATION_LIMIT=${ITERATION_LIMIT:-500}

# Dry run
if [[ "$DRY_RUN" == "true" ]]; then
  echo "🔍 dev-ralph: Dry run"
  echo ""
  echo "Gate: PASSED"
  echo "  Specs: $SPEC_COUNT files"
  echo "  Plan items: $PLAN_ITEMS"
  echo "  Iteration limit: $ITERATION_LIMIT"
  echo ""
  echo "Run without --dry-run to start."
  exit 0
fi

# Create simple loop state
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat > "$STATE_FILE" << EOF
{
  "active": true,
  "iteration": 1,
  "max_iterations": $ITERATION_LIMIT,
  "started_at": "$TIMESTAMP"
}
EOF

echo "🚀 dev-ralph: Starting loop"
echo "═══════════════════════════"
echo ""
echo "Plan: $PLAN_ITEMS items"
echo "Specs: $SPEC_COUNT files"
echo "Limit: $ITERATION_LIMIT iterations"
echo ""
echo "Loop continues until:"
echo "  • <promise>VERIFIED_COMPLETE</promise>"
echo "  • Iteration limit reached"
echo "  • /ralph-cancel"
echo ""
echo "─────────────────────────────"
echo ""

# Output prompt to start
cat "$PROMPT_FILE"
