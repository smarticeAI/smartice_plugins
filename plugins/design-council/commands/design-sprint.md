---
description: "Orchestrate multi-model frontend design: Opus plans, Gemini codes, Opus reviews"
argument-hint: "[description] --rounds=3 --format=react"
model: claude-opus-4-5-20251101
---

# Design Sprint

Execute a design sprint with iterative planning, generation, and review.

## Arguments

Parse from $ARGUMENTS:
- **description**: What to design (required)
- **--rounds=N**: Max iterations (default: 3)
- **--format=X**: html/react/vue/svelte/nextjs (default: ask user)
- **--strict**: Require score > 8 (default: 7.0)
- **--output=DIR**: Output directory (default: ./)

### Output Formats

| Format | Best For |
|--------|----------|
| **html** | Quick demos, design approval, stakeholder previews (single file, no build) |
| **react** | Production components, complex interactivity |
| **vue** | Vue 3 composition API components |
| **svelte** | Svelte components |
| **nextjs** | Next.js App Router pages/components |

**Format Confirmation:**
- If `--format` is provided: Show the format and ask user to confirm or change
- If `--format` is not provided: Ask user to choose from available formats

This ensures the user always has visibility into the tech stack choice.

## Staging Directory

All generated code is written to a staging directory first:
```
./.design-sprint-staging/
├── round-1/
│   ├── spec.json
│   ├── code/
│   │   ├── Component.jsx (or index.html for html format)
│   │   └── ...
│   └── review.json
├── round-2/
│   └── ...
└── color-palette-preview.html
```

This ensures:
- Reviewer reads actual files, not stale cache
- Each iteration is preserved
- Easy to compare rounds
- Clear audit trail

## Workflow

### Phase 1: Design Specification

Launch **design-strategist** agent:
```
Create a design specification for: $ARGUMENTS
Output format: [--format value or ask user]
```

The agent will:
1. **Confirm output format** - If format provided, show it and ask to confirm; if not, ask user to choose
2. Interview for aesthetic preferences (visual mood, typography style)
3. Ask about existing brand colors or generate palette
4. **Create color palette preview** at `./.design-sprint-staging/color-palette-preview.html`
5. Ask user to confirm colors (open preview in browser)
6. Output final JSON design spec

**Write spec to**: `./.design-sprint-staging/round-1/spec.json`

### Phase 2: Code Generation

Call Gemini API with the design spec:
```bash
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/gemini-generate.py
```

**Write generated code to staging**:
- HTML format: `./.design-sprint-staging/round-N/code/index.html`
- React format: `./.design-sprint-staging/round-N/code/*.jsx` + `*.css`
- Other formats: appropriate file structure

### Phase 3: Code Review

Launch **opus-reviewer** agent with the staging directory:

```
Review the generated code in the staging directory.

Design spec: ./.design-sprint-staging/round-N/spec.json
Generated code: ./.design-sprint-staging/round-N/code/

Read the files and evaluate against the design specification.
```

The reviewer will:
1. Read spec.json
2. Read all code files in the code/ directory
3. Evaluate against spec
4. Output review JSON

**Write review to**: `./.design-sprint-staging/round-N/review.json`

### Phase 4: Adaptation (if not passed)

If score < threshold AND rounds remain:

Launch **adaptation-advisor** agent with:
```
Review the iteration at: ./.design-sprint-staging/round-N/
- spec.json: design specification
- code/: generated code
- review.json: review results

Prepare guidance for round N+1.
```

Agent outputs iteration prompt. Return to Phase 2 for next round.

### Phase 5: Output

**If passed:**
```
Design Sprint Complete!
Final Score: [SCORE]/10
Rounds Used: [N] of [MAX]
Format: [html/react/vue/etc]

Staged at: ./.design-sprint-staging/round-N/code/
```

Ask user to confirm output directory, then:
- Copy from staging to final output directory
- Optionally clean up staging directory

For HTML format: Single file can be opened directly in browser.
For framework formats: Component files ready for integration.

**If max rounds reached:**
```
Sprint finished after [N] rounds.
Final Score: [SCORE]/10 (below threshold)
Remaining issues: [LIST]

Staged at: ./.design-sprint-staging/round-N/code/

Options:
1. Accept current code (copy to output)
2. Continue manual iteration
3. Restart with different requirements
```

## Quick Preview

For any round, user can preview the generated code:
- HTML: Open `./.design-sprint-staging/round-N/code/index.html` in browser
- React: Need to set up dev server (or use color palette preview for quick visual check)

## Error Handling

**Gemini API failure:**
```
ERROR: Gemini API failed - [message]
Check: GEMINI_API_KEY set? API quota available?
```

**Invalid arguments:**
```
Usage: /design-sprint "description" [--rounds=N] [--format=X] [--strict]

Formats: html, react, vue, svelte, nextjs
```

## Cleanup

After successful completion, optionally remove staging:
```bash
rm -rf ./.design-sprint-staging/
```

Or keep it for reference/comparison.
