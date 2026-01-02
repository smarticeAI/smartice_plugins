---
description: "Show current Ralph loop status including phase, iteration, and progress"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/check-status.sh)", "Read"]
---

# Ralph Status

Display the current status of the Ralph implementation loop.

## Status Protocol

Run the status check script:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/check-status.sh
```

The script will output formatted status information. If no loop is active, it will report that.

## Expected Output Format

```
Ralph Loop Status
═════════════════

Phase: [Implementation | Verification]
Iteration: [N] / [max] (limit)
Retries: [N] / [limit]

Current Task: [task description]

Plan Progress: [completed]/[total] items
├── [x] [Completed task 1] (iteration N)
├── [x] [Completed task 2] (iteration N)
├── [ ] [Current task] (in progress)
├── [ ] [Pending task 1]
└── [ ] [Pending task 2]

Configuration:
  Coverage threshold: [N]%
  Verbosity: [level]

Verification Status: [Not triggered | In progress | Passed | Failed]

Last Activity: [timestamp]
```

## If No Loop Active

```
Ralph Loop Status
═════════════════

Status: No active loop

To start a new loop:
  1. Run /ralph-plan to create specs and plan
  2. Run /ralph-build to start implementation

Or if .ralph/ exists:
  Run /ralph-build to resume
```

## Additional Information

If you need more details, you can read these files directly:
- `.ralph/loop-state.json` - Current loop state
- `.ralph/IMPLEMENTATION_PLAN.md` - Task list with completion status
- `.ralph/verification-report.md` - Latest verification results (if exists)
