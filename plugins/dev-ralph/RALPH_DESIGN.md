# Ralph Loop Design: Self-Critical Verification

A design document for improving the Ralph Wiggum loop with quality-focused completion verification.

---

## Problem Statement

Current Ralph loop behavior:
```
Claude writes tests → Tests pass → Claude outputs promise → Loop exits
```

The issue: Claude may output the completion promise **too quickly**, without genuinely verifying that the work meets quality standards. The promise becomes an escape mechanism rather than a quality gate.

---

## Design Goal

Transform the completion promise from a **checkbox** into a **quality gate**:

| Current Mindset | Desired Mindset |
|-----------------|-----------------|
| "Tests pass, I'm done" | "Tests pass, but is this actually good?" |
| Output promise ASAP | Reflect, improve, THEN output |
| Escape-focused | Quality-focused |

---

## Proposed: Reflection Phase

Before outputting the completion promise, Claude should enter a **mandatory reflection phase**:

```
┌─────────────────────────────────────────────────────────────────┐
│                     REFLECTION PHASE                             │
│                                                                  │
│  1. RE-READ: Review all tests written                           │
│     └── What behaviors are tested?                              │
│     └── What edge cases are covered?                            │
│                                                                  │
│  2. SELF-CRITIQUE: What's missing?                              │
│     └── Error handling?                                         │
│     └── Boundary conditions?                                    │
│     └── Integration points?                                     │
│     └── Accessibility?                                          │
│                                                                  │
│  3. COVERAGE CHECK: Is it sufficient?                           │
│     └── Run coverage tool if available                          │
│     └── Target: >80% on new code                                │
│     └── If under target → write more tests                      │
│                                                                  │
│  4. DECISION:                                                   │
│     └── Gaps found? → Fix them, restart verification            │
│     └── Truly complete? → Output promise                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation Options

### Option A: Prompt-Based Reflection

Add reflection requirements to the prompt:

```markdown
## Completion Protocol

Before outputting <promise>DONE</promise>, you MUST complete these steps:

### Step 1: Test Inventory
List all tests you wrote and what they verify:
- [ ] Test 1: [what it tests]
- [ ] Test 2: [what it tests]
- ...

### Step 2: Gap Analysis
Answer these questions honestly:
- What edge cases are NOT tested?
- What error scenarios are NOT handled?
- What integration points are NOT verified?

### Step 3: Coverage Assessment
- Run: `bun run test:coverage -- --reporter=text-summary`
- New files should have >80% coverage
- If under target, write more tests

### Step 4: Decision
- If gaps found in Steps 2-3 → address them first
- If genuinely complete → output promise

IMPORTANT: The loop gives you unlimited iterations. Use them wisely.
Do not rush to completion. Quality over speed.
```

### Option B: Structured Verification Output

Require Claude to output a verification report before the promise:

```markdown
## Verification Report Format

Before the promise, output this report:

---
## Verification Report

### Tests Written
| Test | What It Verifies |
|------|------------------|
| ... | ... |

### Edge Cases Covered
- [x] Empty input
- [x] Invalid input
- [ ] Concurrent access (not applicable)

### Edge Cases NOT Covered (and why)
- Network failures: Mocked in tests, not relevant for unit tests

### Coverage
- New files: 87% (target: 80%) ✓
- Lines: 234/268 covered

### Self-Assessment
All acceptance criteria met. Edge cases appropriate for scope.

---
<promise>DONE</promise>
```

### Option C: Two-Phase Completion

Split completion into two stages:

```markdown
## Two-Phase Completion

### Phase 1: Implementation Complete
When implementation is done, output:
<status>IMPLEMENTATION_COMPLETE</status>

This triggers a verification iteration where you:
1. Re-read all code and tests
2. Run coverage analysis
3. Identify gaps
4. Fix any issues found

### Phase 2: Verification Complete
Only after verification passes, output:
<promise>VERIFIED_COMPLETE</promise>

The hook only accepts Phase 2 promise after Phase 1 was seen.
```

### Option D: Coverage-Gated Promise

Make the hook itself verify coverage:

```markdown
## Hook-Verified Completion

The stop hook will:
1. Detect <promise>DONE</promise> in output
2. Run `bun run test:coverage --json`
3. Parse coverage for new/modified files
4. If coverage < 80% → BLOCK exit, feed back coverage report
5. If coverage >= 80% → ALLOW exit

This makes coverage a hard gate, not just a suggestion.
```

---

## Comparison

| Option | Pros | Cons |
|--------|------|------|
| A: Prompt-Based | Simple, no code changes | Claude can skip/fake it |
| B: Structured Report | Auditable, transparent | Verbose, Claude can still fake |
| C: Two-Phase | Forces reflection iteration | More complex prompt |
| D: Hook-Verified | Hard gate, can't fake | Requires hook modification |

---

## Recommended Approach

**Start with Option A + B combined**, then iterate:

1. **Prompt requires reflection** (Option A)
2. **Prompt requires verification report** (Option B)
3. **Transcript is auditable** - we can review if Claude actually reflected
4. **Iterate based on results** - if Claude still escapes too quickly, move to Option C or D

---

## Open Questions

1. **What coverage threshold is reasonable?**
   - 80% is industry standard, but may be too rigid for some tasks
   - Should it be configurable per task?

2. **How to handle non-test tasks?**
   - Refactoring, documentation, bug fixes have different completion criteria
   - Need task-type-specific verification protocols

3. **How to prevent fake reflection?**
   - Claude could output a report without actually thinking
   - Option D (hook-verified) solves this but adds complexity

4. **Should reflection be a separate iteration?**
   - Option C forces a dedicated verification iteration
   - More thorough but doubles minimum iterations

5. **How to measure reflection quality?**
   - Can we detect genuine vs. superficial reflection?
   - Metrics: time spent, tests added after reflection, coverage improvement

---

## Next Steps

- [ ] Test Option A+B on next TDD task
- [ ] Measure: Does Claude add tests during reflection?
- [ ] Measure: Coverage before vs. after reflection
- [ ] Iterate on prompt based on results
- [ ] Consider Option D if prompt-based approaches fail

---

*Created: 2026-01-02*
*Status: Draft - Needs Testing*
