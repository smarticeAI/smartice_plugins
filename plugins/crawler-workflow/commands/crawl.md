# Crawler Development Command
# v3.0 - Use TodoWrite to enforce workflow
---
description: Start interactive crawler development workflow - explore site with DevTools, document paths, then build and test crawler
---

# Crawler Development Workflow

**FIRST ACTION**: Use TodoWrite to create this task list:

```
TodoWrite with todos:
1. "Load skill crawler-workflow:crawler-development" (in_progress)
2. "Create crawl-path.md from template" (pending)
3. "Ask user: site, CDP ready, data to extract" (pending)
4. "Explore site with user (record steps)" (pending)
5. "Launch crawler-builder agent" (pending)
6. "Launch crawler-tester agent" (pending)
```

Then execute each todo in order. Mark as completed when done.

---

## Todo 1: Load Skill

```
Use Skill tool: "crawler-workflow:crawler-development"
```

This loads locator priority and loop patterns. **Read it.**

---

## Todo 2: Create crawl-path.md

```
Copy ${CLAUDE_PLUGIN_ROOT}/templates/crawl-path-template.md to ./crawl-path.md
```

---

## Todo 3: Ask User

- "What site/page are we crawling?"
- "Is Chrome open with DevTools on port 9222?"
- "What data do you want to extract?"

---

## Todo 4: Explore (User-Led)

**Behavior Rules:**
- ONE action at a time, then WAIT
- Record every step in crawl-path.md
- When you see pagination/dropdown/tabs → ask about loops

**Loop:**
1. User tells you what to do
2. Do that ONE thing
3. Record in crawl-path.md
4. Ask: "What next?"
5. WAIT

When user says "exploration done" → mark todo 4 complete, start todo 5.

---

## Todo 5: Build

Ask: "Python or JavaScript?"

Then launch agent:
```
Task tool
  subagent_type: "crawler-workflow:crawler-builder"
  prompt: "Build crawler from ./crawl-path.md. Language: [user choice]."
```

---

## Todo 6: Test

Ask: "Want me to test it?"

Then launch agent:
```
Task tool
  subagent_type: "crawler-workflow:crawler-tester"
  prompt: "Test crawler at [path]. Validate output format."
```

If failed → ask user: re-explore or fix code?

---

## DevTools MCP Tools

- `mcp__chrome-devtools__take_snapshot` - See page
- `mcp__chrome-devtools__click` - Click
- `mcp__chrome-devtools__fill` - Fill input
- `mcp__chrome-devtools__wait_for` - Wait

---

**START NOW**: Create the todo list above, then begin todo 1.
