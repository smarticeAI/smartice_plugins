#!/bin/bash

# setup-ralph-plan.sh
# Initialize the .ralph/ directory structure for planning phase

set -euo pipefail

RALPH_DIR=".ralph"

# Create directory structure
mkdir -p "$RALPH_DIR/specs"
mkdir -p "$RALPH_DIR/stdlib"

echo "📋 dev-ralph: Planning phase initialized"
echo ""
echo "Directory structure created:"
echo "  $RALPH_DIR/"
echo "  ├── specs/       (specification files)"
echo "  └── stdlib/      (code patterns)"
echo ""
echo "Next steps:"
echo "  1. Conduct structured interview"
echo "  2. Create spec files in specs/"
echo "  3. Create IMPLEMENTATION_PLAN.md"
echo "  4. Create PROMPT.md"
echo "  5. Optionally add patterns to stdlib/"
echo ""
