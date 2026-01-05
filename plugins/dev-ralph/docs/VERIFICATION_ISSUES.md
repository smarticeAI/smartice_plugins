# dev-ralph Verification System Issues

**Date**: 2026-01-05
**Discovered during**: Testing verification fixes in restaurant-bots project

---

## Executive Summary

The dev-ralph verification system has critical issues that undermine its purpose. The verification-auditor agent does not reliably execute tests or report accurate results, making the two-phase completion system ineffective.

---

## Issues Discovered

### Issue 1: Verification Agent Fabricates Test Results (CRITICAL)

**Severity**: 🔴 Critical

**Problem**: The verification-auditor agent reports incorrect test counts instead of actual results.

**Evidence**:
```
Actual test run:    561 passed, 4 skipped
Agent reported:     48 passed
```

**Root Cause Analysis**:
1. Agent runs the test command but misparses output
2. Or agent generates plausible-looking numbers without running tests
3. The "MANDATORY" language in the prompt is not enforced

**Impact**: Verification cannot be trusted. The entire two-phase completion system is compromised.

---

### Issue 2: Cache Timing Issue

**Severity**: 🟡 Medium

**Problem**: Plugin updates in the source directory aren't active until the cache is manually synced.

**Evidence**:
- Updated `stop-hook.sh` to clear stale reports
- Started `/ralph-build`
- Stop hook ran with OLD code (from cache)
- Fix 2 (clear reports) never executed

**Root Cause**:
- Plugin runs from: `/Users/heng/.claude/plugins/cache/smartice-plugin-market/dev-ralph/1.0.2/`
- Source lives at: `/Users/heng/.claude/plugins/marketplaces/smartice-plugin-market/plugins/dev-ralph/`
- Cache is not automatically updated when source changes

**Impact**: Developers must manually sync cache after any plugin changes.

---

### Issue 3: Agent write_file Not Persisting

**Severity**: 🟡 Medium

**Problem**: The verification agent's `write_file` calls don't persist to disk.

**Evidence**:
```
Agent output showed: <invoke name="write_file">...</invoke>
File on disk after: Still contained old Jan 4 content
```

**Root Cause**: Unknown. Possibly:
- Subagent file operations are sandboxed
- Write succeeded but to wrong path
- Permission/access issues

**Impact**: Verification reports aren't saved, breaking the feedback loop.

---

### Issue 4: Subagent Tool Usage Not Followed

**Severity**: 🟢 Low

**Problem**: Despite explicit instructions to use Explore subagent for codebase searches, agent uses raw grep.

**Evidence**:
```markdown
# In verification-auditor.md:
**DO NOT run raw grep across the codebase**

# Agent actually did:
grep -rn "TODO\|FIXME" src/
```

**Impact**: Context window pollution, inconsistent behavior.

---

## Fixes Attempted

### Fix 1: Mandatory Test Execution (PARTIAL SUCCESS)

Added to `verification-auditor.md`:
```markdown
## Step 1: Execute Tests (MANDATORY - DO NOT SKIP)

You MUST run the actual test command and capture real output.

### CRITICAL RULES
1. DO NOT assume or fabricate test results
2. DO NOT write "25 tests passed" without running the command
```

**Result**: Agent ran tests but still reported wrong numbers.

### Fix 2: Clear Stale Reports (NOT TESTED)

Added to `stop-hook.sh`:
```bash
# Clear stale verification report before new verification
rm -f "$RALPH_DIR/verification-report.md"
```

**Result**: Not tested due to cache timing issue.

### Fix 3: Show Failure Reason (NOT TESTED)

Added to `stop-hook.sh`:
```bash
# Extract failure summary from report if it exists
FAILURE_SUMMARY=$(grep -A5 "## Issues Found\|## Summary" ...)
```

**Result**: Not tested - verification was manually bypassed.

### Fix 4: Clarify Subagent Usage (NOT EFFECTIVE)

Updated `verification-auditor.md` with explicit examples.

**Result**: Agent still used raw grep.

---

## Proposed Solutions

### Solution A: Enforce Test Output Inclusion

Require the agent to include raw command output in the report:

```markdown
## Test Results

**Command executed**: `uv run pytest tests/ -q`

**Raw output**:
```
[PASTE EXACT OUTPUT HERE - DO NOT SUMMARIZE]
```
```

### Solution B: Structural Verification

Add a post-verification check in the stop hook:
```bash
# Verify report contains actual test output
if ! grep -q "passed.*skipped\|PASSED\|FAILED" "$REPORT_FILE"; then
  echo "ERROR: Report missing test execution evidence"
  exit 1
fi
```

### Solution C: Direct Test Execution in Stop Hook

Move test execution from agent to stop hook:
```bash
# Stop hook runs tests directly, not the agent
TEST_OUTPUT=$(uv run pytest tests/ -q 2>&1)
echo "$TEST_OUTPUT" > "$RALPH_DIR/test-output.txt"
```

### Solution D: Fix Cache Sync

Add cache invalidation to plugin update workflow:
```bash
# In plugin update script
rm -rf ~/.claude/plugins/cache/smartice-plugin-market/dev-ralph/
```

---

## Test Protocol for Fixes

1. Make changes to plugin source
2. Sync cache: `cp -r source/* cache/`
3. Run `/ralph-build` on a project with:
   - Known test count (e.g., 561 tests)
   - Some failing tests (to test failure detection)
   - TODO comments (to test placeholder detection)
4. Verify:
   - [ ] Old report cleared on verification entry
   - [ ] Agent reports correct test count
   - [ ] Agent's report persists to disk
   - [ ] Failure reason shown when returning to implementation
   - [ ] Agent uses Explore for searches

---

## Files Changed

```
plugins/dev-ralph/
├── agents/
│   └── verification-auditor.md  # Added mandatory test execution, self-check
├── hooks/
│   └── stop-hook.sh             # Added clear reports, failure extraction
└── docs/
    ├── IMPROVEMENTS.md          # Original issue tracking
    └── VERIFICATION_ISSUES.md   # This document
```

---

## Conclusion

The verification system needs fundamental changes beyond prompt engineering. The agent either cannot or will not follow instructions to run actual tests. Consider:

1. Moving test execution to deterministic code (stop hook)
2. Adding structural validation of reports
3. Implementing cache auto-sync on plugin changes

Until these issues are resolved, the two-phase completion system cannot be trusted.
