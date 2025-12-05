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
├── palette-options.html       # 4 palette choices with mini mockups
├── typography-options.html    # 4 typography choices with previews
├── round-1/
│   ├── spec.json              # Final design specification
│   ├── code/
│   │   ├── Component.jsx (or index.html for html format)
│   │   └── ...
│   └── review.json
├── round-2/
│   └── ...
```

This ensures:
- Reviewer reads actual files, not stale cache
- Each iteration is preserved
- Easy to compare rounds
- Clear audit trail

## Workflow

> **Architecture Note (v2):** Main Claude handles ALL user interaction. Sub-agents are non-interactive workers that return results without user prompts.

### Phase 1: User Interview (Main Claude - Interactive)

**You (Main Claude) handle all user interaction directly:**

1. **Load skill**: Use the `design-orchestration` skill for design principles
2. **Confirm format**: Use AskUserQuestion to confirm or select output format
3. **Interview preferences**: Use AskUserQuestion to gather:
   - Aesthetic direction (Minimalist / Maximalist / Brutalist / etc.)
   - Color mood (Warm / Cool / Bold / Calm / Dark / Natural)
   - Reference image? (Yes/No - if yes, ask for file path)
   - Target audience (Consumer / Business / Creative / Technical)

4. **Generate palette options**:
   ```bash
   cd ${CLAUDE_PLUGIN_ROOT}/scripts && echo '{"mood": "...", "aesthetic": "...", "project": "..."}' | python3 palette-generator.py
   ```

5. **Create palette preview**:
   ```bash
   cd ${CLAUDE_PLUGIN_ROOT}/scripts && echo '{"palettes": [...], "project": "..."}' | python3 preview-generator.py > ./.design-sprint-staging/palette-options.html
   ```
   Open preview in browser, ask user to select (verbal: "Option 2")

6. **Generate typography options**:
   ```bash
   cd ${CLAUDE_PLUGIN_ROOT}/scripts && echo '{"mood": "...", "aesthetic": "...", "project": "..."}' | python3 typography-generator.py
   ```

7. **Create typography preview**:
   ```bash
   cd ${CLAUDE_PLUGIN_ROOT}/scripts && echo '{"typography": [...], "project": "..."}' | python3 typography-preview-generator.py > ./.design-sprint-staging/typography-options.html
   ```
   Open preview, ask user to select

8. **Allow mixing**: Confirm selections, allow user to mix (e.g., Palette 2 + Typography 3)

9. **Create spec.json**: Write final specification to `./.design-sprint-staging/round-1/spec.json`

### Phase 2: Code Generation (Sub-agent - Non-interactive)

Launch **gemini-generator** agent via Task:

```
Generate frontend code from the design specification.

Spec path: ./.design-sprint-staging/round-1/spec.json
Staging dir: ./.design-sprint-staging
Round: 1

Write code to staging directory and return summary only (not full code).
```

The agent will:
1. Read spec.json
2. Call gemini-generate.py
3. Write code to `./.design-sprint-staging/round-N/code/`
4. Return summary: `{success, lines, file_size, errors}`

**Important**: Generated code stays in sub-agent context (saves ~35KB+ per round)

### Phase 3: Code Review (Sub-agent - Non-interactive)

Launch **opus-reviewer** agent via Task:

```
Review the generated code in the staging directory.

Staging dir: ./.design-sprint-staging/round-N/
- spec.json: design specification
- code/: generated code files

Read files and evaluate against the design specification.
Return review JSON with scores and issues.
```

The reviewer will:
1. Read spec.json and all code files
2. Evaluate against design principles (uses design-orchestration skill)
3. Score across 4 dimensions (fidelity, quality, accessibility, completeness)
4. Return review JSON with overall score and issues

**Pass threshold**: 7.0 (or 8.0 with --strict)

### Phase 4: Iteration Planning (Interactive)

If user chooses to iterate (regardless of pass/fail):

**Step 4a: Get Recommendations (Sub-agent)**

Launch **adaptation-advisor** agent via Task:

```
Analyze the review and prepare iteration guidance.

Review path: ./.design-sprint-staging/round-N/review.json
Spec path: ./.design-sprint-staging/round-N/spec.json

Prioritize issues and create Gemini iteration prompt.
Identify elements to PRESERVE.
```

**Step 4b: Present to User (Main Claude - Interactive)**

Show the user a summary of recommended changes:

```
## Iteration Plan for Round [N+1]

Based on the review (score: X/10), here are the recommended fixes:

### Priority Fixes
1. [MAJOR] Issue description - Recommended fix
2. [MINOR] Issue description - Recommended fix
3. [MINOR] Issue description - Recommended fix

### What Will Be Preserved
- List of elements that are working well
- These will NOT be changed

Would you like to:
- Proceed with these fixes
- Add your own feedback
- Skip certain fixes
- Focus on specific issues only
```

Use **AskUserQuestion** to let user:
1. **Approve** - Proceed with recommended fixes
2. **Modify** - Add comments or change priorities
3. **Focus** - Pick specific issues to address

If user provides feedback, incorporate it into the iteration spec before proceeding.

**Step 4c: Generate Next Round**

Create spec for round N+1 incorporating:
- Adaptation advisor recommendations
- User's additional feedback (if any)
- Clear PRESERVE list

**Return to Phase 2** with the updated spec.

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
