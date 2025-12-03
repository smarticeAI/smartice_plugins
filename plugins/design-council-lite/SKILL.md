---
name: design-council-lite
description: This skill should be used when the user asks to "design with gemini", "multi-model design", "generate frontend code", "create UI components", or wants to leverage both Claude and Gemini for frontend development. Provides a lightweight workflow for design planning and code generation.
version: 1.0.0
---

# Design Council Lite

A lightweight multi-model frontend design workflow using Claude for planning and Gemini for code generation.

## Overview

This skill orchestrates two AI models for frontend development:
- **Claude (Opus 4.5)**: Design strategy, specifications, and code review
- **Gemini 3 Pro**: Frontend code generation

Unlike the full design-council plugin, this lightweight version provides knowledge and utilities without complex orchestration. Follow the workflow manually for maximum control.

## Workflow

```
┌─────────────────────────────────────────┐
│         DESIGN COUNCIL LITE             │
├─────────────────────────────────────────┤
│                                         │
│  Step 1: CREATE DESIGN SPEC             │
│  Claude creates detailed specification  │
│                                         │
│  Step 2: GENERATE CODE                  │
│  Call Gemini via script                 │
│                                         │
│  Step 3: REVIEW & ITERATE               │
│  Claude reviews, suggests fixes         │
│                                         │
│  Step 4: OUTPUT                         │
│  Write files to project                 │
│                                         │
└─────────────────────────────────────────┘
```

## Step 1: Create Design Specification

Before generating code, create a comprehensive design specification.

### Design Spec Template

```json
{
  "project_name": "Component Name",
  "description": "What this component does",
  "aesthetic": "minimalist | maximalist | brutalist | organic | industrial",

  "typography": {
    "heading": "Space Grotesk | Playfair Display | etc.",
    "body": "IBM Plex Sans | Source Sans Pro | etc.",
    "mono": "JetBrains Mono | Fira Code | etc."
  },

  "colors": {
    "primary": "#1B4332",
    "secondary": "#F59E0B",
    "background": "#FAFAFA",
    "text": "#171717",
    "accent": "#8B5CF6"
  },

  "components": [
    "Header with navigation",
    "Hero section with CTA",
    "Feature cards grid",
    "Footer with links"
  ],

  "requirements": [
    "Mobile-first responsive",
    "Dark mode support",
    "Accessible (WCAG AA)",
    "Smooth animations"
  ]
}
```

### Anti-Patterns to Avoid

When creating design specs, avoid these "AI slop" patterns:

| Category | Avoid | Use Instead |
|----------|-------|-------------|
| Typography | Inter, Roboto, Arial, system fonts | Space Grotesk, Playfair Display, IBM Plex |
| Colors | Purple gradients on white | Cohesive palettes with purpose |
| Layout | Symmetric card grids | Asymmetric, intentional compositions |
| Components | Rounded corners everywhere | Varied treatments per context |

## Step 2: Generate Code with Gemini

Use the provided script to call Gemini API for code generation.

### Basic Usage

```bash
# Set API key first
export GEMINI_API_KEY="your-api-key"

# Generate code
echo '{"design_spec": "Dashboard with charts", "framework": "react"}' | \
  python3 ${CLAUDE_PLUGIN_ROOT}/scripts/gemini_generate.py
```

### Full Specification Input

```bash
cat << 'EOF' | python3 ${CLAUDE_PLUGIN_ROOT}/scripts/gemini_generate.py
{
  "design_spec": "Modern dashboard for agricultural sensor data with real-time charts, dark theme, and mobile support",
  "framework": "react",
  "context": "Using Tailwind CSS, existing color variables in theme.css"
}
EOF
```

### Supported Frameworks

| Framework | Value | Notes |
|-----------|-------|-------|
| React | `react` | Hooks, functional components |
| Vue 3 | `vue` | Composition API |
| Svelte | `svelte` | Svelte 4 patterns |
| Next.js | `nextjs` | App Router |
| Plain HTML | `html` | No framework |

### Script Output

The script returns JSON with:
```json
{
  "error": false,
  "code": "// Generated code here...",
  "finish_reason": "STOP",
  "lines_of_code": 450,
  "components_count": 3,
  "has_styles": true
}
```

## Step 3: Review & Iterate

