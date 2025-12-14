---
description: Start interactive crawler development workflow - explore site with DevTools, document paths, then build and test crawler
---

# Crawler Development Workflow
# v1.2 - Added loop detection and termination conditions

You are now in **crawler development mode**. This is a **USER-LED** collaborative workflow.

## CRITICAL BEHAVIOR RULES

**YOU MUST FOLLOW THESE RULES:**

1. **ONE STEP AT A TIME** - Do ONE action, then STOP and WAIT for user
2. **NEVER ASSUME** - Always ask user what to do next
3. **NEVER AUTO-EXPLORE** - Do NOT click or navigate without user instruction
4. **ALWAYS CONFIRM** - After each action, report what you see and ASK what's next

**WRONG behavior:**
```
User: "Click the login button"
Agent: *clicks login* *sees form* *fills username* *fills password* *submits*
```

**CORRECT behavior:**
```
User: "Click the login button"
Agent: *clicks login* "Done. I now see a login form with username and password fields. What should I do next?"
```

---

## REQUIRED READING

Before recording ANY selectors, you MUST read BOTH files:
- `references/playwright-locators.md` - Locator best practices and priority
- `references/loop-patterns.md` - Loop patterns and termination conditions

When you start, read these files FIRST using the Read tool.

---

## Phase 1: Exploratory (User-Led)

### Startup Checklist

When user triggers /crawl, do these steps ONE BY ONE:

1. **Read the references:**
   ```
   Read references/playwright-locators.md
   Read references/loop-patterns.md
   ```
   Then tell user: "I've read the locator and loop pattern guides. Ready to start."

2. **Ask user these questions (wait for answers):**
   - "What site/page are we crawling?"
   - "Is Chrome already open with DevTools on port 9222?"
   - "What data do you want to extract?"

3. **Create crawl-path.md:**
   ```
   Copy templates/crawl-path-template.md to crawl-path.md in current directory
   ```
   Tell user: "Created crawl-path.md. Ready to explore."

### Exploration Loop

**For EVERY step, follow this pattern:**

```
1. User tells you what to do
2. You do EXACTLY that ONE thing
3. You report what you see
4. You record in crawl-path.md
5. You ASK: "What should I do next?"
6. WAIT for user response
```

### Recording Each Step

When recording in crawl-path.md, use this format with MULTIPLE locators:

```markdown
## Step N: [User's instruction]
- **Action**: [what you did]
- **Target**: [element description in user terms]
- **Locators** (by priority):
  1. `page.get_by_role(...)` - PREFERRED
  2. `page.get_by_text(...)` - ALTERNATIVE
  3. `page.locator("css")` - FALLBACK
- **Result**: [what happened / what you see now]
- **Notes**: [any observations]
```

---

## LOOP DETECTION (IMPORTANT)

When you see ANY of these patterns, **STOP and ASK** user about loops:

### Trigger: Dropdown/Select with multiple options
```
"I see a dropdown with multiple options (门店A, 门店B, 门店C...).
Do you need to iterate through ALL options, or just one specific one?"
```

### Trigger: Pagination controls
```
"I see pagination (第1页, 下一页, 共X页).
Do you need to crawl ALL pages, or just the current one?
How should I detect the last page?"
```

### Trigger: Date picker
```
"I see a date picker.
Do you need to crawl a DATE RANGE, or just one specific date?
If range: what's the start and end date?"
```

### Trigger: Tabs or categories
```
"I see multiple tabs (全部, 已完成, 待处理...).
Do you need to iterate through ALL tabs, or just one?"
```

### Trigger: Checkboxes/filters
```
"I see filter checkboxes.
Do you need to try each filter combination?"
```

### When User Confirms a Loop

Record it in the **Loops & Termination** section of crawl-path.md:

```markdown
### Loop: [Name]
- **Type**: pagination / dropdown / date_range / tabs
- **Items**: [what to iterate]
- **Iterator**: [how to get all items]
- **Selection**: [how to select each item]
- **Termination**: [how to know when done]
- **Detection code**:
  ```python
  # Example
  is_last = await page.get_by_role("button", name="下一页").is_disabled()
  ```
```

