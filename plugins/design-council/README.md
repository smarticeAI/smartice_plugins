# Design Council

Multi-model frontend design orchestration plugin for Claude Code.

## Overview

Design Council orchestrates multiple AI models in a turn-based workflow to create production-quality frontend code:

- **Claude Opus 4.5**: Design planning, code review, and iteration guidance
- **Gemini 3 Pro**: Frontend code generation

## Quick Start

### 1. Set Up Gemini API Key

```bash
export GEMINI_API_KEY="your-api-key-here"
```

Get your API key from: https://makersuite.google.com/app/apikey

### 2. Run a Design Sprint

```bash
/design-sprint "A modern dashboard with data visualizations" --framework=react
```

## Command Reference

### /design-sprint

```
/design-sprint "[description]" [options]

Options:
  --rounds=N      Maximum iteration rounds (default: 3)
  --framework=X   Target: react|vue|svelte|html|nextjs (default: react)
  --strict        Require score > 8 to pass (default: 7.0)
  --output=DIR    Output directory (default: ./)
  --context=TEXT  Existing codebase context
```

### Examples

```bash
# Basic React component
/design-sprint "User profile card with avatar and stats"

# Vue with specific requirements
/design-sprint "Data table with sorting and filtering" --framework=vue --rounds=5

# With existing codebase context
/design-sprint "Navigation sidebar" --context="Uses Tailwind, dark theme, existing colors in theme.css"
```

## Workflow

```
┌─────────────────────────────────────────┐
│              DESIGN SPRINT              │
├─────────────────────────────────────────┤
│                                         │
│  Round N                                │
│  ┌─────────────────────────────────┐   │
│  │ 1. Design Strategist (Opus)     │   │
│  │    → Creates design spec        │   │
│  └──────────────┬──────────────────┘   │
│                 ▼                       │
│  ┌─────────────────────────────────┐   │
│  │ 2. Code Generator (Gemini)      │   │
│  │    → Generates frontend code    │   │
│  └──────────────┬──────────────────┘   │
│                 ▼                       │
│  ┌─────────────────────────────────┐   │
│  │ 3. Code Reviewer (Opus)         │   │
│  │    → Scores and critiques       │   │
│  └──────────────┬──────────────────┘   │
│                 ▼                       │
│  ┌─────────────────────────────────┐   │
│  │ 4. Adaptation Advisor (Opus)    │   │
│  │    → Prepares next iteration    │   │
│  └──────────────┬──────────────────┘   │
│                 │                       │
│        ┌───────┴───────┐               │
│        ▼               ▼               │
│   [Pass ≥7.0]    [Fail <7.0]           │
│        │               │               │
│        ▼               ▼               │
│   Write Files    Next Round            │
│                                         │
└─────────────────────────────────────────┘
```

## Quality Scoring

Code is evaluated across four dimensions:

| Dimension | Weight | What It Measures |
|-----------|--------|------------------|
| Design Fidelity | 30% | Typography, colors, spacing match spec |
| Code Quality | 25% | Structure, patterns, maintainability |
| Accessibility | 25% | WCAG compliance, keyboard nav, ARIA |
| Completeness | 20% | All features, responsive, no placeholders |

**Pass Threshold**: 7.0 (or 8.0 with `--strict`)

## Agents

### design-strategist

Creates comprehensive design specifications:
- Aesthetic direction (minimalist, maximalist, brutalist, etc.)
- Typography system (distinctive fonts, scales)
- Color palette (primary, semantic, neutrals)
- Spacing and layout patterns
- Motion and animation guidelines
- Component patterns
- Accessibility requirements

### opus-reviewer

Reviews generated code with structured scoring:
- Scores each quality dimension (1-10)
- Identifies issues (critical/major/minor)
- Provides specific fix recommendations
- Makes pass/fail decisions

### adaptation-advisor

Bridges reviews and iterations:
- Prioritizes fixes by impact
- Preserves working code elements
- Creates targeted iteration prompts
- Communicates progress to user

## Design Principles

The Design Council follows these principles to avoid "AI slop":

### Do

- Use distinctive typography (Playfair Display, Space Grotesk, etc.)
- Create cohesive, purposeful color palettes
- Embrace asymmetry and unexpected layouts
- Add intentional motion and micro-interactions
- Ensure WCAG accessibility compliance

### Don't

- Use generic fonts (Inter, Roboto, Arial)
- Apply purple gradients on white backgrounds
- Create cookie-cutter symmetric layouts
- Add decoration without purpose
- Skip accessibility considerations

## Troubleshooting

### "GEMINI_API_KEY not set"

```bash
# Add to your shell profile (~/.zshrc or ~/.bashrc)
export GEMINI_API_KEY="your-api-key-here"

# Then reload
source ~/.zshrc
```

### Low Review Scores

- Provide more specific design requirements
- Add context about existing codebase
- Increase `--rounds` for complex designs
- Use `--strict` for higher quality threshold

### API Timeouts

- Complex designs may take longer
- Check network connectivity
- Retry with the same command

## File Structure

```
design-council/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   ├── design-strategist.md
│   ├── opus-reviewer.md
│   └── adaptation-advisor.md
├── commands/
│   └── design-sprint.md
├── scripts/
│   └── gemini-generate.py
├── skills/
│   └── design-orchestration/
│       ├── SKILL.md
│       └── references/
│           ├── design-principles.md
│           └── prompt-templates.md
└── README.md
```

## License

MIT
