# dev-ralph: Plugin Specification

A Claude Code plugin implementing Geoffrey Huntley's Ralph Wiggum technique with developer-agent collaboration.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Name** | dev-ralph |
| **Scope** | Greenfield projects only |
| **Operator Model** | Developer + Agent collaboration |
| **Distribution** | Private (evaluate open-source later) |

---

## Philosophy

### Core Principles (from Huntley)

1. **Deterministically bad in an undeterministic world** - Failures are predictable and tunable
2. **One item per loop** - Ask Claude to do one thing per iteration
3. **Monolithic, not multi-agent** - Single process, single repo, scales vertically
4. **Deterministic stack allocation** - Same context loaded every loop
5. **The wheel must turn fast** - Iteration speed matters

### Our Adaptations

1. **Developer-in-the-loop** - Human guides planning, agent executes
2. **Two-phase completion** - Implementation complete → verification → verified complete
3. **Structured planning** - AskUserQuestion tool for planning interviews
4. **Checklist gates** - Required items before phase transitions

---

## Directory Structure

```
.ralph/
├── PROMPT.md                    # Static prompt loaded every iteration
├── specs/                       # One spec per topic of concern
│   ├── feature-auth.md
│   └── feature-chat.md
├── IMPLEMENTATION_PLAN.md       # Prioritized task list (ephemeral)
├── stdlib/                      # Code patterns for Claude to follow
│   ├── error-handling.md
│   └── api-patterns.md
├── verification-report.md       # Latest verification audit
└── config (in PROMPT.md frontmatter)
```

### PROMPT.md Structure

```markdown
---
# Configuration (YAML frontmatter)
coverage_threshold: 80
iteration_limit: 500
retry_limit: 5
verbosity: normal  # minimal | normal | verbose
---

# PROMPT.md

## Context Loading

0a. Study specs/* to learn about requirements
0b. Study IMPLEMENTATION_PLAN.md for current priorities
0c. Study stdlib/* for code patterns to follow
0d. The source code is in src/

## Your Task

Pick the most important unfinished item from IMPLEMENTATION_PLAN.md and implement it.
Use as many parallel subagents as needed for search/read operations.
Use only 1 subagent for build/test operations.

## Completion Protocol

When implementation is complete:
1. Run type check: `bun run type-check`
2. If passing, output: <status>IMPLEMENTATION_COMPLETE</status>
3. This triggers verification phase (subagent audit)
4. If verification passes, output: <promise>VERIFIED_COMPLETE</promise>

## Anti-Cheating Rules

99999999999999. DO NOT IMPLEMENT PLACEHOLDERS.
99999999999998. NO TODO comments, no unimplemented stubs.
99999999999997. FULL IMPLEMENTATIONS ONLY OR I WILL YELL AT YOU.
```

### IMPLEMENTATION_PLAN.md Structure

Huntley-style lightweight format:

```markdown
# Implementation Plan

Items sorted by priority (links to specs for traceability):

- Implement user authentication flow (spec: specs/feature-auth.md)
- Add message streaming support (spec: specs/feature-chat.md)
- Create error boundary component (spec: specs/feature-auth.md)
- Add loading states to all forms
```

Updated by checking off completed items:
```markdown
- [x] Implement user authentication flow (spec: specs/feature-auth.md)
- Add message streaming support (spec: specs/feature-chat.md)
```

---

## Commands

### /ralph-plan

Starts the planning phase with structured interview.

```
Usage: /ralph-plan [task-description]

Example: /ralph-plan "Build a kanban board with drag-drop"
```

**Behavior:**
1. Uses AskUserQuestion tool for structured interview
2. Agent proposes spec files, human approves each
3. Continues until checklist gate is satisfied
4. Gate requires: specs exist + plan exists + stdlib has patterns + developer approval

### /ralph-build

Starts the implementation loop.

```
Usage: /ralph-build [-v|--verbose] [--dry-run]

Options:
  -v, --verbose    Show detailed progress (configurable levels)
  --dry-run        Show what would be done without executing
```

**Behavior:**
1. Validates checklist gate (fails if planning incomplete)
2. Activates Stop hook to create loop
3. Feeds PROMPT.md content each iteration
4. Loops until VERIFIED_COMPLETE or limits reached

### /ralph-status

Shows current loop status.

```
Usage: /ralph-status
```

**Output:**
```
Ralph Loop Status
─────────────────
Phase: Implementation
Iteration: 12 / 500 (limit)
Current task: Add message streaming support
Plan progress: 2/5 items complete

Recent activity:
  - [x] Implement user authentication flow (iteration 8)
  - [x] Create error boundary component (iteration 11)
  - [ ] Add message streaming support (in progress)

Files changed this session: 14
Errors encountered: 2 (recovered)
```

