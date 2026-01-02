---
description: "Start Ralph implementation loop with two-phase completion and verification"
argument-hint: "[-v|--verbose] [--dry-run]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-build.sh *)", "Read"]
---

# Ralph Build Phase

You are starting the Ralph implementation loop. This will activate the Stop hook to create a continuous loop until all work is verified complete.

## Arguments

Options provided: $ARGUMENTS

- `-v` or `--verbose`: Show detailed progress
- `--dry-run`: Show what would happen without starting the loop

## Build Protocol

### Step 1: Validate Checklist Gate

Run the setup script to validate and initialize:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-build.sh $ARGUMENTS
```

The script will:
1. Check that `.ralph/specs/*.md` exists (at least one)
2. Check that `.ralph/IMPLEMENTATION_PLAN.md` exists with items
3. Check that `.ralph/PROMPT.md` exists with valid frontmatter
4. Create `.ralph/loop-state.json` with initial state
5. Output the initial prompt

If validation fails, the script will report what's missing and exit.

### Step 2: Display Loop Start

If validation passes, display:

```
🚀 dev-ralph: Starting implementation loop
═══════════════════════════════════════════

Configuration (from PROMPT.md):
  Iteration limit: [N]
  Retry limit: [N]
  Coverage threshold: [N]%
  Verbosity: [level]

Plan: [N] items to implement
Specs: [N] specifications loaded

The Stop hook is now active. The loop will continue until:
  • <promise>VERIFIED_COMPLETE</promise> is output
  • Iteration limit is reached
  • /ralph-cancel is executed

Starting iteration 1...
```

### Step 3: Begin Implementation

After displaying the start message, the PROMPT.md content will be fed to Claude by the Stop hook. Follow the instructions in PROMPT.md:

1. Read specs/* to understand requirements
2. Read IMPLEMENTATION_PLAN.md for priorities
3. Read stdlib/* for coding patterns
4. Pick the most important unfinished item
5. Implement it fully (no placeholders!)
6. Run type-check when done
7. If passing, output `<status>IMPLEMENTATION_COMPLETE</status>`

## Two-Phase Completion

### Phase 1: Implementation
- Work on tasks from IMPLEMENTATION_PLAN.md
- Run backpressure (type-check) after each task
- When implementation is complete, output: `<status>IMPLEMENTATION_COMPLETE</status>`

### Phase 2: Verification
- The Stop hook detects IMPLEMENTATION_COMPLETE
- Run the verification-auditor agent
- Check: coverage, lint, no placeholders, all specs addressed
- Write report to `.ralph/verification-report.md`
- If ALL checks pass: output `<promise>VERIFIED_COMPLETE</promise>`
- If ANY check fails: fix issues and try again

## Error Handling

- If type-check fails: fix errors (up to retry limit)
- If stuck after 5 retries: pause and ask developer for help
- If context overflows: auto-summarize and continue
- Maximum 500 iterations (configurable)

## Anti-Cheating Rules

These are critical - violations will cause verification to fail:

1. NO placeholder implementations
2. NO TODO comments in new code
3. NO unimplemented stubs
4. FULL implementations only

## Important Notes

- The loop runs until VERIFIED_COMPLETE or limits reached
- Use `/ralph-status` to check progress
- Use `/ralph-cancel` to stop the loop
- All state is in `.ralph/` directory (git-trackable)
