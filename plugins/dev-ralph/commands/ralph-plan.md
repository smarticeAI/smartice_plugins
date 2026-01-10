---
description: "Start Ralph planning phase with in-depth interview to create specs and implementation plan"
argument-hint: "[task-description]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-plan.sh *)", "Read", "Write", "Glob", "Grep", "AskUserQuestion"]
---

# Ralph Planning Phase

Task description: $ARGUMENTS

## Step 1: Initialize

Run the setup script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-plan.sh
```

## Step 2: In-Depth Interview

Interview me in detail using the AskUserQuestion tool about literally anything:
- Technical implementation details
- UI & UX preferences
- Concerns and constraints
- Tradeoffs and priorities
- Edge cases
- Error handling approaches
- Performance requirements
- Security considerations

**Interview Guidelines:**
- **Ask 4 questions at a time** using the AskUserQuestion tool's multi-question capability for efficient interviews
- **Make sure the questions are not obvious.** Dig deep. Ask follow-up questions based on my answers.
- Continue interviewing until you have a complete understanding of what I want to build.
- Do not stop after a fixed number of questions. Keep asking until the spec is fully fleshed out.

## Step 2.5: Analyze Existing Patterns (if existing codebase)

If this is an **existing codebase** (not greenfield), analyze it for patterns:

```bash
# Look for existing error handling patterns
grep -rn "try {" src/ | head -10
grep -rn "catch" src/ | head -10

# Look for existing utility modules
ls src/utils/ src/lib/ src/helpers/ 2>/dev/null

# Look for existing types/interfaces
grep -rn "^export type\|^export interface" src/ | head -10
```

Based on analysis, propose stdlib patterns that match existing conventions:
```
Based on your codebase, I found these patterns:
1. Error handling: {pattern found}
2. API calls: {pattern found}
3. Validation: {pattern found}

Should I codify these into stdlib/ so the build loop follows them?
```

## Step 2.6: stdlib Requirements

Ask about reusable utilities/patterns the project needs:

```
Question: What reusable utilities/patterns does this project need?

Examples:
- Error handling utilities (Result types, error classes)
- API client wrappers
- Validation helpers
- Common data transformations
- Logging/telemetry
- Testing utilities

Options:
- Yes, define stdlib modules now
- No, add them during build as needed
- Skip stdlib (use framework defaults)
```

If "Yes", interview about each stdlib module:
- Module name (e.g., "errors", "validation", "api-client")
- Purpose (what problem does it solve?)
- Key functions/classes needed
- Patterns to follow (e.g., "always return Result, never throw")

**Create both specs AND pattern files:**
1. `specs/stdlib/[module-name].md` - Interface specification (using template)
2. `stdlib/[module-name].md` - Code pattern documentation (injected into build loop)

For spec files, use `${CLAUDE_PLUGIN_ROOT}/templates/stdlib-spec.md.template`

**Why stdlib matters:**
- Single source of truth for patterns
- Features import from stdlib, don't duplicate utilities
- stdlib patterns are injected into build loop context
- When Ralph generates wrong patterns, update stdlib → Ralph follows them

## Step 3: Write Specs

After the interview is complete, create:

1. **`.ralph/specs/stdlib/*.md`** - stdlib module specs (if defined in Step 2.6)
2. **`.ralph/stdlib/*.md`** - Code patterns for build loop injection
3. **`.ralph/specs/*.md`** - One spec file per major feature/concern
4. **`.ralph/lessons-learned.md`** - Initialize with template from `${CLAUDE_PLUGIN_ROOT}/templates/lessons-learned.md.template`
5. **`.ralph/IMPLEMENTATION_PLAN.md`** - Prioritized task list with:
   - Phase 0: Project setup
   - Phase 1: stdlib modules (build first!)
   - Phase 2+: Features (use stdlib)

### Customize PROMPT.md (Already Created by Setup Script)

The setup script has already copied the full PROMPT.md template (172 lines).

**You only need to customize the frontmatter:**

Edit `.ralph/PROMPT.md` to update:
```yaml
build_commands:
  type_check: "{project's type-check command}"
  lint: "{project's lint command}"
  test: "{project's test command}"
```

For Bun projects: `bun run type-check`, `bun run lint`, `bun test`
For npm projects: `npm run type-check`, `npm run lint`, `npm test`

**DO NOT rewrite PROMPT.md. Only customize the frontmatter.**

Each feature spec should include:
- Requirements
- Acceptance criteria
- Edge cases
- Dependencies
- Verification checklist

Each stdlib spec should follow `${CLAUDE_PLUGIN_ROOT}/templates/stdlib-spec.md.template`

## Step 4: Confirm

Display the checklist gate:
```
Planning Complete!
═══════════════════

[x] .ralph/specs/stdlib/*.md   - N stdlib module specs (or skipped)
[x] .ralph/stdlib/*.md         - N stdlib patterns (for build loop injection)
[x] .ralph/specs/*.md          - N feature specs
[x] lessons-learned.md         - Initialized for compound learning
[x] IMPLEMENTATION_PLAN.md     - stdlib as Phase 1, features after
[x] PROMPT.md                  - Configured with Signs section

Ready: /ralph-build
```
