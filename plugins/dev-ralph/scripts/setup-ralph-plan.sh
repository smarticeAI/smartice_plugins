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
echo "      └── stdlib/    (stdlib module specifications)"
echo ""
echo "Next steps:"
echo "  1. Conduct structured interview"
echo "  2. Define stdlib modules (specs/stdlib/*.md)"
echo "  3. Create feature specs (specs/*.md)"
echo "  4. Create IMPLEMENTATION_PLAN.md (stdlib as Phase 1)"
echo "  5. Create PROMPT.md"
echo ""
echo "Note: stdlib specs define what to build in src/stdlib/"
echo "      Ralph will build stdlib BEFORE features."
echo ""
