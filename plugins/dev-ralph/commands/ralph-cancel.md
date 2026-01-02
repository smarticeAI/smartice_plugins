---
description: "Cancel active Ralph loop with optional git checkpoint"
argument-hint: "[--checkpoint]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/cancel-loop.sh *)", "Read"]
---

# Ralph Cancel

Cancel the active Ralph implementation loop.

## Arguments

Options: $ARGUMENTS

- `--checkpoint`: Create a git commit with current state before canceling

## Cancel Protocol

Run the cancel script:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/cancel-loop.sh $ARGUMENTS
```

## Behavior

### Without --checkpoint

1. Read current iteration count from `.ralph/loop-state.json`
2. Delete `.ralph/loop-state.json`
3. Report cancellation

Output:
```
🛑 Ralph loop cancelled

Stopped at iteration: [N]
Phase: [implementation | verification]

The .ralph/ directory is preserved:
  • specs/ - Your specifications
  • IMPLEMENTATION_PLAN.md - Task list (may have progress markers)
  • stdlib/ - Code patterns
  • PROMPT.md - Loop configuration

To resume: /ralph-build
To restart planning: /ralph-plan
```

### With --checkpoint

1. Stage all changes: `git add -A`
2. Commit with message: `Ralph checkpoint at iteration N`
3. Delete `.ralph/loop-state.json`
4. Report cancellation with commit info

Output:
```
🛑 Ralph loop cancelled (with checkpoint)

Stopped at iteration: [N]
Phase: [implementation | verification]

Git checkpoint created:
  Commit: [hash]
  Message: Ralph checkpoint at iteration N

The .ralph/ directory is preserved.

To resume: /ralph-build
To restart planning: /ralph-plan
```

## If No Loop Active

```
ℹ️  No active Ralph loop found

Nothing to cancel. The .ralph/ directory may still exist
with your previous planning work.

To start a new loop: /ralph-build
To plan a new project: /ralph-plan
```

## Important Notes

- Canceling does NOT delete the `.ralph/` directory
- Your specs, plan, and patterns are preserved
- You can resume with `/ralph-build` at any time
- Use `--checkpoint` to save work before canceling
