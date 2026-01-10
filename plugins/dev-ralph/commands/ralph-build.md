---
description: "Start Ralph implementation loop - simple, no agents"
argument-hint: "[--dry-run]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-build.sh *)", "Read"]
---

# Ralph Build Phase (v3 - Simplified)

Start the Ralph implementation loop. Based on Geoffrey Huntley's Ralph Wiggum technique.

**One item per iteration**: read context, implement one item, type-check, mark done, signal.
**No agents**: You handle everything inline.
**Files are state**: specs/, IMPLEMENTATION_PLAN.md, lessons-learned.md

## Arguments

Options: $ARGUMENTS

- `--dry-run`: Show what would happen without starting

## Start Protocol

### Step 1: Validate and Initialize

Run the setup script:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-build.sh $ARGUMENTS
```

The script:
1. Checks `.ralph/specs/*.md` exists
2. Checks `.ralph/IMPLEMENTATION_PLAN.md` exists
3. Checks `.ralph/PROMPT.md` exists
4. Creates `.ralph/loop-state.json`
5. Outputs the prompt

### Step 2: Follow PROMPT.md

The Stop hook feeds PROMPT.md back each iteration. Per iteration:

1. **Read context**: specs/*.md, IMPLEMENTATION_PLAN.md, lessons-learned.md
2. Find FIRST unchecked `[ ]` item in IMPLEMENTATION_PLAN.md
3. Implement it fully (no placeholders!)
4. Run type-check (backpressure)
5. Mark it `[x]` when done
6. Output: `<item>COMPLETE</item>`

### Step 3: Complete

When ALL items are done:

```
<promise>VERIFIED_COMPLETE</promise>
```

## The Loop

```
┌─────────────────────────────────────┐
│  ONE ITEM PER ITERATION             │
│                                     │
│  1. Read context (specs, plan)      │
│  2. Pick first unchecked item       │
│  3. Implement fully                 │
│  4. Type-check (backpressure)       │
│  5. Mark [x]                        │
│  6. Output: <item>COMPLETE</item>   │
│                                     │
│  Loop feeds next iteration.         │
│  When ALL done:                     │
│  <promise>VERIFIED_COMPLETE</promise>│
└─────────────────────────────────────┘
```

## Backpressure

**Type-check is your validation.** Run after each item.

- Fails → fix before moving on
- Passes → item is done

No verification agents needed. Type-check IS the verification.

## Anti-Cheating

**NON-NEGOTIABLE:**

1. NO placeholder code (TODO, FIXME, stubs)
2. NO empty function bodies
3. NO unimplemented interfaces
4. FULL implementations only

## Loop Controls

- `/ralph-status` - Check progress
- `/ralph-cancel` - Stop the loop
- Max iterations: configurable in PROMPT.md

## State Files

All in `.ralph/`:
- `loop-state.json` - iteration counter
- `PROMPT.md` - fed back each iteration
- `IMPLEMENTATION_PLAN.md` - task tracking
- `specs/*.md` - specifications
- `Signs.md` - tuning instructions (optional)
- `lessons-learned.md` - discoveries (append-only, optional)
