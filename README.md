# SmartIce Plugin Marketplace

A Claude Code plugin marketplace featuring design tools for multi-model frontend development.

## Installation

Add this marketplace to Claude Code:

```
/plugin marketplace add HengWoo/smartice_plugin_market
```

## Available Plugins

### design-council

Multi-model frontend design orchestration using Opus for planning/review and Gemini for code generation.

**Features:**
- Turn-based design workflow with multiple AI roles
- Design Strategist (Opus 4.5) creates specifications
- Code Generator (Gemini 3 Pro) produces frontend code
- Code Reviewer (Opus 4.5) evaluates quality
- Adaptation Advisor synthesizes feedback for iterations

**Install:**
```
/plugin install design-council@smartice-plugin-market
```

**Usage:**
```
/design-sprint "Your design description" --rounds=3 --framework=react
```

### design-council-lite

Lightweight version for simpler multi-model design workflows.

**Features:**
- Streamlined two-step workflow
- Claude plans, Gemini generates
- Manual iteration control
- Design templates included

**Install:**
```
/plugin install design-council-lite@smartice-plugin-market
```

## Requirements

Both plugins require a Gemini API key:

```bash
export GEMINI_API_KEY="your-api-key-here"
```

Get your API key: https://makersuite.google.com/app/apikey

## Supported Frameworks

- React (hooks, functional components)
- Vue 3 (Composition API)
- Svelte
- Next.js (App Router)
- Plain HTML/CSS/JavaScript

## License

MIT
