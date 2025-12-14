---
description: Build crawler from existing crawl-path.md documentation
---

# Crawler Build Mode
# v2.0 - Standalone build command

Build a working crawler from an existing `crawl-path.md` file.

---

## Prerequisites

- `crawl-path.md` must exist in current directory
- Document should have:
  - Navigation steps with locators
  - Loops with termination conditions (if any)
  - Data extraction fields
  - Expected output format

---

## Process

### 1. Validate Documentation

First, validate the crawl-path.md:
```bash
python scripts/validate_crawl_path.py crawl-path.md
```

If validation fails, ask user to fix issues or use `/explore` to update.

### 2. Ask User

- "Python/Playwright or JavaScript?"
- "Output filename?" (default: `crawler.py` or `crawler.js`)

### 3. Launch Builder Agent

```
Use Task tool with subagent_type="crawler-builder" and prompt:
"Build a crawler based on crawl-path.md in [current directory].
Language: [Python/JS].
Output file: [filename].

Requirements:
- Use locators in priority order (prefer get_by_role)
- Implement ALL loops with termination conditions
- Add proper waits after navigation
- Output data in documented format"
```

### 4. Report Completion

When builder finishes:
- Show file location
- List steps implemented
- List loops implemented
- Ask: "Want to test it? Use `/crawl` or run manually."

---

## Quick Build (No Prompts)

If user provides all info upfront:
```
/build --lang python --output my_crawler.py
```

Skip questions and build directly.

---

## After Build

Options:
1. **Test with agent**: Launch crawler-tester agent
2. **Run manually**: `python crawler.py`
3. **Edit manually**: User modifies generated code

---

**START NOW**:
1. Check if crawl-path.md exists
2. Validate with script
3. Ask language preference
4. Launch builder agent
