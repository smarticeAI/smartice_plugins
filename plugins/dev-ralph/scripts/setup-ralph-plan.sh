#!/bin/bash

# setup-ralph-plan.sh
# Initialize the .ralph/ directory structure for planning phase

set -euo pipefail

RALPH_DIR=".ralph"

# Create directory structure
mkdir -p "$RALPH_DIR/specs/stdlib"
mkdir -p "$RALPH_DIR/stdlib"

echo "📋 dev-ralph: Planning phase initialized"
echo ""
echo "Directory structure created:"
echo "  $RALPH_DIR/"
echo "  ├── specs/"
echo "  │   └── stdlib/    (stdlib interface specifications)"
echo "  └── stdlib/        (code patterns → injected into build loop)"
echo ""
echo "Next steps:"
echo "  1. Conduct structured interview"
echo "  2. Analyze existing codebase patterns (if not greenfield)"
echo "  3. Define stdlib modules in specs/stdlib/*.md (optional)"
echo "  4. Create stdlib patterns in stdlib/*.md (for build loop injection)"
echo "  5. Create feature specs in specs/*.md"
echo "  6. Create lessons-learned.md (for compound learning)"
echo "  7. Create IMPLEMENTATION_PLAN.md (stdlib as Phase 1)"
echo "  8. Create PROMPT.md with Signs section"
echo ""
echo "Compound Learning:"
echo "  • Signs: Anti-patterns added to PROMPT.md when errors repeat 3+ times"
echo "  • stdlib: Patterns injected into build loop context"
echo "  • lessons-learned.md: Error counts track toward Sign promotion"
echo ""
