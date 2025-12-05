---
name: design-orchestration
description: This skill should be used when the user asks to "design council", "multi-model design", "design sprint", "gemini design", "collaborative design", "design review loop", or wants to orchestrate multiple AI models for frontend design work. Provides knowledge about the turn-based design workflow using Opus for planning/review and Gemini for code generation.
version: 2.0.0
---

# Design Council - Multi-Model Design Orchestration (v2)

This skill enables collaborative frontend design using multiple AI models in a turn-based workflow.

## Architecture (v2)

> **Key Insight**: Sub-agents cannot use AskUserQuestion for interactive prompts. They run to completion and return a single result. Therefore:
> - **Main Claude** handles ALL user interaction (interview, option selection)
> - **Sub-agents** are non-interactive workers (code generation, review, adaptation)

### Roles

| Role | Who | Interactive? | Purpose |
|------|-----|--------------|---------|
| **Strategist/Orchestrator** | Main Claude | Yes | User interview, option selection, coordination |
| **Code Generator** | gemini-generator agent | No | Calls Gemini API, writes code to staging |
| **Code Reviewer** | opus-reviewer agent | No | Evaluates code, returns scores |
| **Adaptation Advisor** | adaptation-advisor agent | No | Synthesizes feedback for iteration |

### Context Efficiency

Sub-agents keep heavy content (generated code ~35KB+) out of main context:
- gemini-generator returns summary only, not full code
- opus-reviewer reads code in sub-agent context
- Main context stays small across multiple iterations

## Workflow Pattern (v2)

```
User Request
     │
     ▼
┌─────────────────────────────────────────────┐
│  Main Claude (Strategist + Orchestrator)    │
│  ✓ Loads this skill                         │
│  ✓ Interviews user (AskUserQuestion)        │
│  ✓ Generates 4 palette options              │
│  ✓ Generates 4 typography options           │
│  ✓ User selects/mixes options               │
│  ✓ Creates spec.json                        │
└──────────────────┬──────────────────────────┘
                   │
     ┌─────────────┼─────────────┐
     ▼             ▼             ▼
┌──────────┐ ┌──────────┐ ┌──────────┐
│ gemini-  │ │ opus-    │ │ adapt-   │
│ generator│ │ reviewer │ │ advisor  │
│ (Task)   │ │ (Task)   │ │ (Task)   │
│          │ │          │ │          │
│ Returns: │ │ Returns: │ │ Returns: │
│ summary  │ │ scores   │ │ guidance │
└──────────┘ └──────────┘ └──────────┘
     │             │             │
     └─────────────┴─────────────┘
                   │
                   ▼
            ┌─────────────┐
            │   Output    │
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

### Main Claude (Strategist + Orchestrator)

Handles all user-facing interaction:
- **Interview**: Gathers preferences via AskUserQuestion
- **Palette Generation**: Calls palette-generator.py, shows 4 options
- **Typography Generation**: Calls typography-generator.py, shows 4 options
- **Option Selection**: User picks options, allows mixing
- **Spec Creation**: Writes spec.json with selected palette + typography
- **Coordination**: Launches sub-agents, handles iteration loop

Design specifications include:
- **Typography**: Font families, sizes, weights, line heights
- **Colors**: Primary, secondary, semantic, neutral palettes
- **Spacing**: Base unit, scale, grid system
- **Motion**: Timing, easing, animation patterns
- **Components**: Button, input, card, navigation patterns
- **Accessibility**: Contrast ratios, focus states, ARIA requirements

### Code Generator (gemini-generator agent)

Non-interactive sub-agent that:
- Reads spec.json from staging directory
- Calls Gemini API via gemini-generate.py
- Writes generated code to staging/round-N/code/
- **Returns summary only** (lines, file size, success) - NOT full code
- Keeps ~35KB+ of generated code out of main context

Generated code includes:
- Complete, production-ready components
- Framework-appropriate patterns
- Responsive design implementation
- CSS variables for theming
- Accessibility features

### Code Reviewer (opus-reviewer agent)

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

## Manual Agent Invocation (v2)

For fine-grained control, invoke sub-agents individually. Note that user interaction must happen at the main level.

```
# Generate code (returns summary only)
Task: gemini-generator
Prompt: Generate code from spec at ./.design-sprint-staging/round-1/spec.json
        Write to ./.design-sprint-staging/round-1/code/
        Return summary only.

# Review existing code
Task: opus-reviewer
Prompt: Review code in ./.design-sprint-staging/round-1/
        Read spec.json and code/ files.
        Return scores and issues.

# Prepare iteration feedback
Task: adaptation-advisor
Prompt: Analyze review at ./.design-sprint-staging/round-1/review.json
        Prepare iteration guidance for next round.
```

**Note**: The design-strategist role is now handled by Main Claude directly (not a sub-agent) because it requires user interaction.

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
