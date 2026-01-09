#!/bin/bash

# setup-ralph-plan.sh
# Initialize the .ralph/ directory structure for planning phase

set -euo pipefail

RALPH_DIR=".ralph"

# Create directory structure
mkdir -p "$RALPH_DIR/specs/stdlib"

echo "📋 dev-ralph: Planning phase initialized"
echo ""
echo "Directory structure created:"
echo "  $RALPH_DIR/"
echo "  └── specs/"
echo "      └── stdlib/    (stdlib module specifications → builds to src/stdlib/)"
echo ""
echo "Next steps:"
echo "  1. Conduct structured interview"
echo "  2. Define stdlib modules in specs/stdlib/*.md (optional)"
echo "  3. Create feature specs in specs/*.md"
echo "  4. Create IMPLEMENTATION_PLAN.md (stdlib as Phase 1 if defined)"
echo "  5. Create PROMPT.md with Signs section"
echo ""
echo "Compound Learning:"
echo "  • Signs: Anti-patterns added to PROMPT.md when errors repeat 3+ times"
echo "  • stdlib: Actual code in src/stdlib/ built from specs/stdlib/*.md"
echo "  • lessons-learned.md: Accumulated wisdom across iterations"
echo ""
