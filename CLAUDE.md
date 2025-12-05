# SmartIce Plugin Marketplace

This repository contains Claude Code plugins for the SmartIce marketplace.

## Project Structure

```
plugins/
├── design-council/          # Multi-model frontend design workflow (v2)
│   ├── agents/
│   │   ├── gemini-generator.md    # Generates code via Gemini API (returns summary only)
│   │   ├── opus-reviewer.md       # Reviews generated code for quality
│   │   ├── adaptation-advisor.md  # Prepares guidance for failed iterations
│   │   └── design-strategist.md.bak  # Archived - Main Claude now handles this role
│   ├── commands/
│   │   └── design-sprint.md       # Main orchestration command
│   └── skills/
│       └── design-orchestration/  # Design principles and guidelines
├── db-tools/                # Database review tools
└── smartice-tools/          # Marketplace submission tools
```

## Design-Council Plugin

### Workflow (v2)

1. **Design Sprint Command**: `/design-council:design-sprint "description" --rounds=3 --format=react`
2. **Main Claude Interview**: Gathers preferences via AskUserQuestion (aesthetic, colors, audience)
3. **Option Generation**: Creates 4 palette options + 4 typography options with preview HTML
4. **User Selection**: User selects or mixes options
5. **Code Generation**: gemini-generator agent writes code to staging, returns summary only
6. **Review**: opus-reviewer agent evaluates code quality (pass threshold: 7.0)
7. **Iteration**: If failed, adaptation-advisor prepares feedback for next round
8. **Staging Directory**: All generated code goes to `./.design-sprint-staging/round-N/`

### Output Formats

| Format | Use Case |
|--------|----------|
| `html` | Quick demos, design approval (single file, no build) |
| `react` | Production React components |
| `vue` | Vue 3 composition API |
| `svelte` | Svelte components |
| `nextjs` | Next.js App Router |

### Testing Changes

After modifying plugin files, sync to installed location:
```bash
cp -r plugins/design-council/* ~/.claude/plugins/marketplaces/smartice-plugin-market/plugins/design-council/
```

Then restart Claude Code to pick up changes.

### Key Files

- `plugins/design-council/scripts/gemini-generate.py` - Calls Gemini API for code generation
- Requires `GEMINI_API_KEY` environment variable

## Architecture (v2)

**Key Insight**: Sub-agents cannot use AskUserQuestion - they run to completion and return a single result.

| Role | Handler | Interactive? |
|------|---------|--------------|
| Strategist/Orchestrator | Main Claude | Yes |
| Code Generator | gemini-generator agent | No |
| Code Reviewer | opus-reviewer agent | No |
| Adaptation Advisor | adaptation-advisor agent | No |

**Context Efficiency**: The gemini-generator agent keeps 35KB+ of generated code out of main context by writing to staging and returning only a summary.

## Development Notes

- Agent namespaces: Use full names like `design-council:gemini-generator`
- Staging directory pattern ensures reviewer reads fresh files, not cached content
- **Multi-option preview**: 4 AI-generated palette/typography options with project-specific mockups (palette-generator.py, typography-generator.py, preview-generator.py)
- **Sub-agents are non-interactive**: Only Main Claude uses AskUserQuestion for user input

## Weather Dashboard Example

Test output in `weather-dashboard/` - a Vite React project with retro-futuristic styling.
Run with `cd weather-dashboard && npm run dev`.
