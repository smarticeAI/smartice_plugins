# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Plugin Does (v2.0.0)

Implements Geoffrey Huntley's "Ralph Wiggum technique" - a simple loop for automated development.

**Key principles:**
- **One item per loop** - Single task per iteration
- **Simple loop** - Stop hook blocks exit, feeds PROMPT.md back
- **Backpressure** - Type-check/tests are the validation (no verification agents)
- **Files are state** - specs/, IMPLEMENTATION_PLAN.md, lessons-learned.md
- **No agents** - Main Claude handles everything inline

## Plugin Structure

```
dev-ralph/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata (v2.0.0)
├── commands/
│   ├── ralph-plan.md            # Planning interview (/ralph-plan)
│   ├── ralph-build.md           # Start implementation loop (/ralph-build)
│   ├── ralph-status.md          # Show loop status (/ralph-status)
│   ├── ralph-cancel.md          # Cancel active loop (/ralph-cancel)
│   └── help.md                  # Documentation (/ralph-help)
├── hooks/
│   ├── hooks.json               # Hook registration
│   └── stop-hook.sh             # Simple loop logic
├── agents/
│   └── codebase-explorer.md     # For searching (optional, Haiku)
├── scripts/
│   ├── setup-ralph-plan.sh      # Initialize .ralph/ directory
│   ├── setup-ralph-build.sh     # Validate gate and start loop
│   ├── check-status.sh          # Status display
│   └── cancel-loop.sh           # Cancel with optional checkpoint
├── templates/
│   ├── PROMPT.md.template       # Default loop prompt
│   └── spec.md.template         # Spec file template
└── skills/
    └── ralph-workflow/
        └── SKILL.md
```

## Commands

| Command | Description |
|---------|-------------|
| `/ralph-plan [task]` | Start planning interview |
| `/ralph-build [--dry-run]` | Start implementation loop |
| `/ralph-status` | Show loop status |
| `/ralph-cancel [--checkpoint]` | Cancel loop |
| `/ralph-help` | Show documentation |

## The Loop (v2.0.0 - Simplified)

```
1. Read context (specs, stdlib, plan, signs, lessons)
2. Pick FIRST unchecked [ ] item
3. Implement fully (following stdlib patterns!)
4. Run type-check (backpressure)
5. Mark [x] when done
6. Append learnings (optional)
7. Continue to next item
8. When ALL done: <promise>VERIFIED_COMPLETE</promise>
```

**No agents needed.** Type-check IS the verification.

## State Files

- `.ralph/loop-state.json` - Loop state: `{active, iteration, max_iterations, started_at}`
- `.ralph/PROMPT.md` - Fed back each iteration
- `.ralph/IMPLEMENTATION_PLAN.md` - Task list with `[ ]` and `[x]` markers
- `.ralph/specs/*.md` - Feature specifications (WHAT to build)
- `.ralph/stdlib/*.md` - Code patterns (HOW to build)
- `.ralph/Signs.md` - Tuning instructions (optional)
- `.ralph/lessons-learned.md` - Append-only discoveries (optional)

## Testing Changes

**IMPORTANT: Claude Code uses the CACHE, not marketplace folders!**

For development, create a symlink from cache to dev folder:
```bash
rm -rf ~/.claude/plugins/cache/smartice-plugin-market/dev-ralph/1.1.0
ln -s $(pwd) ~/.claude/plugins/cache/smartice-plugin-market/dev-ralph/1.1.0
```

Then restart Claude Code. Changes take effect immediately (no copy needed).

## v2.0.0 Changes (Simplification)

Based on comparing with:
- Official `ralph-loop` plugin (claude-plugins-official)
- snarktank/ralph implementation
- Geoffrey Huntley's original vision (PDF)

**Removed:**
- All verification/learning agents (9 agents deleted)
- Complex state machine (phases, retry counts)
- Per-item `<item>COMPLETE</item>` signals
- Agent orchestration in stop hook

**Kept:**
- Simple loop (stop hook → feed PROMPT.md → iterate)
- codebase-explorer agent (for searching, optional)
- Files as state (specs, plan, lessons)
- Signs (tuning instructions)

**Why:** Huntley's vision uses subagents for WORK (search, write), not for DECISIONS. Type-check is the backpressure. Main Claude makes all decisions.

## Reference

- `SIMPLIFICATION_PLAN.md` - Full rationale for v2.0.0 changes
- `ralph-loop` plugin in claude-plugins-official - Reference implementation
- https://ghuntley.com/ralph/ - Geoffrey Huntley's original post
