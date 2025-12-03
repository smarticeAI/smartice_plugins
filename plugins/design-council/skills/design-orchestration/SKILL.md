---
name: design-orchestration
description: This skill should be used when the user asks to "design council", "multi-model design", "design sprint", "gemini design", "collaborative design", "design review loop", or wants to orchestrate multiple AI models for frontend design work. Provides knowledge about the turn-based design workflow using Opus for planning/review and Gemini for code generation.
version: 1.0.0
---

# Design Council - Multi-Model Design Orchestration

This skill enables collaborative frontend design using multiple AI models in a turn-based workflow.

## Overview

The Design Council orchestrates three specialized roles:
1. **Design Strategist (Opus 4.5)**: Creates comprehensive design specifications
2. **Code Generator (Gemini 3 Pro)**: Generates production-ready frontend code
3. **Code Reviewer (Opus 4.5)**: Evaluates code quality and provides feedback
4. **Adaptation Advisor (Opus 4.5)**: Synthesizes feedback for iterations

## Workflow Pattern

```
User Request
     │
     ▼
┌─────────────┐
│   Round 1   │
├─────────────┤
│ 1. Design Strategist creates spec
│ 2. Gemini generates code
│ 3. Opus reviews code
│ 4. Adaptation Advisor prepares feedback
└──────┬──────┘
       │
       ▼ (if not passed)
┌─────────────┐
│   Round N   │
├─────────────┤
│ 1. Apply feedback to spec
│ 2. Gemini regenerates code
│ 3. Opus reviews again
│ 4. Check pass/fail
└──────┬──────┘
       │
       ▼ (passed or max rounds)
┌─────────────┐
│   Output    │
├─────────────┤
│ Write files to project
└─────────────┘
```

## Using the Design Sprint Command

Invoke the full workflow with:

```
/design-sprint "Your design description" --rounds=3 --framework=react
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `description` | What to design (required) | - |
| `--rounds=N` | Maximum iteration rounds | 3 |
| `--framework=X` | Target framework | react |
| `--strict` | Require score > 8 to pass | false |
| `--output=DIR` | Output directory | ./ |

### Supported Frameworks

- `react` - React with hooks and functional components
- `vue` - Vue 3 composition API
- `svelte` - Svelte components
- `html` - Plain HTML/CSS/JavaScript
- `nextjs` - Next.js App Router

## Role Responsibilities

### Design Strategist

Creates design specifications including:
- **Typography**: Font families, sizes, weights, line heights
- **Colors**: Primary, secondary, semantic, neutral palettes
- **Spacing**: Base unit, scale, grid system
- **Motion**: Timing, easing, animation patterns
- **Components**: Button, input, card, navigation patterns
- **Accessibility**: Contrast ratios, focus states, ARIA requirements

### Code Generator (Gemini)

Generates code following the specification:
- Complete, production-ready components
- Framework-appropriate patterns
- Responsive design implementation
- CSS variables for theming
- Accessibility features

### Code Reviewer

Evaluates across four dimensions:
- **Design Fidelity** (30%): How well code matches spec
- **Code Quality** (25%): Structure, patterns, maintainability
- **Accessibility** (25%): WCAG compliance, keyboard nav, screen readers
- **Completeness** (20%): All features implemented, no placeholders

Pass threshold: Weighted score >= 7.0

### Adaptation Advisor

After each review:
- Prioritizes critical/major/minor issues
- Creates targeted iteration prompt
- Preserves working code elements
- Communicates progress to user

## Environment Setup

Set your Gemini API key:

```bash
export GEMINI_API_KEY="your-api-key-here"
```

Obtain a key from: https://makersuite.google.com/app/apikey

## Design Principles

The Design Council follows these principles (avoid "AI slop"):

### Typography
- Use distinctive fonts (avoid Inter, Roboto, Arial, system fonts)
- Match font personality to project tone
- Define complete type scale

### Colors
- Create cohesive, purposeful palettes
- Avoid cliched purple gradients on white
- Use CSS variables for consistency
- Ensure WCAG contrast compliance

### Layout
- Embrace asymmetry and unexpected compositions
- Use negative space intentionally
- Design for mobile-first responsiveness

### Motion
- Define consistent timing functions
- Use animation purposefully, not decoratively
- Support reduced-motion preferences

## Manual Agent Invocation

For fine-grained control, invoke agents individually:

```
# Create design spec only
Task: design-strategist
Prompt: Create a design spec for a dashboard with sensor visualizations

# Review existing code
Task: opus-reviewer
Prompt: Review this code against the design spec: [code]

# Prepare iteration feedback
Task: adaptation-advisor
Prompt: Analyze this review and prepare iteration guidance: [review]
```

## Integration with Existing Code

To design components for an existing project:

1. Provide context about existing design patterns
2. Reference existing CSS variables or theme
3. Specify component naming conventions
4. Mention any framework-specific requirements

Example:
```
/design-sprint "Create a data table component with sorting and filtering"
  --framework=react
  --context="Uses Tailwind, existing colors in globals.css"
```

## Troubleshooting

### Gemini API Errors
- Verify GEMINI_API_KEY is set
- Check API quota/limits
- Ensure network connectivity

### Low Review Scores
- Provide more specific design requirements
- Increase round count for complex designs
- Check if design spec is too ambiguous

### Iteration Not Improving
- Review adaptation advisor output
- Consider simplifying requirements
- Check for conflicting design requirements

## Additional Resources

For detailed design principles, see:
- `references/design-principles.md` - Extended design guidelines
- `references/prompt-templates.md` - Prompt patterns for each agent