### /ralph-cancel

Cancels the active loop.

```
Usage: /ralph-cancel [--checkpoint]

Options:
  --checkpoint    Git commit current state before canceling
```

---

## State Management

### Filesystem Only

All state stored in `.ralph/` directory:
- Git-tracked for version control
- Survives session restarts
- Human-readable markdown

### No Database

Unlike LingLong Agent's Supabase integration, dev-ralph is purely filesystem-based for simplicity and portability.

---

## Subagent Architecture

### Parallelism Strategy

| Operation Type | Parallelism | Rationale |
|---------------|-------------|-----------|
| Search (grep, glob) | Parallel | Read-only, no conflicts |
| File reads | Parallel | Read-only, no conflicts |
| File writes | Serial | Avoid conflicts |
| Build/test | Serial (1 agent) | Resource intensive |

### Context Preservation

Primary agent (~170k context) acts as **scheduler**:
- Coordinates work
- Reads summarized results
- Makes decisions

Subagents handle **expensive operations**:
- Codebase search
- Test execution
- File analysis
- URL fetching

### Result Flow

```
Subagent work → Write to file → Primary reads file
                    │
                    └── .ralph/scratch/<operation>.md
```

File-mediated results prevent context bloat. Subagents write findings to scratch files, primary reads only what's needed.

### Escalation Protocol

When subagent discovers something important:

1. **Alert primary** - Include in summary response
2. **Persist for future** - Append to `.ralph/IMPLEMENTATION_PLAN.md` or `.ralph/issues.md`

---

## Two-Phase Completion

### Phase 1: Implementation Complete

When Claude finishes implementing a task:

1. Run backpressure: `bun run type-check`
2. If passing, output: `<status>IMPLEMENTATION_COMPLETE</status>`

### Phase 2: Verification

Hook detects IMPLEMENTATION_COMPLETE and triggers verification:

1. **Spawn verification subagent** (independent audit)
2. Subagent checks:
   - Test coverage on new code (configurable threshold)
   - No placeholder patterns (`grep -r "TODO\|unimplemented\|NotImplemented"`)
   - All specs addressed
3. Write report to `.ralph/verification-report.md`

### Phase 3: Verified Complete

If verification passes:
- Output: `<promise>VERIFIED_COMPLETE</promise>`
- Hook detects promise and allows exit
- Loop terminates successfully

If verification fails:
- New iteration begins (counter increments)
- Verification report provides context for fixes

---

## Backpressure Stack

### During Iteration (Fast)

Only type checking for fast iteration:
```bash
bun run type-check
```

### During Verification (Thorough)

Full verification:
```bash
bun run type-check
bun run lint
bun run test:coverage
grep -r "TODO\|FIXME\|unimplemented" src/
```

Coverage threshold is configurable (default: 80%).

---

## Error Handling

### Retry Strategy

| Failure Type | Retries | Action After Limit |
|-------------|---------|-------------------|
| Type error | 5 | Ask developer for help |
| Test failure | 5 | Ask developer for help |
| Lint error | 5 | Ask developer for help |
| Context overflow | 1 | Auto-summarize, continue |

### Error Context

When backpressure rejects, subagent provides:
- Parsed error messages
- Relevant code snippets
- Suggested fixes

Not raw error dumps (context preservation).

### Hard Failure Recovery

When 5 retries exhausted:
1. Loop pauses
2. Prompt developer: "I'm stuck on X. Here's what I tried..."
3. Wait for guidance
4. Continue with new direction

---

## Edge Cases

### Context Overflow

When context exhausted:
1. Auto-summarize conversation
2. Continue in same session
3. File-based state survives

### Orphan Loops

Safety limits even with "unlimited budget":
- Hard cap: 500 iterations
- Prevents runaway loops

### Impossible Tasks

When task is impossible (spec contradiction, missing dependency):
1. Pause loop
2. Prompt developer with specific blocker
3. Wait for guidance or spec update

### Plan Drift

When Ralph goes off track:
- **Auto-detect**: Suggest plan regeneration after N failed iterations
- **Manual**: `/ralph-cancel` + `/ralph-plan` to restart planning

---

## Planning Phase Details

### Structured Interview

Planning uses AskUserQuestion tool (like this conversation):

```
Developer: /ralph-plan "Build user dashboard"

Ralph: [Uses AskUserQuestion]
  "What data should the dashboard display?"
  - User profile info
  - Recent activity
  - Analytics metrics
  - All of the above

Developer: [Selects options]

Ralph: "Based on your answers, I propose this spec:"
  [Shows spec content]
  "Should I write this to .ralph/specs/dashboard.md?"

Developer: "Yes"

Ralph: [Writes spec, continues interview...]
```

