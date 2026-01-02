---
name: ralph-workflow
description: "This skill should be used when the user asks about 'dev-ralph', 'ralph plan', 'ralph build', 'ralph wiggum technique', 'structured development loop', 'two-phase completion', 'implementation loop', or wants to understand how to use the dev-ralph plugin for autonomous development with planning and verification phases."
version: 1.0.0
---

# Ralph Workflow

The dev-ralph plugin implements Geoffrey Huntley's Ralph Wiggum technique with developer-agent collaboration for greenfield projects.

## Core Philosophy

1. **Deterministically bad in an undeterministic world** - Failures are predictable and tunable
2. **One item per loop** - Single task per iteration
3. **Monolithic, not multi-agent** - Single process, scales vertically
4. **Deterministic stack allocation** - Same context loaded every loop
5. **The wheel must turn fast** - Iteration speed matters

## Our Adaptations

1. **Developer-in-the-loop** - Human guides planning, agent executes
2. **Two-phase completion** - Implementation → verification → verified complete
3. **Structured planning** - AskUserQuestion for planning interviews
4. **Checklist gates** - Required items before phase transitions

## Workflow Overview

### Planning Phase (`/ralph-plan`)

1. Conduct structured interview with developer
2. Create specifications in `.ralph/specs/`
3. Create prioritized task list in `.ralph/IMPLEMENTATION_PLAN.md`
4. Create coding patterns in `.ralph/stdlib/` (optional)
5. Create loop configuration in `.ralph/PROMPT.md`

### Checklist Gate

Before implementation can start, ALL must exist:
- At least one spec file in `.ralph/specs/`
- `IMPLEMENTATION_PLAN.md` with prioritized items
- `PROMPT.md` with valid configuration

### Build Phase (`/ralph-build`)

1. Stop hook activates and creates loop
2. Each iteration:
   - Read specs, plan, stdlib
   - Pick most important unfinished task
   - Implement fully (no placeholders!)
   - Run type-check
3. When implementation complete: `<status>IMPLEMENTATION_COMPLETE</status>`
4. Verification phase runs
5. If all checks pass: `<promise>VERIFIED_COMPLETE</promise>`
6. Loop exits

### Two-Phase Completion

**Phase 1: Implementation**
- Work through tasks from IMPLEMENTATION_PLAN.md
- Run type-check after each task
- Output `<status>IMPLEMENTATION_COMPLETE</status>` when done

**Phase 2: Verification**
- Verification subagent audits:
  - Type check passing
  - Lint passing
  - Test coverage meets threshold
  - No placeholder patterns (TODO, FIXME, etc.)
  - All specs addressed
- Write report to `.ralph/verification-report.md`
- If passed: `<promise>VERIFIED_COMPLETE</promise>`
- If failed: Return to Phase 1

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

## Configuration

In `.ralph/PROMPT.md` frontmatter:

```yaml
---
iteration_limit: 500      # Max iterations
retry_limit: 5            # Retries before help
coverage_threshold: 80    # Test coverage %
verbosity: normal         # minimal|normal|verbose
placeholder_patterns:     # Anti-cheat patterns
  - "TODO"
  - "FIXME"
---
```

## Commands

| Command | Purpose |
|---------|---------|
| `/ralph-plan [task]` | Start planning interview |
| `/ralph-build [-v]` | Start implementation loop |
| `/ralph-status` | Show loop status |
| `/ralph-cancel [--checkpoint]` | Cancel loop |
| `/ralph-help` | Show help |

## Anti-Cheating Rules

The verification phase enforces:
- NO placeholder implementations
- NO TODO/FIXME comments in new code
- NO unimplemented stubs
- FULL implementations only

## Error Handling

- **Type errors**: Fix and retry (up to retry limit)
- **Stuck after retries**: Pause and ask developer
- **Context overflow**: Auto-summarize and continue
- **Max iterations**: Stop and report

## References

See `references/planning-protocol.md` for interview structure.
See `references/anti-patterns.md` for placeholder detection patterns.
