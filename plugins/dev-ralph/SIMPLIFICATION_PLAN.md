# dev-ralph Simplification Plan

## Pre-Implementation Steps

1. Create new branch: `git checkout -b simplify-ralph-loop`
2. Copy this plan to project folder: `cp ~/.claude/plans/delightful-wibbling-pnueli.md ./SIMPLIFICATION_PLAN.md`

## Problem Statement

The current dev-ralph implementation has become overengineered with multiple decision-making agents (verification-auditor, learning-agent) that:
1. Break the loop flow (each agent call ends Claude's turn)
2. Pollute main context with agent outputs
3. Add complexity without matching Huntley's original vision

## Huntley's Actual Vision (from PDF + implementations)

### Core Principles
1. **Monolithic loop** - Single process, one item per loop
2. **Scheduler pattern** - Main context schedules work, doesn't do expensive work
3. **Subagents for work** - Search (parallel), write (parallel), NOT for decisions
4. **Single backpressure point** - Build/test must run in ONE place for coherent feedback
5. **Files are state** - specs/, fix_plan.md, AGENTS.md persist between iterations
6. **Append-only learnings** - progress.txt / lessons-learned.md

### What Subagents Are FOR
- Searching filesystem (many, parallel, Haiku)
- Writing files (many, parallel, Haiku)
- Summarizing expensive outputs (single)

### What Subagents Are NOT FOR
- Making pass/fail decisions
- Running build/test (must be single point)
- Complex orchestration

## Proposed Architecture

```
Main Claude (orchestrator/scheduler):
├── READ: specs/, IMPLEMENTATION_PLAN.md, Signs, lessons-learned.md
├── DECIDE: which item to implement next
├── DELEGATE: spawn Haiku subagents for search/write
├── BACKPRESSURE: run type-check, tests INLINE (single point)
├── EVALUATE: did it work? (decision stays with Main)
├── UPDATE: mark item done, append to lessons-learned.md
├── LOOP: stop hook feeds PROMPT.md back
└── EXIT: <promise>VERIFIED_COMPLETE</promise> when all done
```

## Implementation Changes

### Files to KEEP (simplified)
- `.ralph/PROMPT.md` - Loop prompt (fed back each iteration)
- `.ralph/specs/*.md` - Specifications (source of truth)
- `.ralph/IMPLEMENTATION_PLAN.md` - Simplify to passes: true/false per item
- `.ralph/lessons-learned.md` - Append-only learnings
- `.ralph/Signs.md` - Tuning instructions (Huntley's "signs")

### Files to REMOVE
- `.ralph/loop-state.json` - Merge into PROMPT.md frontmatter
- `.ralph/verification-report.md` - No longer needed (inline backpressure)

### Agents to REMOVE
- `agents/verification-auditor.md` - DELETE (Main Claude self-verifies via tests)
- `agents/learning-agent.md` - DELETE (Main Claude updates lessons inline)
- `agents/test-verifier.md` - DELETE
- `agents/placeholder-scanner.md` - DELETE
- `agents/integration-checker.md` - DELETE
- `agents/plan-updater.md` - DELETE
- `agents/pattern-detector.md` - DELETE
- `agents/lessons-tracker.md` - DELETE
- `agents/spec-evolver.md` - DELETE

### Agent to KEEP (simplified)
- `agents/codebase-explorer.md` - KEEP (Haiku, for search - matches Huntley's "subagents for searching")

### Agent to ADD (optional)
- `agents/item-executor.md` - NEW (Haiku, for implementing a single item)
  - Main Claude spawns this with spec + item
  - Executor searches, writes code, runs type-check
  - Returns summary only (keeps main context clean)
  - Main Claude evaluates result

### Hooks to SIMPLIFY
- `hooks/stop-hook.sh` - Simplify to match official ralph-loop:
  1. Check for `<promise>VERIFIED_COMPLETE</promise>` → allow exit
  2. Check max iterations → allow exit
  3. Otherwise → block, feed PROMPT.md back, increment iteration

Remove:
- Per-item `<item>COMPLETE</item>` detection
- Agent triggering logic
- Complex state management

## New Loop Flow

```
1. User runs /ralph-build
2. Stop hook activates
3. Main Claude reads PROMPT.md, specs/, IMPLEMENTATION_PLAN.md
4. Main Claude picks next incomplete item
5. Main Claude spawns Haiku executor with item spec
   OR implements inline (user's choice)
6. Main Claude runs type-check, tests (INLINE - single backpressure point)
7. If passes:
   - Mark item as complete in IMPLEMENTATION_PLAN.md
   - Append learnings to lessons-learned.md
   - Continue to next item
8. If fails:
   - Fix errors
   - Retry
9. When all items done:
   - Output <promise>VERIFIED_COMPLETE</promise>
10. Stop hook allows exit
```

## IMPLEMENTATION_PLAN.md Format (Simplified)

```markdown
# Implementation Plan

## Items

- [x] Set up project structure
- [ ] Implement user authentication
- [ ] Add API endpoints
- [ ] Write tests

## Learnings

(Append-only section - Main Claude adds discoveries here)
```

OR use JSON like snarktank/ralph:

```json
{
  "items": [
    {"id": "1", "title": "Set up project structure", "passes": true},
    {"id": "2", "title": "Implement user authentication", "passes": false}
  ]
}
```

## Verification Strategy

**Instead of verification-auditor agent:**
1. Type-check must pass (fast backpressure)
2. Tests must pass (correctness backpressure)
3. Main Claude self-evaluates against spec
4. Optional: final manual review before VERIFIED_COMPLETE

**Why this works:**
- Huntley: "only a single subagent should be used for validation"
- Build/test IS the validation (single point)
- Main Claude has judgment to know when spec is satisfied

## Migration Path

### Phase 1: Remove complexity
1. Delete all agents except codebase-explorer
2. Simplify stop-hook.sh to basic loop logic
3. Remove per-item agent triggers

### Phase 2: Simplify state
1. Merge loop-state.json into PROMPT.md frontmatter
2. Simplify IMPLEMENTATION_PLAN.md format
3. Keep lessons-learned.md as append-only

### Phase 3: Add optional executor (if needed)
1. Create simple item-executor agent (Haiku)
2. Main Claude can choose to delegate or implement inline
3. Executor returns summary, not full implementation details

## Testing the Changes

1. Sync simplified plugin to cache:
   ```bash
   cp -r . ~/.claude/plugins/cache/smartice-plugin-market/dev-ralph/1.2.0/
   ```

2. Test with simple task:
   ```
   /ralph-plan "Add a hello world function"
   /ralph-build
   ```

3. Verify:
   - Loop continues without agent overhead
   - Type-check runs inline
   - Items marked complete correctly
   - Lessons appended
   - Loop exits on VERIFIED_COMPLETE

## Success Criteria

1. **Faster iterations** - No agent call overhead between items
2. **Cleaner context** - Implementation details stay in executor (if used)
3. **Simpler state** - Fewer files, easier to debug
4. **Matches Huntley** - Scheduler pattern, subagents for work, single backpressure

## Files to Modify

| File | Action | Description |
|------|--------|-------------|
| `agents/*.md` | DELETE | Remove all except codebase-explorer |
| `agents/item-executor.md` | CREATE | Optional Haiku executor |
| `hooks/stop-hook.sh` | SIMPLIFY | Basic loop logic only |
| `hooks/hooks.json` | UPDATE | Remove complex triggers |
| `commands/ralph-build.md` | UPDATE | Simplified instructions |
| `templates/PROMPT.md.template` | UPDATE | Include iteration in frontmatter |
| `scripts/setup-ralph-build.sh` | SIMPLIFY | Less state initialization |
