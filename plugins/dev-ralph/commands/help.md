---
description: "Show help and documentation for dev-ralph plugin"
allowed-tools: ["Read"]
---

# dev-ralph Help

Display comprehensive help for the dev-ralph plugin.

## Overview

dev-ralph implements Geoffrey Huntley's Ralph Wiggum technique with developer-agent collaboration. It provides:

- **Structured Planning**: Interactive interview to create specs and implementation plans
- **Autonomous Implementation**: Loop-based development with quality gates
- **Two-Phase Completion**: Implementation → Verification → Verified Complete
- **Quality Assurance**: Coverage checks, placeholder detection, spec compliance

## Commands

### /ralph-plan [task-description]

Start the planning phase with a structured interview.

```
/ralph-plan "Build a kanban board with drag-drop"
```

This will:
1. Create `.ralph/` directory structure
2. Conduct structured interview (AskUserQuestion)
3. Create specification files in `.ralph/specs/`
4. Create prioritized task list in `.ralph/IMPLEMENTATION_PLAN.md`
5. Optionally create coding patterns in `.ralph/stdlib/`
6. Create `.ralph/PROMPT.md` with loop configuration

### /ralph-build [-v|--verbose] [--dry-run]

Start the implementation loop.

```
/ralph-build
/ralph-build -v           # Verbose output
/ralph-build --dry-run    # Show what would happen
```

Requirements (Checklist Gate):
- At least one spec file in `.ralph/specs/`
- `IMPLEMENTATION_PLAN.md` with items
- `PROMPT.md` with valid configuration

The loop continues until:
- `<promise>VERIFIED_COMPLETE</promise>` is output
- Iteration limit is reached (default: 500)
- `/ralph-cancel` is executed

### /ralph-status

Show current loop status.

```
/ralph-status
```

Displays:
- Current phase (implementation/verification)
- Iteration count
- Plan progress
- Recent activity
- Verification status

### /ralph-cancel [--checkpoint]

Cancel the active loop.

```
/ralph-cancel              # Cancel immediately
/ralph-cancel --checkpoint # Git commit before canceling
```

## Two-Phase Completion

### Phase 1: Implementation

1. Pick task from IMPLEMENTATION_PLAN.md
2. Implement fully (no placeholders!)
3. Run type-check
4. If passing, output: `<status>IMPLEMENTATION_COMPLETE</status>`

### Phase 2: Verification

1. Stop hook detects IMPLEMENTATION_COMPLETE
2. Verification subagent runs:
   - Type check
   - Lint
   - Test coverage (threshold from config)
   - Placeholder pattern grep
   - Spec compliance check
3. Writes `.ralph/verification-report.md`
4. If ALL pass: output `<promise>VERIFIED_COMPLETE</promise>`
5. If ANY fail: return to Phase 1 to fix

## Configuration

Configure in `.ralph/PROMPT.md` frontmatter:

```yaml
---
iteration_limit: 500      # Max iterations
retry_limit: 5            # Retries before asking for help
coverage_threshold: 80    # Test coverage percentage
verbosity: normal         # minimal | normal | verbose
placeholder_patterns:     # Patterns to detect (anti-cheat)
  - "TODO"
  - "FIXME"
  - "unimplemented"
  - "NotImplementedError"
---
```

## Directory Structure

```
.ralph/
├── PROMPT.md              # Loop configuration and instructions
├── IMPLEMENTATION_PLAN.md # Prioritized task list
├── loop-state.json        # Current loop state (ephemeral)
├── verification-report.md # Latest verification results
├── specs/                 # Specification files
│   ├── feature-auth.md
│   └── feature-chat.md
└── stdlib/                # Code patterns for Claude to follow
    ├── error-handling.md
    └── api-patterns.md
```

## Philosophy

Based on Geoffrey Huntley's Ralph Wiggum technique:

1. **Deterministically bad in an undeterministic world** - Failures are predictable
2. **One item per loop** - Single task per iteration
3. **Monolithic, not multi-agent** - Single process, scales vertically
4. **The wheel must turn fast** - Iteration speed matters

Our adaptations:
1. **Developer-in-the-loop** - Human guides planning
2. **Two-phase completion** - Verification before exit
3. **Structured planning** - AskUserQuestion interviews
4. **Checklist gates** - Required items before transitions

## Tips

- Keep specs focused (one concern per file)
- Keep implementation plan items small
- Add patterns to stdlib when Claude makes mistakes
- Use `/ralph-status` to monitor progress
- Use `--checkpoint` with cancel to save work
- All state in `.ralph/` is git-trackable
