#!/bin/bash

# setup-ralph-plan.sh
# Initialize the .ralph/ directory structure for planning phase

set -euo pipefail

RALPH_DIR=".ralph"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

# Create directory structure
mkdir -p "$RALPH_DIR/specs/stdlib"
mkdir -p "$RALPH_DIR/stdlib"

# Copy PROMPT.md template (CRITICAL - do not let Claude generate a minimal version)
if [[ -f "$PLUGIN_ROOT/templates/PROMPT.md.template" ]]; then
  cp "$PLUGIN_ROOT/templates/PROMPT.md.template" "$RALPH_DIR/PROMPT.md"
  echo "✅ Copied PROMPT.md template ($(wc -l < "$RALPH_DIR/PROMPT.md") lines)"
else
  echo "⚠️  Warning: PROMPT.md template not found at $PLUGIN_ROOT/templates/PROMPT.md.template"
fi

# Copy lessons-learned template
if [[ -f "$PLUGIN_ROOT/templates/lessons-learned.md.template" ]]; then
  cp "$PLUGIN_ROOT/templates/lessons-learned.md.template" "$RALPH_DIR/lessons-learned.md"
  echo "✅ Copied lessons-learned.md template"
fi

# Copy stdlib README template
if [[ -f "$PLUGIN_ROOT/templates/stdlib/README.md.template" ]]; then
  cp "$PLUGIN_ROOT/templates/stdlib/README.md.template" "$RALPH_DIR/stdlib/README.md"
  echo "✅ Copied stdlib/README.md template"
fi

echo ""
echo "📋 dev-ralph: Planning phase initialized"
echo ""
echo "Directory structure:"
echo "  $RALPH_DIR/"
echo "  ├── specs/stdlib/  (stdlib interface specs)"
echo "  ├── stdlib/        (code patterns)"
echo "  ├── PROMPT.md      (loop instructions - from template)"
echo "  └── lessons-learned.md (compound learning)"
echo ""
echo "Next steps:"
echo "  1. Conduct structured interview"
echo "  2. Create feature specs in specs/*.md"
echo "  3. Create IMPLEMENTATION_PLAN.md"
echo "  4. Customize PROMPT.md frontmatter (build_commands)"
echo ""
