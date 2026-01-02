# Ralph Wiggum Technique: Operator's Guide

A comprehensive guide to using the Ralph Wiggum autonomous loop technique effectively with Claude Code.

---

## What is Ralph?

Ralph is **a persistence loop** that exploits a key insight: Claude can see its own previous work through files and git history. Each iteration:

```
Prompt → Claude works → Tries to exit → Hook intercepts → Same prompt fed back → Claude sees modified files → Repeat
```

The magic: **the prompt never changes, but the context does** (via files Claude created/modified).

Named after Ralph Wiggum from The Simpsons - embodying persistent iteration despite setbacks.

---

## Why Use Ralph?

| Use Case | Traditional | With Ralph |
|----------|-------------|------------|
| Build feature with tests | Multiple back-and-forth sessions | Single prompt, walk away |
| Fix all lint errors | Manual iteration | Autonomous until green |
| Generate documentation | Piecemeal requests | Comprehensive, self-verifying |
| Greenfield projects | Constant supervision | Overnight generation |

**Real results:**
- Y Combinator hackathon: 6 repositories generated overnight
- $50k contract delivered for ~$297 in API costs
- Entire programming language created over 3 months

---

## Getting Started

### Option 1: Claude Code Plugin (Recommended)

The plugin is already available. Start a loop:

```bash
/ralph-loop "Your task description" --completion-promise "DONE" --max-iterations 30
```

**CRITICAL: You MUST provide the prompt!** Without it, the loop has no task.

Cancel if needed:
```bash
/cancel-ralph
```

**Verify the loop started correctly:**
```bash
head -10 .claude/ralph-loop.local.md
```

Should show:
```yaml
---
active: true
iteration: 1
max_iterations: 30
completion_promise: "DONE"
---
Your task description
```

If the file doesn't exist, the loop wasn't started properly.

### Option 2: Ralph Orchestrator (Production)

For more control, monitoring, and multi-agent support:

```bash
git clone https://github.com/mikeyobrien/ralph-orchestrator.git
cd ralph-orchestrator && uv sync
ralph init        # Creates PROMPT.md + ralph.yml
ralph run         # Start the loop
ralph status      # Check progress
```

Features: token tracking, cost limits, git checkpointing, ACP protocol support.

---

## TDD with Ralph: Two Approaches

Ralph excels at Test-Driven Development. Choose your approach:

### Approach A: Tests Upfront (Spec-First TDD)

Human writes all tests first, Ralph implements until they pass.

**File Structure:**
```
.claude/plans/feature-name.md     # Detailed plan (phases, files, architecture)
src/__tests__/feature.test.ts     # All tests written upfront (all fail initially)
```

**Prompt:**
```markdown
Implement the plan in ~/.claude/plans/feature-name.md

Tests are already written in src/__tests__/feature.test.ts

Run `bun run test` after each change.
Done when all tests pass.
```

**Completion:**
```bash
--completion-promise 'ALL_TESTS_PASS'
```

**When to use:**
- Clear spec/requirements
- Well-defined interfaces
- Tests serve as documentation
- You want strict control over behavior

### Approach B: Ralph Writes Tests (True TDD)

Prompt instructs Ralph to follow TDD workflow: write test → implement → repeat.

**File Structure:**
```
.claude/plans/feature-name.md     # Detailed plan (phases, files, architecture)
```

**Prompt:**
```markdown
Follow the plan in ~/.claude/plans/feature-name.md

Use TDD workflow:
1. Write a failing test
2. Implement minimum code to pass
3. Refactor if needed
4. Repeat for next feature

Run `bun run test && bun run type-check && bun run lint` after each change.
Done when all features implemented and tests pass.
```

**When to use:**
- Exploratory implementation
- Complex features that need iterative design
- When interface isn't fully defined yet
- Learning/prototyping

### The Plan File

Both approaches need a detailed plan file. Ralph reads it to know WHAT to build.

**Example plan structure:**
```markdown
# Feature: [Name]

## Objective
[What we're building and why]

## Architecture
[How it fits into the system]

## Phases
### Phase 1: Foundation
- [Task 1]
- [Task 2]

### Phase 2: Core Logic
- [Task 3]
- [Task 4]

## Files to Create/Modify
| File | Purpose |
|------|---------|
| src/components/X.tsx | Main component |
| src/hooks/useX.ts | State management |

## Verification
- `bun run test` - all tests pass
- `bun run type-check` - no type errors
- `bun run lint` - no lint warnings
```

### Invoking Ralph with Plan + Tests

**For Approach A (tests upfront):**
```bash
/ralph-loop "Implement ~/.claude/plans/feature.md - tests in src/__tests__/feature.test.ts - done when all tests pass" --completion-promise 'ALL_TESTS_PASS' --max-iterations 60
```

**For Approach B (Ralph writes tests):**
```bash
/ralph-loop "Follow TDD per ~/.claude/plans/feature.md - write tests first then implement - done when all features complete and tests pass" --completion-promise 'FEATURE_COMPLETE' --max-iterations 60
```

---

## Prompt Engineering: The Core Skill

**Operator skill matters more than model capability.** Your prompt quality determines success.