### Checklist Gate

Before implementation can start, ALL must be true:
- [ ] At least one spec file exists in `.ralph/specs/`
- [ ] `IMPLEMENTATION_PLAN.md` exists with items
- [ ] At least one stdlib pattern exists (or explicit skip)
- [ ] Developer explicitly approved (typed `/ralph-build`)

### Spec Granularity

Agent decides granularity based on task complexity:
- Small task: 1-2 specs
- Large feature: 5+ specs (one per concern)

---

## stdlib Patterns

### Purpose

Show Claude the "right way" to do things in this project.

### Population Strategy

Start empty, populate iteratively:

1. **Manual**: Developer adds patterns when Claude makes mistakes
2. **Agentic**: During planning, agent proposes patterns based on codebase analysis

### Integration

During loops, stdlib content is merged into context alongside CLAUDE.md:
```
PROMPT.md → loads specs/* → loads IMPLEMENTATION_PLAN.md → loads stdlib/* → loads CLAUDE.md
```

### Example Pattern

`.ralph/stdlib/api-patterns.md`:
```markdown
# API Patterns

## Error Handling

Always wrap API calls in try-catch with specific error types:

```typescript
try {
  const response = await apiClient.get('/endpoint');
  return response.data;
} catch (error) {
  if (error instanceof ApiError) {
    // Handle API-specific error
  }
  throw error;
}
```

## Why This Matters

Previous iterations produced inconsistent error handling. This pattern ensures
all API errors are properly typed and handled consistently.
```

---

## Plugin Implementation

### Hook: Stop

Blocks exit and re-feeds PROMPT.md:

```bash
#!/bin/bash
# hooks/stop-hook.sh

RALPH_STATE_FILE=".ralph/loop-state.json"

if [[ ! -f "$RALPH_STATE_FILE" ]]; then
  exit 0  # No active loop
fi

# Read state
STATE=$(cat "$RALPH_STATE_FILE")
ITERATION=$(echo "$STATE" | jq -r '.iteration')
MAX_ITERATIONS=$(echo "$STATE" | jq -r '.max_iterations')

# Check completion
LAST_OUTPUT="$CLAUDE_LAST_OUTPUT"
if echo "$LAST_OUTPUT" | grep -q "<promise>VERIFIED_COMPLETE</promise>"; then
  rm "$RALPH_STATE_FILE"
  echo "✅ Ralph loop: Verified complete after $ITERATION iterations"
  exit 0
fi

# Check limits
if [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "⚠️ Ralph loop: Iteration limit reached ($MAX_ITERATIONS)"
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Continue loop
NEXT_ITERATION=$((ITERATION + 1))
echo "$STATE" | jq ".iteration = $NEXT_ITERATION" > "$RALPH_STATE_FILE"

# Feed prompt back
cat .ralph/PROMPT.md
echo ""
echo "---"
echo "Iteration: $NEXT_ITERATION / $MAX_ITERATIONS"

exit 1  # Block exit, continue loop
```

### Skill: ralph-plan

```yaml
---
name: ralph-plan
description: Start Ralph planning phase with structured interview
arguments:
  - name: task
    description: Brief description of what to build
    required: true
---
```

### Skill: ralph-build

```yaml
---
name: ralph-build
description: Start Ralph implementation loop
arguments:
  - name: verbose
    description: Verbosity level (minimal, normal, verbose)
    required: false
    default: normal
---
```

---

## Configuration Reference

YAML frontmatter in `.ralph/PROMPT.md`:

```yaml
---
# Limits
iteration_limit: 500      # Hard cap on iterations
retry_limit: 5            # Retries before asking for help

# Coverage
coverage_threshold: 80    # Percentage required for verification

# UX
verbosity: normal         # minimal | normal | verbose

# Anti-cheat patterns to grep for
placeholder_patterns:
  - "TODO"
  - "FIXME"
  - "unimplemented"
  - "NotImplementedError"
  - "throw new Error('Not implemented')"
---
```

---

## Success Criteria

A successful dev-ralph session:

1. ✅ Planning phase produces clear specs via structured interview
2. ✅ Implementation loop runs autonomously
3. ✅ Two-phase completion ensures quality
4. ✅ Developer intervention only when truly stuck
5. ✅ Final code passes all backpressure checks
6. ✅ Verification report documents what was built

---

## Future Considerations

Not in scope for v1, but worth considering:

- [ ] Web dashboard for monitoring
- [ ] Cost tracking and estimates
- [ ] Git checkpointing at phase boundaries
- [ ] Multi-project orchestration
- [ ] Open source release

---

*Specification Version: 1.0*
*Created: 2026-01-02*
*Status: Ready for Implementation*