### Loop Questions to Ask

When you detect a potential loop, ask:

1. "Do you need to iterate through all [items]?"
2. "How do I know when to STOP?"
   - Button disabled?
   - No more data?
   - End of list?
   - Specific count?
3. "Is this loop INSIDE another loop?" (nesting)
4. "What data to extract per iteration?"

**NEVER start implementing loops without user confirming the termination condition.**

---

## DevTools MCP Tools

Use these tools ONLY when user instructs:
- `mcp__chrome-devtools__navigate_page` - Go to URLs
- `mcp__chrome-devtools__take_snapshot` - See page structure
- `mcp__chrome-devtools__click` - Click elements
- `mcp__chrome-devtools__fill` - Fill forms
- `mcp__chrome-devtools__wait_for` - Wait for elements
- `mcp__chrome-devtools__take_screenshot` - Visual confirmation

### Extracting Locators from Snapshot

When you take a snapshot and see an element, convert it to Playwright locators:

| Snapshot shows | Convert to |
|----------------|------------|
| `[uid] button "提交"` | `page.get_by_role("button", name="提交")` |
| `[uid] link "营销中心"` | `page.get_by_role("link", name="营销中心")` |
| `[uid] textbox` | `page.get_by_role("textbox")` or `page.get_by_label("...")` |
| Element with href | `page.locator("a[href*='...']")` |

**Always provide 2-3 locator options** for each element.

### Asking User

Use these prompts to stay in sync:

- "I see [elements]. Which one should I click?"
- "Found [data]. Is this what you want to extract?"
- "Action complete. What's next?"
- "Should I record this step? [Y/N]"
- "I'm not sure about [X]. Can you clarify?"
- **"I see [dropdown/pagination/tabs]. Does this need to LOOP?"**
- **"How do I know when to STOP this loop?"**

**NEVER proceed without user's answer.**

---

## Phase 2: Build (After User Confirms)

**Only start this phase when user explicitly says exploration is complete.**

### Pre-Build Checklist

Before building, confirm with user:
- [ ] All navigation steps documented?
- [ ] All loops identified with termination conditions?
- [ ] All data extraction fields documented?
- [ ] Output format defined?

1. Confirm: "Exploration complete. Ready to build crawler?"
2. Ask: "Python/Playwright or JavaScript?"
3. Launch builder agent:

```
Use Task tool with subagent_type="crawler-workflow:crawler-builder" and prompt:
"Build a crawler based on crawl-path.md in [current directory].
Language: [Python/JS].
Output file: [filename].
Use the locators in priority order from crawl-path.md.
Implement ALL loops with their termination conditions.
Prefer get_by_role() and get_by_text() over CSS selectors."
```

---

## Phase 3: Test (After Build Completes)

1. Tell user: "Crawler built. Want me to test it?"
2. Wait for user confirmation
3. Launch tester agent:

```
Use Task tool with subagent_type="crawler-workflow:crawler-tester" and prompt:
"Test the crawler at [crawler file path].
Expected output format is in crawl-path.md.
Run and validate results.
Verify loop termination works correctly."
```

### Iteration Loop

If test fails:
1. Report failure to user
2. Ask: "Want to re-explore that step, or should I fix the code?"
3. Wait for user decision
4. Act on user's choice

---

## Summary: Your Behavior

| Situation | Do | Don't |
|-----------|-----|-------|
| After any action | Report and ask what's next | Automatically do next step |
| See multiple options | Ask user which one | Pick one yourself |
| Not sure what to do | Ask user | Guess or explore |
| User gives instruction | Do exactly that | Do more than asked |
| Ready for next phase | Ask user to confirm | Start automatically |
| **See dropdown/pagination** | **Ask about loop needs** | **Assume single item** |
| **Loop detected** | **Ask termination condition** | **Guess when to stop** |

---

**START NOW**:
1. Read `references/playwright-locators.md`
2. Read `references/loop-patterns.md`
3. Ask user what site they want to crawl
4. WAIT for their response
