# Analysis: Ryan Carson's Workflow vs Ralph Wiggum vs dev-ralph

## Overview of Approaches

### 1. Ryan Carson's 3-Step Workflow
**Source**: [Lenny's Newsletter](https://www.lennysnewsletter.com/p/a-3-step-ai-coding-workflow-for-solo)

| Component | Description |
|-----------|-------------|
| **PRD** | AI-generated product requirements document |
| **Task List** | Granular, executable tasks with dependencies |
| **Implementation** | Sequential execution in Cursor |

**Core Principle**: "Slowing down to provide proper context is the secret to speeding up."

**Tools**: Cursor, MCPs (Browserbase, Stagehand, Repo Prompt)

---

### 2. Geoffrey Huntley's Ralph Wiggum
**Source**: [HumanLayer Blog](https://www.humanlayer.dev/blog/brief-history-of-ralph)

```bash
while :; do cat PROMPT.md | npx --yes @sourcegraph/amp ; done
```

| Principle | Description |
|-----------|-------------|
| **Declarative specs** | Describe outcomes, not steps |
| **Infinite loop** | Agent keeps iterating until task complete |
| **Context window engineering** | Carve work into independent windows |
| **Code is disposable** | Regenerate vs merge conflicts |

**Notable Result**: 3-month loop built a complete programming language.

---

### 3. Our dev-ralph Implementation
**Source**: `DEV_RALPH_SPEC.md`

| Feature | Description |
|---------|-------------|
| **Two-phase completion** | Implementation → Verification → Verified |
| **Structured planning** | AskUserQuestion interview before build |
| **Checklist gates** | Must have specs + plan before implementation |
| **Verification auditor** | Independent subagent audit |
| **Stop hook** | Blocks exit until `<promise>VERIFIED_COMPLETE</promise>` |

---

## Comparative Analysis

### Philosophy Spectrum

```
Manual Control ←————————————————————————→ Full Autonomy

Ryan Carson         dev-ralph           Ralph Wiggum
(structured,        (hybrid,            (minimal structure,
 deliberate)         gated)              maximum autonomy)
```

### Key Differences

| Dimension | Carson | Huntley | dev-ralph |
|-----------|--------|---------|-----------|
| **Human involvement** | High (each step) | Low (launch & monitor) | Medium (planning, gates) |
| **Structure** | PRD → Tasks → Code | PROMPT.md loop | Specs → Plan → Build → Verify |
| **Verification** | Manual review | Emergent (overbaking risk) | Explicit verification phase |
| **Failure handling** | Human intervenes | Keep looping | Retry limits + escalation |
| **Context strategy** | Fresh per task | Same prompt, changed code | File-mediated results |
| **Termination** | Human decides | Manual stop | Promise-based exit |

---

## Strengths & Weaknesses

### Ryan Carson's Approach
**Strengths**:
- Maximum control and predictability
- Clear documentation trail (PRD)
- Works well with Cursor's UI

**Weaknesses**:
- High human overhead
- Doesn't leverage overnight/background runs
- Manual context management

---

### Huntley's Ralph Wiggum
**Strengths**:
- Elegantly simple (one bash line)
- True autonomous night shifts
- Context window engineering insight
- Proven on massive tasks

**Weaknesses**:
- "Overbaking" risk (post-quantum crypto anyone?)
- No quality gates (loop until manual stop)
- Bad specs → bad results (garbage in, garbage out)
- No structured planning phase

---

### dev-ralph
**Strengths**:
- Two-phase completion prevents shipping broken code
- Verification auditor catches placeholders/TODOs
- Structured planning interview reduces spec ambiguity
- Checklist gates prevent premature build
- Retry limits + escalation prevent infinite loops

**Weaknesses**:
- More complex than vanilla Ralph
- Planning phase adds overhead for simple tasks
- Potentially over-engineered for small projects
- Less "set and forget" than pure Ralph

---

## What dev-ralph Gets Right

1. **Two-phase completion** - Huntley's loop has no quality gate. dev-ralph's IMPLEMENTATION_COMPLETE → verification → VERIFIED_COMPLETE ensures the agent doesn't just claim "done" without proof.

2. **Verification auditor** - Independent subagent checks for:
   - Test coverage
   - No placeholder patterns (TODO, FIXME, unimplemented)
   - All specs addressed

   This catches the "overbaking" problem where the loop keeps running without meaningful progress.

3. **Structured planning** - Carson's PRD approach is valuable but manual. dev-ralph automates this with AskUserQuestion interviews while maintaining human approval.

4. **Checklist gates** - Prevents the "bad specs → bad results" problem by requiring:
   - Specs exist
   - Implementation plan exists
   - Developer explicitly approved

5. **Retry limits + escalation** - Unlike pure Ralph (loop forever), dev-ralph pauses and asks for help after 5 retries. This respects the human's time.

---

## What dev-ralph Could Learn

1. **Simplicity** - Huntley's one-liner is beautiful. dev-ralph has more moving parts. Consider a "lite" mode for simple tasks.

2. **Context window engineering** - The insight that "same prompt, changed code = learning" is powerful. We use file-mediated results, but could lean more into this.

3. **Disposable code mentality** - "Regenerate vs merge conflicts" is wise. We could add automatic checkpointing and easier rollback.

4. **Carson's PRD discipline** - The explicit PRD step forces thinking before doing. Our specs serve this purpose but could be more structured.

---

## Synthesis: Best of All Worlds

The ideal workflow might combine:

| From | Take |
|------|------|
| **Carson** | Explicit PRD/context discipline |
| **Huntley** | Autonomous loop, declarative specs |
| **dev-ralph** | Two-phase completion, verification |

### Proposed Evolution for dev-ralph v2

1. **Lightweight mode** - Skip planning for small tasks (auto-detect complexity)
2. **Better spec templates** - More structured like Carson's PRDs
3. **Checkpoint-on-verify** - Git commit after each VERIFIED_COMPLETE
4. **Overbaking detection** - Alert if loop runs N iterations without progress

---

## Conclusion

dev-ralph occupies a thoughtful middle ground:
- More structured than vanilla Ralph Wiggum (prevents overbaking)
- More autonomous than Carson's manual workflow (enables night shifts)
- The two-phase completion is a genuine innovation

The verification auditor is the key differentiator - it adds the quality gate that pure Ralph lacks, without requiring human-in-the-loop for every iteration.

**The core insight**: Ralph Wiggum proves loops work. dev-ralph proves loops work *better* with verification gates.

---

---

## Deep Dive: The Learning Gap

### The Problem You Identified

> "Our ralph does not learn from what he did and does not update his plan very effectively. Carson has a document to update learnings and do compound learning."

This is **the fundamental difference** between these approaches. Let me break it down.

---

### How Each System "Learns"

#### Carson's Compound Learning

```
Iteration 1: PRD v1 → Tasks v1 → Work → Update PRD with learnings
Iteration 2: PRD v2 → Tasks v2 → Work → Update PRD with learnings
Iteration N: PRD vN → Tasks vN → Work → (context compounds!)
```

**Key mechanism**: The PRD is a **living document** that accumulates context. Each iteration adds:
- What worked
- What didn't
- Discovered requirements
- Pattern decisions

The system gets **smarter** because context grows.

---

#### Huntley's Implicit Learning

```
Loop 1: PROMPT.md + codebase v1 → Work → codebase v2
Loop 2: PROMPT.md + codebase v2 → Work → codebase v3
Loop N: PROMPT.md + codebase vN → Work → (code IS the memory)
```

**Key insight**: "The prompt doesn't change, but the codebase does."

Learning is **embedded in files**:
- Previous implementations inform new ones
- Test failures from last iteration still exist
- The codebase IS the learning document

---

#### dev-ralph's Current State

```
Loop 1: PROMPT.md + plan v1 → Work → verify → tick checkboxes
Loop 2: PROMPT.md + plan v2 → Work → verify → tick checkboxes
                ↑                            ↑
            (static)               (transient report)
```

**What we do:**
- verification-report.md captures findings
- IMPLEMENTATION_PLAN.md gets checkboxes ticked
- `[FOUND]` items added for discovered issues

**What we DON'T do:**
- PROMPT.md never evolves
- stdlib/* is manually populated (not auto-learned)
- verification-report.md is overwritten each loop (findings don't compound)
- No "lessons learned" accumulator across iterations

---

### The Missing Compound Learning Loop

#### Carson's Secret Sauce

Carson explicitly says: *"Structure beats vibe coding."* His structure includes:

1. **PRD as memory** - It's not just requirements, it's accumulated context
2. **Task list reflects reality** - Updated with blockers, dependencies discovered
3. **Context is currency** - More context = better AI decisions

#### What We're Missing

| Component | Carson Has | dev-ralph Has | Gap |
|-----------|-----------|---------------|-----|
| Living spec | PRD updated each iteration | specs/* static after planning | Specs don't evolve |
| Lessons log | Accumulated in PRD | None | No persistent learnings |
| Pattern library | Implicit in PRD | stdlib/* (manual) | No auto-learning |
| Context growth | Compounds over time | Resets each loop | Memory loss |

---

### Specific Gaps in dev-ralph

#### 1. PROMPT.md is Static

```yaml
# Current: Same prompt every iteration
---
iteration_limit: 500
coverage_threshold: 80
---
# PROMPT.md
Pick the most important unfinished item...
```

**Problem**: The prompt never learns from past iterations.

**Carson would**: Update the PRD with learnings after each task.

**Proposed fix**: Add a "learned patterns" section that verification-auditor can append to:

```yaml
---
learned_patterns:
  - "API routes need explicit error boundaries (discovered iteration 12)"
  - "Auth middleware must be registered before routes (discovered iteration 8)"
---
```

---

#### 2. stdlib/* is Manual

From DEV_RALPH_SPEC.md:
> "Start empty, populate iteratively:
> 1. Manual: Developer adds patterns when Claude makes mistakes
> 2. Agentic: During planning, agent proposes patterns"

**Problem**: Only populates during planning, not during build loops.

**Carson would**: Add pattern to PRD when discovered during implementation.

**Proposed fix**: Verification auditor should propose stdlib additions:

```markdown
## Proposed Pattern (for developer approval)

During implementation, repeated errors with API error handling.
Propose adding to `.ralph/stdlib/api-errors.md`:

```typescript
// Discovered pattern: Always use typed errors
```

Add to stdlib? [y/n]
```

---

#### 3. verification-report.md is Transient

```bash
# Current: Each verification OVERWRITES the report
rm -f "$RALPH_DIR/verification-report.md"  # from stop-hook.sh
```

**Problem**: Findings from iteration 5 are gone by iteration 10. No memory of past failures.

**Carson would**: Append findings to a running log.

**Proposed fix**: Keep a `verification-history.md` that appends:

```markdown
## Iteration 23 (2026-01-08 14:32)
- FAILED: Missing test for edge case X
- FOUND: Unregistered router Y

## Iteration 22 (2026-01-08 14:15)
- PASSED: All checks green
```

---

#### 4. Plan Updates Are Local, Not Strategic

The verification-auditor does:
```markdown
- [ ] [FOUND] Register AuthService in app.py
```

But it doesn't:
- Synthesize patterns across failures
- Suggest architectural changes
- Update specs based on discovered requirements

**Carson would**: Update PRD with "We discovered auth needs middleware, updating requirements."

**Proposed fix**: Add a "discovery" phase after verification:

```markdown
## Discoveries This Session

### New Requirements (add to specs?)
- Auth needs middleware layer (not in original spec)
- API routes need rate limiting

### Pattern Proposals (add to stdlib?)
- Error boundary pattern repeated 3 times
- Auth check pattern used in 5 routes
```

---

### The Compound Learning Model We Need

```
                    ┌─────────────────────────────────────┐
                    │          COMPOUND LEARNING          │
                    │  (Carson's key insight)             │
                    └─────────────────────────────────────┘
                                    │
         ┌──────────────────────────┼──────────────────────────┐
         ▼                          ▼                          ▼
   ┌───────────┐            ┌───────────┐             ┌───────────┐
   │  LESSONS  │            │  PATTERNS │             │  HISTORY  │
   │  LEARNED  │            │  (stdlib) │             │   LOG     │
   └───────────┘            └───────────┘             └───────────┘
         │                          │                          │
         │ What we                  │ How to do it             │ What we
         │ discovered               │ right next time          │ tried before
         │                          │                          │
         └──────────────────────────┼──────────────────────────┘
                                    ▼
                          ┌──────────────────┐
                          │    NEXT LOOP     │
                          │ (richer context) │
                          └──────────────────┘
```

---

### Proposed dev-ralph v2 Learning Mechanisms

#### 1. Add `lessons-learned.md`

A running log that survives across iterations:

```markdown
# Lessons Learned

## Session: 2026-01-08

### Discovered Requirements
- Auth middleware needed before routes (iteration 12)
- Rate limiting required for public endpoints (iteration 15)

### Error Patterns
- Forgot to register router 3 times (→ added to stdlib)
- Type errors with optional fields 5 times (→ added pattern)

### What Worked
- TDD approach reduced rework
- Starting with stdlib accelerated features
```

#### 2. Auto-Populate stdlib

When verification fails with a pattern > 2 times:

```bash
# Pseudo-logic in verification-auditor
if pattern_failure_count > 2:
    propose_stdlib_pattern()
    # "This error occurred 3 times. Propose adding pattern to stdlib?"
```

#### 3. Evolving PROMPT.md

Add a dynamic section that grows:

```yaml
---
# Static config
iteration_limit: 500

# Dynamic learnings (auto-updated by verification-auditor)
session_learnings:
  - "Always register routes in main.ts after creating them"
  - "Auth middleware must be first in the chain"
---
```

#### 4. Plan Auto-Update with Strategic Synthesis

Not just `[FOUND]` items, but synthesis:

```markdown
## Strategic Notes (auto-generated)

After 15 iterations, patterns observed:
- Auth-related tasks take 3x longer than estimated
- Route registration is the #1 failure point
- Consider: Add pre-flight check for registrations?
```

---

## Conclusion: The Learning Imperative

**Carson's core insight**: Context compounds. Each iteration should make the next one smarter.

**Huntley's core insight**: The codebase is the memory. Same prompt + changed code = learning.

**dev-ralph's current gap**: We have verification, but we don't **compound** the learnings.

**The fix**: Add learning accumulators that survive across iterations:
1. `lessons-learned.md` - Persistent discovery log
2. Auto-stdlib proposals - Learn patterns from repeated failures
3. Dynamic PROMPT.md sections - Inject learnings into context
4. Strategic plan synthesis - Not just `[FOUND]`, but patterns

This transforms dev-ralph from "iterate and verify" to **"iterate, verify, and learn"**.

---

## Deep Dive: Additional Dimensions

Beyond learning, there are several other dimensions where we can learn from these approaches.

---

### 1. Context Management

#### Addy Osmani's "Information Packing"

From his [2026 workflow](https://addyosmani.com/blog/ai-coding-workflow/):

> "Create comprehensive `spec.md` files containing requirements, architecture, and testing strategy."

| Technique | Description | dev-ralph equivalent |
|-----------|-------------|---------------------|
| **gitingest** | Dump relevant codebase portions | We use Explore agent |
| **Claude Skills** | Modular capability packages | Our stdlib/* pattern |
| **Selective inclusion** | Only include task-relevant context | Missing - we load all specs |
| **Explicit constraints** | "Tell it which naive solutions are too slow" | Missing - specs don't include anti-patterns |

**Gap identified**: Our specs don't include "what NOT to do" - anti-patterns that would waste iterations.

**Proposed fix**: Add anti-pattern section to spec template:

```markdown
## Anti-Patterns (DO NOT)

- Don't use inline styles (we use CSS modules)
- Don't fetch in components (we use React Query)
- Don't use `any` types (strict TypeScript)
```

---

#### Huntley's "Context Window Engineering"

> "Carve work into independent context windows rather than one massive continuous session."

| Principle | Implication |
|-----------|-------------|
| Fresh context per task | Each loop starts with clean PROMPT.md |
| Code IS memory | Changes persist in files, not conversation |
| Avoid context bloat | File-mediated results |

**dev-ralph alignment**: ✅ We already do this well with:
- Explore agents for search (return summaries, not raw output)
- File-mediated results in `.ralph/scratch/`
- Fresh PROMPT.md each iteration

**Gap**: We could be more aggressive about pruning context. Current PROMPT.md template has ~160 lines. Could be shorter.

---

### 2. Error Recovery Strategies

#### The "Failure as Data" Philosophy

From the Ralph Wiggum analysis:

> "Failure-as-data methodology. Each iteration's feedback—through file changes and logs—helps Claude refine approaches."

| Approach | How It Works |
|----------|--------------|
| **Let Claude fail** | "Let Claude fail repeatedly until it succeeds" |
| **File changes as feedback** | Git diffs inform next iteration |
| **Rapid iteration > perfect planning** | Speed over perfection |

**dev-ralph comparison**:
- ✅ We have retry limits (5 retries before asking for help)
- ✅ verification-report.md captures failures
- ❌ We don't explicitly feed failure context to next iteration
- ❌ We don't use git diffs as feedback

**Proposed enhancement**: Stop hook should include git diff summary:

```bash
# In stop-hook.sh, add:
CHANGES_SUMMARY=$(git diff --stat 2>/dev/null | tail -5)
SYSTEM_MSG="${SYSTEM_MSG}

Files changed since last iteration:
${CHANGES_SUMMARY}"
```

---

#### Addy Osmani's Multi-Layer Verification

> "Treat every AI-generated snippet as if it came from a junior developer."

| Layer | Mechanism |
|-------|-----------|
| Tests at each step | "write code → run tests → fix" |
| Secondary AI review | "Ask Gemini to critique code produced by Claude" |
| Ultra-frequent commits | "Save points enabling quick rollbacks" |

**dev-ralph comparison**:
- ✅ Verification phase is our "senior review"
- ❌ No secondary AI review (could use different model in auditor?)
- ❌ No auto-commits at checkpoints

**Proposed enhancement**: Checkpoint commit after each VERIFIED_COMPLETE:

```bash
# After verification passes, before exiting:
if [[ "$VERIFIED" == "true" ]]; then
    git add -A
    git commit -m "checkpoint: iteration $ITERATION verified"
fi
```

---

### 3. Task Decomposition

#### Osmani's "Waterfall in 15 Minutes"

> "Rapid structured planning before coding that prevents wasted cycles."

```
Planning Phase → Decomposition → Implementation → Verification → Integration
```

**Key insight**: The planning is fast but structured. Not free-form chat.

**dev-ralph comparison**:
- ✅ `/ralph-plan` does structured interview
- ❌ Interview might be too slow (multiple rounds of AskUserQuestion)
- ❌ We don't auto-decompose - developer must approve each spec

**Proposed enhancement**: Speed option for planning:

```bash
/ralph-plan "Build X" --fast
# Generates spec + plan in one shot, single approval
```

---

#### Huntley's "One Item Per Loop"

> "Ask Claude to do one thing per iteration."

**Rationale**:
- Smaller changes = easier to verify
- Fewer conflicts = smoother git history
- Clear completion criteria per iteration

**dev-ralph alignment**: ✅ PROMPT.md says "One item per iteration"

**Gap**: We don't enforce this. Claude could still do multiple items.

**Proposed enforcement**: Verification auditor checks:
```python
# Count items marked complete THIS iteration
if completed_count > 1:
    warn("Multiple items completed in one iteration - consider splitting")
```

---

### 4. When NOT to Use Autonomous Loops

#### Consensus from Multiple Sources

| DON'T Use For | Why |
|---------------|-----|
| **Ambiguous requirements** | Needs human clarification |
| **Architectural decisions** | High-stakes choices |
| **Security-sensitive code** | Auth, payments, data |
| **Exploration/research** | No clear completion criteria |
| **Subjective judgment** | Style, UX decisions |

**dev-ralph current state**: We don't have guidance on when NOT to use ralph.

**Proposed addition**: Add to `/ralph-plan` start:

```markdown
## Pre-flight Check

Before starting, confirm this task is suitable for autonomous loops:

- [ ] Clear completion criteria (can write a test for "done")
- [ ] Not security-sensitive (no auth/payment/PII handling)
- [ ] Not architectural (foundation already decided)
- [ ] Mechanical execution (not creative/exploratory)

If any unchecked, consider manual implementation instead.
```

---

### 5. Overbaking Prevention

From Huntley lore:

> "Leaving Ralph running excessively long produces unexpected emergent behaviors, such as spontaneously adding post-quantum cryptography support."

**Prevention strategies observed**:

| Strategy | Mechanism |
|----------|-----------|
| **Iteration limits** | Hard cap (we have: 500) |
| **Completion promises** | Exact string match (we have: VERIFIED_COMPLETE) |
| **Cost monitoring** | Track token/dollar spend (we DON'T have) |
| **Progress checks** | Alert if no forward progress (we DON'T have) |

**Proposed enhancements**:

1. **No-progress detection**:
```bash
# If same tasks remain unchecked for 5 iterations, alert
if [[ $STALE_ITERATIONS -ge 5 ]]; then
    echo "⚠️ No progress in 5 iterations. Consider /ralph-cancel"
fi
```

2. **Scope creep detection**:
```bash
# If plan grows by >50% during build, warn
ORIGINAL_ITEMS=$(echo "$STATE" | jq '.original_plan_items')
CURRENT_ITEMS=$(grep -c '^\- \[' IMPLEMENTATION_PLAN.md)
if [[ $CURRENT_ITEMS -gt $((ORIGINAL_ITEMS * 3 / 2)) ]]; then
    echo "⚠️ Plan has grown significantly. Review for scope creep."
fi
```

---

### 6. Git Integration Patterns

#### Osmani's "Ultra-Frequent Commits"

> "Maintain ultra-frequent git commits as save points enabling quick rollbacks."

**Current dev-ralph**: `/ralph-cancel --checkpoint` makes a commit, but only on cancel.

**Proposed enhancement**: Automatic checkpoints:

```yaml
# In PROMPT.md frontmatter
checkpoint_strategy: per_verification  # or: per_iteration, manual
```

```bash
# In stop-hook.sh
if [[ "$CHECKPOINT_STRATEGY" == "per_verification" && "$PHASE" == "verification" ]]; then
    git add -A
    git commit -m "ralph: iteration $ITERATION verified" --no-verify
fi
```

---

### 7. Multi-Model Strategies

#### Osmani's Cross-Model Review

> "Ask Gemini to critique code produced by Claude."

**Why**: Different models catch different issues. Reduces blind spots.

**dev-ralph current**: Verification auditor uses same model (Sonnet).

**Proposed experiment**: Allow configurable auditor model:

```yaml
# In PROMPT.md frontmatter
auditor_model: opus  # or: sonnet, gemini (if MCP available)
```

---

## Summary: Lessons from Each Approach

| Dimension | Carson | Huntley | Osmani | dev-ralph Gap |
|-----------|--------|---------|--------|---------------|
| **Learning** | PRD compounds | Code is memory | Rules in prompts | No accumulation |
| **Context** | Manual curation | Window engineering | Information packing | Missing anti-patterns |
| **Errors** | Manual review | Failure as data | Multi-layer verify | Missing git diff feedback |
| **Decomposition** | PRD → Tasks | One item per loop | Waterfall in 15min | No fast mode |
| **Safety** | Human in loop | Iteration limits | Frequent commits | Missing overbaking detection |
| **Git** | Standard workflow | Implicit | Ultra-frequent | Only on cancel |
| **Multi-model** | Cursor default | Not mentioned | Cross-model review | Single model |

---

## Action Items (Prioritized)

If we were to improve dev-ralph, these would be the high-impact changes:

### P0 - Critical Gaps
1. **Add lessons-learned.md** - Compound learning across iterations
2. **Git diff in stop-hook** - Feed file changes as context
3. **No-progress detection** - Alert after N stale iterations

### P1 - Important Improvements
4. **Anti-patterns in specs** - What NOT to do
5. **Auto-checkpoints** - Git commit on verification pass
6. **Scope creep detection** - Alert if plan grows too much

### P2 - Nice to Have
7. **Fast planning mode** - Single-shot spec generation
8. **Multi-model auditor** - Use different model for verification
9. **Cost tracking** - Token/dollar monitoring

---

This transforms dev-ralph from "iterate and verify" to **"iterate, verify, and learn"**.

---

## Sources

- [A 3-step AI coding workflow for solo founders | Ryan Carson](https://www.lennysnewsletter.com/p/a-3-step-ai-coding-workflow-for-solo)
- [A brief history of ralph | HumanLayer Blog](https://www.humanlayer.dev/blog/brief-history-of-ralph)
- [Ralph Wiggum Autonomous Loops](https://paddo.dev/blog/ralph-wiggum-autonomous-loops/)
- [How Ralph Wiggum went from The Simpsons to AI | VentureBeat](https://venturebeat.com/technology/how-ralph-wiggum-went-from-the-simpsons-to-the-biggest-name-in-ai-right-now/)
- [My LLM coding workflow going into 2026 | Addy Osmani](https://addyosmani.com/blog/ai-coding-workflow/)
- [What Is the Ralph Wiggum Plugin in Claude Code? | APIDog](https://apidog.com/blog/ralph-wiggum-plugin-in-claude-code/)

---

## Implementation Plan: P0 Improvements

### 1. Add lessons-learned.md

**Goal**: Create a persistent learning document that compounds across iterations.

**Files to modify**:
- `templates/PROMPT.md.template` - Add instruction to read lessons
- `agents/verification-auditor.md` - Add logic to append learnings
- `hooks/stop-hook.sh` - Optionally create file if missing

**Implementation**:

1. Create template at `templates/lessons-learned.md.template`:
```markdown
# Lessons Learned

This file accumulates discoveries across Ralph loops. Read at start of each iteration.

## Session: {date}

### Discovered Requirements
<!-- Requirements not in original spec that we had to address -->

### Error Patterns
<!-- Repeated mistakes and their fixes -->

### What Worked
<!-- Patterns that accelerated development -->

### Anti-Patterns Found
<!-- Things to avoid in future iterations -->
```

2. Update `agents/verification-auditor.md` to append after each verification:
   - On FAIL: Append failure pattern to "Error Patterns"
   - On PASS: Append successful patterns to "What Worked"
   - If pattern repeated 3+ times: Add to "Anti-Patterns Found"

3. Update `templates/PROMPT.md.template` context loading:
```markdown
0a. Study `specs/*` for requirements
0b. Study `IMPLEMENTATION_PLAN.md` for priorities
0c. **Study `lessons-learned.md` for accumulated wisdom**  # NEW
0d. The source code is in `src/`
```

---

### 2. Git diff in stop-hook

**Goal**: Feed file changes as context to help Claude understand what changed.

**Files to modify**:
- `hooks/stop-hook.sh` - Add git diff summary to system message

**Implementation**:

Add after line 114 (where we build SYSTEM_MSG):

```bash
# Get summary of changes since loop started
CHANGES_SUMMARY=""
if git rev-parse --git-dir >/dev/null 2>&1; then
    # Get stats for files changed (not full diff, just summary)
    CHANGES_SUMMARY=$(git diff --stat HEAD~1 2>/dev/null | tail -5 || echo "")
    if [[ -z "$CHANGES_SUMMARY" ]]; then
        CHANGES_SUMMARY=$(git status --short 2>/dev/null | head -5 || echo "")
    fi
fi

# Append to system message
if [[ -n "$CHANGES_SUMMARY" ]]; then
    SYSTEM_MSG="${SYSTEM_MSG}

Recent file changes:
${CHANGES_SUMMARY}"
fi
```

---

### 3. No-progress detection

**Goal**: Alert when loop is stuck (same items unchecked for N iterations).

**Files to modify**:
- `hooks/stop-hook.sh` - Track progress, detect stalls
- `.ralph/loop-state.json` - Add progress tracking fields

**Implementation**:

1. Update `scripts/setup-ralph-build.sh` to initialize tracking:
```json
{
  "active": true,
  "iteration": 1,
  "max_iterations": 500,
  "last_completed_count": 0,     // NEW
  "stale_iterations": 0          // NEW
}
```

2. Update `hooks/stop-hook.sh` to detect stalls:

```bash
# Count completed items
CURRENT_COMPLETED=$(grep -c '^\- \[x\]' "$RALPH_DIR/IMPLEMENTATION_PLAN.md" 2>/dev/null || echo 0)
LAST_COMPLETED=$(echo "$STATE" | jq -r '.last_completed_count // 0')
STALE_COUNT=$(echo "$STATE" | jq -r '.stale_iterations // 0')

if [[ "$CURRENT_COMPLETED" -eq "$LAST_COMPLETED" ]]; then
    STALE_COUNT=$((STALE_COUNT + 1))
else
    STALE_COUNT=0
fi

# Warn if stale for 5+ iterations
if [[ $STALE_COUNT -ge 5 ]]; then
    echo "⚠️ dev-ralph: No progress in $STALE_COUNT iterations."
    echo "   Consider /ralph-cancel and reviewing the plan."
fi

# Update state
NEW_STATE=$(echo "$NEW_STATE" | jq \
    --argjson completed "$CURRENT_COMPLETED" \
    --argjson stale "$STALE_COUNT" \
    '.last_completed_count = $completed | .stale_iterations = $stale')
```

---

## Verification

After implementing:

1. **Test lessons-learned.md**:
   - Run `/ralph-plan` + `/ralph-build` on a test project
   - Verify `lessons-learned.md` is created and updated
   - Check that PROMPT.md template references it

2. **Test git diff in stop-hook**:
   - Run a loop that modifies files
   - Check system message includes "Recent file changes:"

3. **Test no-progress detection**:
   - Create a plan with an impossible task
   - Run loop and verify warning after 5 stale iterations

---

## Files to Modify (Summary)

| File | Changes |
|------|---------|
| `templates/PROMPT.md.template` | Add lessons-learned.md reference |
| `templates/lessons-learned.md.template` | NEW - Learning template |
| `agents/verification-auditor.md` | Add logic to append learnings |
| `hooks/stop-hook.sh` | Add git diff + progress detection |
| `scripts/setup-ralph-build.sh` | Initialize progress tracking |
