# dev-ralph

Developer-agent collaborative implementation of Geoffrey Huntley's Ralph Wiggum technique with structured planning, two-phase completion, and quality gates.

## Overview

dev-ralph provides an autonomous development loop for greenfield projects:

1. **Planning Phase**: Structured interview to create specs and implementation plan
2. **Build Phase**: Autonomous loop with quality gates
3. **Verification Phase**: Coverage, lint, placeholder detection before completion

## Installation

Install via SmartIce marketplace:

```bash
claude /install smartice_plugins
```

Or copy manually:

```bash
cp -r dev-ralph ~/.claude/plugins/marketplaces/smartice_plugins/plugins/
```

Or use with `--plugin-dir` for testing:

```bash
claude --plugin-dir /path/to/dev-ralph
```

## Quick Start

```bash
# 1. Plan your project
/ralph-plan "Build a kanban board with drag-drop"

# 2. Answer interview questions to create specs
# 3. Start implementation loop
/ralph-build

# 4. Monitor progress
/ralph-status

# 5. Cancel if needed
/ralph-cancel --checkpoint
```

## Commands

| Command | Description |
|---------|-------------|
| `/ralph-plan [task]` | Start planning interview |
| `/ralph-build [-v]` | Start implementation loop |
| `/ralph-status` | Show loop status |
| `/ralph-cancel [--checkpoint]` | Cancel loop |
| `/ralph-help` | Show documentation |

## How It Works

### Planning Phase

`/ralph-plan` conducts a structured interview:
- What are you building?
- What technology stack?
- What features needed?
- Quality requirements?

Creates `.ralph/` directory with:
- `specs/*.md` - Feature specifications
- `IMPLEMENTATION_PLAN.md` - Prioritized task list
- `stdlib/*.md` - Code patterns (optional)
- `PROMPT.md` - Loop configuration

### Build Phase

`/ralph-build` activates the Stop hook:
1. Claude reads specs and picks a task
2. Implements the task fully
3. Runs type-check
4. If passing, outputs `<status>IMPLEMENTATION_COMPLETE</status>`
5. Verification subagent audits the work
6. If all checks pass, outputs `<promise>VERIFIED_COMPLETE</promise>`
7. Loop exits

### Two-Phase Completion

**Phase 1: Implementation**
- Work through IMPLEMENTATION_PLAN.md
- No placeholders allowed
- Run type-check after each task

**Phase 2: Verification**
- Type check
- Lint
- Test coverage (configurable threshold)
- Placeholder detection
- Spec compliance

## Configuration

In `.ralph/PROMPT.md` frontmatter:

```yaml
---
iteration_limit: 500      # Max iterations
retry_limit: 5            # Retries before help
coverage_threshold: 80    # Test coverage %
verbosity: normal         # minimal|normal|verbose
placeholder_patterns:
  - "TODO"
  - "FIXME"
  - "unimplemented"
---
```

## Directory Structure

```
.ralph/
├── PROMPT.md              # Loop configuration
├── IMPLEMENTATION_PLAN.md # Task list
├── loop-state.json        # Loop state (ephemeral)
├── verification-report.md # Verification results
├── specs/                 # Specifications
│   └── feature-*.md
└── stdlib/                # Code patterns
    └── *.md
```

### Recommended .gitignore

Add to your project's `.gitignore` to exclude transient state:

```gitignore
# dev-ralph transient files
.ralph/loop-state.json
.ralph/verification-report.md
```

Keep these tracked for planning continuity:
- `.ralph/PROMPT.md`
- `.ralph/IMPLEMENTATION_PLAN.md`
- `.ralph/specs/*.md`
- `.ralph/stdlib/*.md`

## Philosophy

Based on Geoffrey Huntley's Ralph Wiggum technique:

1. **Deterministically bad** - Failures are predictable
2. **One item per loop** - Single task focus
3. **Monolithic** - Single process, scales vertically
4. **Fast iterations** - Speed matters

Our adaptations:
1. **Developer-in-the-loop** - Human guides planning
2. **Two-phase completion** - Verification before exit
3. **Checklist gates** - Required items before transitions

## Anti-Cheating

Verification enforces:
- NO placeholder implementations
- NO TODO/FIXME comments
- NO unimplemented stubs
- FULL implementations only

## Error Handling

- **Type errors**: Fix and retry (up to limit)
- **Stuck**: Pause and ask developer
- **Context overflow**: Auto-summarize
- **Max iterations**: Stop and report

## License

MIT
