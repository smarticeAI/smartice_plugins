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

## Step 3: Write Specs

After the interview is complete, create:

1. **`.ralph/specs/*.md`** - One spec file per major feature/concern
2. **`.ralph/IMPLEMENTATION_PLAN.md`** - Prioritized task list linking to specs
3. **`.ralph/PROMPT.md`** - Using template from `${CLAUDE_PLUGIN_ROOT}/templates/PROMPT.md.template`

Each spec should include:
- Requirements
- Acceptance criteria
- Edge cases
- Dependencies

## Step 4: Confirm

Display the checklist gate:
```
Planning Complete!
═══════════════════

[x] .ralph/specs/*.md          - N spec files
[x] IMPLEMENTATION_PLAN.md     - N items
[x] PROMPT.md                  - Configured

Ready: /ralph-build
```