### The Four Pillars

#### 1. Clear Completion Criteria

```markdown
## Task
Build a todo REST API with FastAPI

## Success Criteria (ALL must be true)
- [ ] CRUD endpoints: GET/POST/PUT/DELETE /todos
- [ ] Input validation with Pydantic
- [ ] Tests passing with >80% coverage
- [ ] README with API docs

## Completion Signal
Output <promise>COMPLETE</promise> ONLY when ALL criteria verified.
```

#### 2. Self-Verification Steps

```markdown
## Verification (run EVERY iteration)
1. Run `pytest -v` - all tests must pass
2. Run `ruff check .` - no lint errors
3. Run `bun run type-check` - no TypeScript errors
4. If ANY fail → fix and retry
5. Do NOT output completion signal until ALL green
```

#### 3. Escape Hatches

```markdown
## If Stuck After 15 Iterations
- Document blockers in BLOCKERS.md
- List what was attempted
- Suggest what human input is needed
- Output <promise>STUCK</promise>
```

#### 4. Progressive Phases (for complex tasks)

```markdown
## Phase 1: Foundation (iterations 1-5)
- Project structure
- Basic types and schemas
- Commit: "Phase 1: foundation"

## Phase 2: Core Logic (iterations 6-15)
- Business logic implementation
- Unit tests for each function
- Commit: "Phase 2: core logic"

## Phase 3: Integration (iterations 16-25)
- API endpoints
- Integration tests
- Commit: "Phase 3: integration complete"

## Completion
Only after ALL phases done, output <promise>COMPLETE</promise>
```

---

## Prompt Templates

### Template: Feature with Tests

```markdown
# Task: Implement [FEATURE NAME]

## Context
- Project: [description]
- Stack: [technologies]
- Existing patterns: [reference files]

## Requirements
1. [Requirement 1]
2. [Requirement 2]
3. [Requirement 3]

## Files to Create/Modify
- `src/[path]` - [purpose]
- `tests/[path]` - [purpose]

## Verification (every iteration)
1. Run `[test command]` - must pass
2. Run `[lint command]` - must pass
3. Run `[type-check command]` - must pass

## Success Criteria
- [ ] All requirements implemented
- [ ] Tests cover happy path and edge cases
- [ ] All verification commands pass
- [ ] Code follows existing patterns

## Completion
Output <promise>DONE</promise> when ALL criteria met.

## If Stuck (after 10 iterations)
- Document issue in BLOCKERS.md
- Output <promise>STUCK</promise>
```

### Template: Bug Fix

```markdown
# Task: Fix [BUG DESCRIPTION]

## Reproduction
1. [Step 1]
2. [Step 2]
3. Expected: [X], Actual: [Y]

## Investigation Steps
1. Find where the bug originates
2. Understand the root cause
3. Write a failing test that reproduces the bug

## Fix Requirements
- Fix must not break existing tests
- Add regression test for this bug
- Document the fix in commit message

## Verification
1. `[test command]` - all green including new regression test
2. Manual verification: [steps]

## Completion
Output <promise>FIXED</promise> when:
- Root cause identified
- Fix implemented
- Regression test added
- All tests passing
```

### Template: Refactoring

```markdown
# Task: Refactor [TARGET]

## Goal
[What improvement we want]

## Constraints
- No behavior changes (all existing tests must pass)
- No new dependencies unless absolutely necessary
- Follow existing code patterns

## Approach
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Verification (every iteration)
1. `[test command]` - all existing tests pass
2. `[lint command]` - no new warnings
3. Behavior unchanged

## Completion
Output <promise>REFACTORED</promise> when complete.
```

---

## Monitoring and Intervention

### What Claude Sees Each Iteration

- **Modified files** - its own previous work
- **Git history** - `git log`, `git diff` show progress
- **Test output** - if verification steps are in prompt
- **Error messages** - from failed commands

### Decision Framework: When to Intervene

| Signal | Iterations | Action |
|--------|------------|--------|
| Same error repeating | 3+ | Cancel, add specific guidance to prompt |
| Making progress | Any | Let it run |
| Going wrong direction | 2+ | Cancel, add constraints |
| Completion signal but wrong | 1 | Add verification steps |
| STUCK signal | 1 | Review blockers, provide input |

### Monitoring Commands

```bash
# Check iteration status
/cancel-ralph  # Shows current state

# With orchestrator
ralph status

# Manual checks
git log --oneline -10  # See commits
git diff HEAD~1        # See last changes
```

---

## Cost Management

### Estimated Costs (Claude Sonnet 4)

| Task Complexity | Iterations | Est. Cost |
|-----------------|------------|-----------|
| Simple feature | 5-10 | $0.50-2 |
| Medium feature | 15-25 | $2-8 |
| Complex feature | 30-50 | $8-20 |
| Large project | 50-100 | $20-50 |

### Cost Control Strategies

1. **Always set max-iterations**
   ```bash
   /ralph-loop "..." --max-iterations 30
   ```

2. **Start conservative, increase if needed**
   - First attempt: 15 iterations
   - If hits limit but making progress: restart with 30

