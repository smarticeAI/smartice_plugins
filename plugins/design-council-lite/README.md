# Design Council Lite

Lightweight multi-model frontend design plugin for Claude Code.

## Overview

A streamlined approach to multi-model frontend development:
- **Claude (Opus 4.5)**: Design planning and code review
- **Gemini 3 Pro**: Code generation

Unlike the full `design-council` plugin, this lite version follows Anthropic's skill pattern: just SKILL.md + scripts, no complex agent orchestration.

## Quick Start

```bash
# 1. Set API key
export GEMINI_API_KEY="your-api-key"

# 2. Generate code
echo '{"design_spec": "Modern button component", "framework": "react"}' | \
  python3 ~/.claude/plugins/design-council-lite/scripts/gemini_generate.py
```

## Structure

```
design-council-lite/
├── .claude-plugin/
│   └── plugin.json
├── SKILL.md              # All knowledge in one file
├── scripts/              # Modular Python utilities
│   ├── gemini_generate.py
│   ├── api_client.py
│   ├── prompt_builder.py
│   ├── response_parser.py
│   └── validators.py
├── templates/            # Design spec templates
│   ├── react-component.json
│   ├── dashboard.json
│   └── form.json
└── README.md
```

## Workflow

1. **Claude creates design spec** - Typography, colors, components
2. **Call Gemini script** - Generate code
3. **Claude reviews** - Check quality, suggest fixes
4. **Iterate if needed** - Regenerate with feedback
5. **Output files** - Write to project

## Using Templates

```bash
# Load a template and customize
cat ~/.claude/plugins/design-council-lite/templates/dashboard.json | \
  python3 ~/.claude/plugins/design-council-lite/scripts/gemini_generate.py
```

## Comparison

| Feature | design-council | design-council-lite |
|---------|---------------|---------------------|
| Structure | Agents + Commands + Skill | Skill only |
| Orchestration | Automated rounds | Manual workflow |
| Complexity | High | Low |
| Flexibility | Framework-driven | User-driven |
| Learning curve | Steeper | Gentle |

## When to Use

**Use design-council-lite when:**
- You want manual control over each step
- Simple components or pages
- Learning the workflow
- Quick prototypes

**Use design-council when:**
- Complex multi-component designs
- Need automated quality gates
- Want turn-based iteration
- Large-scale generation

## API Key

Get your Gemini API key: https://makersuite.google.com/app/apikey

```bash
# Add to ~/.zshrc or ~/.bashrc
export GEMINI_API_KEY="your-api-key"
```

## License

MIT
