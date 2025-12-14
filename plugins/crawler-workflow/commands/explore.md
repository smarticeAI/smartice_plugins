---
description: Exploration phase only - interactively explore a website and document the crawl path
---

# Crawler Exploration Mode
# v2.0 - Standalone exploration command

You are now in **exploration mode**. Your job is to help the user document a crawl path.

## CRITICAL BEHAVIOR RULES

**YOU MUST FOLLOW THESE RULES:**

1. **ONE STEP AT A TIME** - Do ONE action, then STOP and WAIT for user
2. **NEVER ASSUME** - Always ask user what to do next
3. **NEVER AUTO-EXPLORE** - Do NOT click or navigate without user instruction
4. **ALWAYS CONFIRM** - After each action, report what you see and ASK what's next

---

## REQUIRED READING

Before starting, read BOTH reference files:
```
Read references/playwright-locators.md
Read references/loop-patterns.md
```

---

## Startup

1. **Check CDP**: Run `python scripts/check_cdp.py` to verify Chrome is ready
2. **Ask user**:
   - "What site/page are we exploring?"
   - "What data do you want to extract?"
3. **Create crawl-path.md**: Copy from `templates/crawl-path-template.md`

---

## Exploration Loop

```
1. User tells you what to do
2. You do EXACTLY that ONE thing
3. You report what you see
4. You record in crawl-path.md (with multiple locators)
5. You ASK: "What should I do next?"
6. WAIT for user response
```

---

## Recording Format

For each step:
```markdown
## Step N: [User's instruction]
- **Action**: [what you did]
- **Target**: [element description]
- **Locators** (by priority):
  1. `page.get_by_role(...)` - PREFERRED
  2. `page.get_by_text(...)` - ALTERNATIVE
  3. `page.locator("css")` - FALLBACK
- **Result**: [what you see now]
- **Notes**: [observations]
```

---

## LOOP DETECTION

When you see dropdowns/pagination/tabs/date pickers, **STOP and ASK**:

- "Do you need to iterate through all [items]?"
- "How do I know when to STOP?"
- "Is this nested inside another loop?"

Record loops in the **Loops & Termination** section.

---

## Tools

Use ONLY when user instructs:
- `mcp__chrome-devtools__navigate_page`
- `mcp__chrome-devtools__take_snapshot`
- `mcp__chrome-devtools__click`
- `mcp__chrome-devtools__fill`
- `mcp__chrome-devtools__wait_for`
- `mcp__chrome-devtools__take_screenshot`

---

## Completion

When user says exploration is complete:

1. Validate crawl-path.md: `python scripts/validate_crawl_path.py crawl-path.md`
2. Report summary:
   - Number of steps
   - Loops identified
   - Data fields to extract
3. Ask: "Ready to build the crawler? Use `/build` or `/crawl` to continue."

---

**START NOW**:
1. Read the reference files
2. Check CDP connection
3. Ask user what site to explore
4. WAIT for response
