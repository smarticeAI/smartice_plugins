# dev-ralph Improvement Notes

Generated: 2026-01-05
Based on: Observation of Ralph loop behavior during PR Review Fixes implementation

**Status: ✅ ALL FIXED** (2026-01-05)

---

## Issue 1: Verification Agent Doesn't Run Tests ✅ FIXED

**Severity:** High
**Component:** `agents/verification-auditor.md`

### Current Behavior
The verification-auditor agent is supposed to run `build_commands` (type_check, lint, test, coverage) but in practice:
- Generates reports without executing actual commands
- Makes assumptions about test results
- Reports incorrect test counts (e.g., claimed 25 tests when 561 exist)

### Expected Behavior
The agent should:
1. Actually run `uv run pytest tests/ -q` (or configured test command)
2. Capture real output and parse results
3. Report actual pass/fail counts
4. Fail verification if tests fail

### Proposed Fix
Add explicit step in agent prompt:

```markdown
## Step 1: Run Tests (MANDATORY)

You MUST run the actual test command and capture output:

```bash
uv run pytest tests/ -q 2>&1
```

Parse the output for:
- Number of tests passed/failed/skipped
- Any error messages

DO NOT assume or generate test results. Only report what the command outputs.
```

---

## Issue 2: Stop Hook Doesn't Show Failure Reason ✅ FIXED

**Severity:** Medium
**Component:** `hooks/stop-hook.sh`

### Current Behavior
When verification fails and returns to implementation (line 154-157):
```bash
SYSTEM_MSG="🔄 dev-ralph: Returning to implementation (iteration $NEXT_ITERATION)

Verification failed. Check .ralph/verification-report.md for issues.
Fix the problems, then output <status>IMPLEMENTATION_COMPLETE</status> when ready to verify again."
```

This message:
- Doesn't include the actual failure reason
- Points to a potentially stale report
- Requires Claude to read the report to understand the issue

### Expected Behavior
The stop hook should:
1. Clear old verification report before verification phase
2. Include a brief summary of why verification failed in the message
3. Or extract key failure points from the report

### Proposed Fix

**Option A: Clear old report when entering verification**
In stop-hook.sh, around line 121-127:
```bash
if [[ "$IMPL_COMPLETE" == "true" ]]; then
    # Clear stale verification report
    rm -f "$RALPH_DIR/verification-report.md"

    # Transition to verification phase
    ...
```

**Option B: Extract failure summary from report**
After verification fails, read the report and extract the "Issues Found" section:
```bash
if [[ -f "$RALPH_DIR/verification-report.md" ]]; then
    ISSUES=$(grep -A10 "## Issues Found" "$RALPH_DIR/verification-report.md" | head -5)
    SYSTEM_MSG="🔄 dev-ralph: Returning to implementation (iteration $NEXT_ITERATION)

Verification failed:
$ISSUES

Fix these issues, then output <status>IMPLEMENTATION_COMPLETE</status>"
fi
```

---

## Issue 3: Stale Verification Report Causes Confusion ✅ FIXED

**Severity:** Medium
**Component:** `hooks/stop-hook.sh`, `agents/verification-auditor.md`

### Current Behavior
1. Verification runs and writes report
2. If verification fails, loop returns to implementation
3. User fixes issues and triggers verification again
4. Old report still exists and may show "VERIFIED COMPLETE" from previous session
5. Confusion about actual verification state

### Expected Behavior
1. Old report should be cleared when entering verification phase
2. Or report should have clear timestamp and iteration number
3. Verification agent should always overwrite, never append

### Proposed Fix

1. **Clear on verification entry** (stop-hook.sh):
```bash
# When transitioning to verification phase
rm -f "$RALPH_DIR/verification-report.md"
```

2. **Include iteration in report** (verification-auditor.md):
```markdown
# Verification Report

Generated: [timestamp]
Iteration: [current iteration number from loop-state.json]
Status: [PASSED | FAILED]
```

---

## Issue 4: Verification Agent Should Use Subagents Consistently ✅ FIXED

**Severity:** Low
**Component:** `agents/verification-auditor.md`

### Current Behavior
The agent prompt says to use Explore subagent for searching, but in practice:
- Runs raw grep/bash commands
- Doesn't leverage subagent capabilities
- Inconsistent with PROMPT.md patterns

### Expected Behavior
- Use Explore subagent for codebase searches (>5 files)
- Use direct tools only for specific known files
- Follow same patterns defined in PROMPT.md

### Proposed Fix
Make subagent usage more explicit and mandatory in the prompt:

```markdown
## Subagent Usage (MANDATORY)

When checking for placeholders across the codebase:
- Use Task tool with subagent_type="Explore"
- DO NOT run `grep -r` directly

Example:
```
Task(
  subagent_type="Explore",
  prompt="Search src/ for TODO, FIXME, NotImplementedError patterns"
)
```
```

---

## Implementation Priority

1. **High**: Issue 1 - Tests must actually run
2. **Medium**: Issue 3 - Clear stale reports
3. **Medium**: Issue 2 - Show failure reason
4. **Low**: Issue 4 - Subagent consistency

---

## Testing Checklist

After implementing fixes:
- [ ] Run a full Ralph loop with failing tests → verify agent detects failures
- [ ] Run a loop where verification fails → verify failure reason is shown
- [ ] Run consecutive loops → verify old reports don't cause confusion
- [ ] Verify subagent usage patterns are followed