3. **Break large tasks into phases**
   - Each phase as separate Ralph run
   - Reduces blast radius if something goes wrong

4. **Use cheaper models for iteration-heavy tasks**
   - Ralph Orchestrator supports Gemini, Q Chat

---

## Common Pitfalls

### 0. Not Passing the Prompt (CRITICAL!)

The most fundamental mistake - invoking Ralph without actually providing the task.

```bash
# WRONG - no prompt, loop has nothing to do
/ralph-loop --completion-promise "DONE" --max-iterations 30

# WRONG - prompt not passed to Skill tool
Skill(skill: "ralph-wiggum:ralph-loop")  # Missing args!

# RIGHT - prompt is the first argument
/ralph-loop "Your task description here" --completion-promise "DONE" --max-iterations 30

# RIGHT - with Skill tool, pass args
Skill(skill: "ralph-wiggum:ralph-loop", args: "\"Your task\" --completion-promise 'DONE' --max-iterations 30")
```

**Always verify the loop started:**
```bash
head -10 .claude/ralph-loop.local.md
```

If the file doesn't exist or has no prompt content, the loop isn't running!

### 1. Vague Completion Criteria

```markdown
# Bad
Output DONE when it looks good.

# Good
Output <promise>DONE</promise> when:
- [ ] `npm test` exits 0
- [ ] `npm run lint` exits 0
- [ ] All 5 requirements implemented
```

### 2. No Verification Steps

```markdown
# Bad
Implement the feature and output DONE.

# Good
Every iteration:
1. Run `npm test`
2. Run `npm run lint`
3. If any fail, fix before continuing
4. Only output DONE when ALL pass
```

### 3. Overly Ambitious Scope

```markdown
# Bad
Build a complete e-commerce platform with user auth,
product catalog, cart, checkout, payments, admin panel,
analytics, and email notifications.

# Good
Phase 1: User authentication (JWT, register, login)
...run Ralph...
Phase 2: Product catalog
...run Ralph...
```

### 4. No Escape Hatch

```markdown
# Bad
Keep trying until it works.

# Good
If after 20 iterations still failing:
- Write BLOCKERS.md with analysis
- Output <promise>STUCK</promise>
```

---

## Best Practices Summary

1. **Always pass the prompt** - No prompt = no loop
2. **Verify loop started** - Check `.claude/ralph-loop.local.md` exists
3. **Set limits** - Always use `--max-iterations`
4. **Use plan files** - Detailed plan in file, prompt references it
5. **Make verification automatic** - Include test commands in prompt
6. **Use git checkpoints** - Prompt Claude to commit at milestones
7. **Include escape hatches** - Define STUCK behavior
8. **Iterate on prompts** - Failures are data; tune the instrument
9. **Break large tasks** - Multiple focused Ralph runs > one giant one

---

## The Prompt-Plan Relationship

**Don't put everything in the prompt.** Use progressive disclosure:

```
┌─────────────────────────────────────────────────────────────┐
│  PROMPT (short, passed to /ralph-loop)                      │
│  - References the plan file                                 │
│  - Defines completion criteria                              │
│  - Specifies verification commands                          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  PLAN FILE (~/.claude/plans/feature.md)                     │
│  - Detailed phases and tasks                                │
│  - Architecture decisions                                   │
│  - Files to create/modify                                   │
│  - Code examples and patterns                               │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  TEST FILE (optional, for Approach A)                       │
│  - All tests written upfront                                │
│  - Defines exact behavior expected                          │
│  - Serves as executable specification                       │
└─────────────────────────────────────────────────────────────┘
```

**Example workflow:**

```bash
# 1. Create detailed plan
cat > ~/.claude/plans/my-feature.md << 'EOF'
# Feature: User Authentication
## Phases
### Phase 1: JWT Token Service
...detailed specs...
EOF

# 2. (Optional) Write tests upfront
# Edit src/__tests__/auth.test.ts with all test cases

# 3. Start Ralph with short prompt referencing plan
/ralph-loop "Implement ~/.claude/plans/my-feature.md using TDD. Tests in src/__tests__/auth.test.ts. Done when all tests pass." --completion-promise 'AUTH_COMPLETE' --max-iterations 60

# 4. Verify loop started
head -10 .claude/ralph-loop.local.md
```

Ralph reads the plan file each iteration, knows what to build, and iterates until done.

---

## Integration with LingLong

See `docs/ORCHESTRATION_PLAN.md` for how we're building Ralph-like capabilities into the LingLong Agent platform for end users.

The key differences:
- **This doc**: Using Ralph as a developer for local development
- **ORCHESTRATION_PLAN**: Building Ralph-style loops into our product

---

## References

- [Ralph Wiggum Plugin](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/ralph-wiggum)
- [Ralph Orchestrator](https://github.com/mikeyobrien/ralph-orchestrator)
- [Original Article by Geoffrey Huntley](https://ghuntley.com/ralph/)
- [Ralph Orchestrator Docs](https://mikeyobrien.github.io/ralph-orchestrator/)

---

*Created: 2026-01-02*
*Updated: 2026-01-02 - Added TDD approaches, plan-prompt relationship, common pitfalls*
*Status: Active*