After Gemini generates code, review it against your design spec.

### Review Checklist

**Design Fidelity**
- [ ] Fonts match specification
- [ ] Colors match palette
- [ ] Spacing follows system
- [ ] Layout matches intent

**Code Quality**
- [ ] Clean component structure
- [ ] No code duplication
- [ ] Proper TypeScript types
- [ ] Follows framework patterns

**Accessibility**
- [ ] Semantic HTML
- [ ] ARIA labels on icons
- [ ] Keyboard navigation works
- [ ] Focus indicators visible
- [ ] Color contrast passes

**Completeness**
- [ ] All components present
- [ ] Responsive breakpoints
- [ ] No TODOs or placeholders
- [ ] Error states defined

### Iteration Pattern

If code needs fixes, call Gemini again with feedback:

```bash
cat << 'EOF' | python3 ${CLAUDE_PLUGIN_ROOT}/scripts/gemini_generate.py
{
  "design_spec": "Modern dashboard...",
  "framework": "react",
  "feedback": "1. Add focus:ring to all buttons. 2. Change --color-secondary from #6366f1 to #8b5cf6. 3. Add loading skeleton components."
}
EOF
```

## Step 4: Output Files

Once code passes review, write files to your project.

### Recommended Structure

```
src/
├── components/
│   ├── Dashboard.tsx
│   ├── Chart.tsx
│   └── StatCard.tsx
├── styles/
│   └── dashboard.css
├── hooks/
│   └── useSensorData.ts
└── utils/
    └── formatters.ts
```

## Quick Reference

### Design Directions

| Style | Typography | Colors | Layout |
|-------|------------|--------|--------|
| Minimalist | Single font, large sizes | 2-3 colors, lots of white | Generous whitespace |
| Maximalist | Multiple fonts | Bold, saturated palette | Layered, dense |
| Brutalist | Monospace, extreme sizes | High contrast B&W | Unconventional grid |
| Organic | Soft serifs, flowing | Earth tones, gradients | Curved sections |
| Industrial | Sans-serif, utilitarian | Dark grays, accent pops | Sharp edges |

### Color Palette Template

```css
:root {
  /* Primary */
  --color-primary-50: #f0fdf4;
  --color-primary-500: #22c55e;
  --color-primary-900: #14532d;

  /* Semantic */
  --color-success: #10b981;
  --color-warning: #f59e0b;
  --color-error: #ef4444;

  /* Neutral */
  --color-gray-50: #fafafa;
  --color-gray-500: #737373;
  --color-gray-900: #171717;
}
```

### Animation Timing

```css
:root {
  --duration-quick: 100ms;
  --duration-normal: 250ms;
  --duration-slow: 400ms;
  --ease-out: cubic-bezier(0, 0, 0.2, 1);
  --ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
}
```

## Environment Setup

### Required

```bash
export GEMINI_API_KEY="your-api-key-here"
```

Get your API key: https://makersuite.google.com/app/apikey

### Verify Setup

```bash
# Test API connectivity
echo '{"design_spec": "Hello world button", "framework": "html"}' | \
  python3 ${CLAUDE_PLUGIN_ROOT}/scripts/gemini_generate.py
```

## Example Session

```
User: Create a dashboard for sensor data monitoring

Claude: I'll create a design specification first.

[Creates design spec with typography, colors, components]

Claude: Now generating code with Gemini...

[Runs gemini_generate.py script]

Claude: Here's the generated code. Let me review it...

Review:
- Typography: 8/10 - Fonts correct, missing one import
- Colors: 9/10 - Palette matches spec
- Accessibility: 6/10 - Missing focus states
- Completeness: 8/10 - Core components done

Claude: Regenerating with fixes...

[Runs script again with feedback]

Claude: Second iteration passes review (8.5/10).
Ready to write files:
- Dashboard.tsx
- components/Chart.tsx
- components/StatCard.tsx
- styles/dashboard.css

Write to src/? (y/n)
```

## Tips

1. **Be specific in design specs** - Vague specs produce generic code
2. **Include context** - Mention existing styles, patterns, constraints
3. **Review thoroughly** - Don't skip accessibility checks
4. **Iterate as needed** - Complex UIs may need 2-3 rounds
5. **Trust the workflow** - Claude plans, Gemini generates, Claude reviews
