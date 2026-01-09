---
# dev-ralph Configuration (Test Project)

iteration_limit: 10
retry_limit: 3
coverage_threshold: 0
verbosity: normal

placeholder_patterns:
  - "TODO"
  - "FIXME"

build_commands:
  type_check: "bun run type-check"
  lint: "echo 'no lint'"
  test: "echo 'no tests'"

integration_strictness: lenient
---

# PROMPT.md - Per-Item Implementation Loop

## Core Principle: ONE ITEM AT A TIME

Each iteration, implement **exactly ONE item**:
1. Pick the first unchecked `[ ]` item
2. Implement it fully
3. Type-check
4. Mark it `[x]`
5. Output: `<item>COMPLETE</item>`

---

## Your Task: ONE ITEM

### Step 1: Find First Unchecked Item
Look in IMPLEMENTATION_PLAN.md for the first `- [ ]` item.

### Step 2: Implement It
Write the code. No placeholders.

### Step 3: Verify
Run type-check.

### Step 4: Mark Complete
Change `[ ]` to `[x]` in IMPLEMENTATION_PLAN.md.

### Step 5: Signal Done
```
<item>COMPLETE</item>
```

---

## When All Items Done

After last item:
1. Run verification
2. Output: `<promise>VERIFIED_COMPLETE</promise>`
