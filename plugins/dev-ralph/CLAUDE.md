# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Plugin Does

Implements Geoffrey Huntley's "Ralph Wiggum technique" for automated development loops with developer-agent collaboration. Key concepts:

- **One item per loop** - Single task per iteration
- **Stop hook loops** - Hook blocks exit and re-feeds PROMPT.md until `<promise>VERIFIED_COMPLETE</promise>`
- **Two-phase completion** - Implementation complete → verification audit → verified complete
- **Filesystem state** - All state in `.ralph/` directory (git-tracked, no database)

## Plugin Structure

```
dev-ralph/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata
├── commands/
│   ├── ralph-plan.md            # Planning interview (/ralph-plan)
│   ├── ralph-build.md           # Start implementation loop (/ralph-build)
│   ├── ralph-status.md          # Show loop status (/ralph-status)
│   ├── ralph-cancel.md          # Cancel active loop (/ralph-cancel)
│   └── help.md                  # Documentation (/ralph-help)
├── hooks/
│   ├── hooks.json               # Hook registration
│   └── stop-hook.sh             # Two-phase completion loop logic
├── agents/
│   └── verification-auditor.md  # Verification subagent
├── scripts/
│   ├── setup-ralph-plan.sh      # Initialize .ralph/ directory
│   ├── setup-ralph-build.sh     # Validate gate and start loop
│   ├── check-status.sh          # Status display
│   └── cancel-loop.sh           # Cancel with optional checkpoint
├── templates/
│   ├── PROMPT.md.template       # Default loop prompt
│   ├── spec.md.template         # Spec file template
│   └── stdlib-pattern.md.template
├── skills/
│   └── ralph-workflow/
│       ├── SKILL.md
│       └── references/
│           ├── planning-protocol.md
│           └── anti-patterns.md
├── DEV_RALPH_SPEC.md            # Full specification document
└── README.md
```

## Commands

| Command | Description |
|---------|-------------|
| `/ralph-plan [task]` | Start planning interview |
| `/ralph-build [-v] [--dry-run]` | Start implementation loop |
| `/ralph-status` | Show loop status |
| `/ralph-cancel [--checkpoint]` | Cancel loop |
| `/ralph-help` | Show documentation |

## Two-Phase Completion Flow

1. **Implementation Phase**: Claude works through tasks, runs type-check
2. When done: `<status>IMPLEMENTATION_COMPLETE</status>`
3. **Verification Phase**: verification-auditor agent audits
4. If passed: `<promise>VERIFIED_COMPLETE</promise>`
5. Stop hook allows exit

## State Files

- `.ralph/loop-state.json` - Current loop state (iteration, phase, etc.)
- `.ralph/PROMPT.md` - Loop configuration and instructions
- `.ralph/IMPLEMENTATION_PLAN.md` - Task list with completion markers
- `.ralph/specs/*.md` - Feature specifications
- `.ralph/verification-report.md` - Verification audit results

## Testing Changes

After modifying plugin files, sync to installed location:
```bash
cp -r . ~/.claude/plugins/marketplaces/smartice_plugins/plugins/dev-ralph/
```

Then restart Claude Code to pick up changes.

## Reference

- `DEV_RALPH_SPEC.md` - Full specification document
- `ralph-wiggum` plugin in claude-plugins-official - Simpler reference implementation
