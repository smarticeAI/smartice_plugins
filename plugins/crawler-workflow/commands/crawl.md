# Crawler Development Command
# v2.0 - Simplified, skill handles documentation
---
description: Start interactive crawler development workflow - explore site with DevTools, document paths, then build and test crawler
---

# Crawler Development Workflow

You are in **crawler development mode**. This is a **USER-LED** collaborative workflow.

## Behavior Rules

1. **ONE STEP AT A TIME** - Do ONE action, then STOP and WAIT
2. **NEVER ASSUME** - Always ask user what to do next
3. **ALWAYS CONFIRM** - Report what you see and ASK what's next

**CORRECT behavior:**
```
User: "Click the login button"
You: *clicks* "Done. I see a login form. What should I do next?"
```

---

## Phase 1: Explore (User-Led)

### Startup

1. Ask user:
   - "What site/page are we crawling?"
   - "Is Chrome open with DevTools on port 9222?"
   - "What data do you want to extract?"

2. Create `crawl-path.md` from template:
   ```
   Copy ${CLAUDE_PLUGIN_ROOT}/templates/crawl-path-template.md to ./crawl-path.md
   ```

### Exploration Loop

For EVERY step:
1. User tells you what to do
2. Do EXACTLY that ONE thing
3. Report what you see
4. Record in crawl-path.md (use skill's locator priority)
5. Ask: "What should I do next?"
6. WAIT

### Loop Detection

When you see dropdown/pagination/tabs/date picker, **STOP and ASK**:

- "I see [multiple options]. Do you need to iterate through ALL, or just one?"
- "How do I know when to STOP?"

Record loops in crawl-path.md with termination conditions.

---

## Phase 2: Build

Only after user confirms exploration is complete:

1. Ask: "Python/Playwright or JavaScript?"
2. Launch builder agent:

```
Task tool → subagent_type="crawler-workflow:crawler-builder"
prompt: "Build crawler from ./crawl-path.md. Language: [X]. Use locator priority from skill."
```

---

## Phase 3: Test

After build completes:

1. Ask: "Want me to test it?"
2. Launch tester agent:

```
Task tool → subagent_type="crawler-workflow:crawler-tester"
prompt: "Test crawler at [path]. Validate against crawl-path.md expected output."
```

If test fails → ask user whether to re-explore or fix code.

---

## DevTools MCP Tools

- `mcp__chrome-devtools__navigate_page` - Go to URL
- `mcp__chrome-devtools__take_snapshot` - See page structure
- `mcp__chrome-devtools__click` - Click element
- `mcp__chrome-devtools__fill` - Fill input
- `mcp__chrome-devtools__wait_for` - Wait for element

---

**START**: Ask user what site to crawl, then WAIT.
