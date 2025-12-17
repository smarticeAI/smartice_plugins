# Crawler Development Skill
# v1.0 - Playwright locators and loop patterns reference
---
name: crawler-development
description: This skill should be used when the user asks to "build a crawler", "scrape a website", "extract data from page", "playwright locators", "loop patterns", "pagination handling", "dropdown iteration", or needs guidance on browser automation, selector strategies, and termination conditions for web crawlers.
version: 1.0.0
---

# Crawler Development Reference

This skill provides comprehensive guidance for building web crawlers with Playwright.

## Playwright Locator Priority

**Always prefer "user-visible" locators** - they are more stable and readable.

| Priority | Method | Example | When to Use |
|----------|--------|---------|-------------|
| 1 | `get_by_role()` | `page.get_by_role("button", name="提交")` | Buttons, links, form controls |
| 2 | `get_by_label()` | `page.get_by_label("用户名")` | Form inputs with labels |
| 3 | `get_by_text()` | `page.get_by_text("营销中心")` | Text links, menu items |
| 4 | `get_by_placeholder()` | `page.get_by_placeholder("请输入")` | Inputs without labels |
| 5 | `get_by_test_id()` | `page.get_by_test_id("submit-btn")` | Elements with data-testid |
| 6 | CSS Selector | `page.locator("a[href*='marketing']")` | Attribute-based selection |
| 7 | XPath | `page.locator("//button")` | Last resort |

### Quick Reference

| Element Type | Recommended Locator |
|--------------|---------------------|
| Button | `get_by_role("button", name="...")` |
| Link | `get_by_role("link", name="...")` |
| Text Input | `get_by_label("...")` or `get_by_placeholder("...")` |
| Checkbox | `get_by_role("checkbox", name="...")` |
| Dropdown | `get_by_role("combobox", name="...")` |
| Table Row | `get_by_role("row").filter(has_text="...")` |

### What to AVOID

```python
# BAD - fragile DOM-dependent selectors
page.locator("#tsf > div:nth-child(2) > div.A8SBwf > input")
page.locator("button").nth(5)

# GOOD - semantic and stable
page.get_by_role("textbox", name="搜索")
page.get_by_role("button", name="提交")
```

---

## Loop Patterns

### 1. Pagination (翻页)

```python
all_data = []
while True:
    page_data = await extract_page_data(page)
    all_data.extend(page_data)

    next_btn = page.get_by_role("button", name="下一页")
    if await next_btn.is_disabled() or not await next_btn.is_visible():
        break

    await next_btn.click()
    await page.wait_for_load_state("networkidle")
```

### 2. Dropdown Iteration (下拉遍历)

```python
options = await page.locator("select#store option").all()
for opt in options:
    value = await opt.get_attribute("value")
    await page.select_option("select#store", value=value)
    await page.wait_for_load_state("networkidle")
    data = await extract_data(page)
    all_data.append(data)
```

### 3. Date Range (日期范围)

```python
from datetime import datetime, timedelta

current = start_date
while current <= end_date:
    await page.get_by_label("日期").fill(current.strftime("%Y-%m-%d"))
    await page.get_by_role("button", name="查询").click()
    await page.wait_for_load_state("networkidle")
    data = await extract_data(page)
    all_data.append(data)
    current += timedelta(days=1)
```

### 4. Nested Loops (嵌套循环)

```python
for store in stores:
    await select_store(page, store)
    while True:  # pagination
        data = await extract_page_data(page)
        all_data.append({"store": store, "data": data})
        if not await has_next_page(page):
            break
        await go_to_next_page(page)
```

---

## Termination Detection

| Condition | Detection Code |
|-----------|----------------|
| Button disabled | `await btn.is_disabled()` |
| Button hidden | `not await btn.is_visible()` |
| No data message | `await page.get_by_text("暂无数据").is_visible()` |
| Empty table | `await page.locator("tbody tr").count() == 0` |
| Page = total | Compare current vs total page numbers |

---

## Recording Format for crawl-path.md

```markdown
## Step N: [Action Description]
- **Action**: click / fill / wait
- **Target**: [user-visible description]
- **Locators** (by priority):
  1. `page.get_by_role(...)`
  2. `page.get_by_text(...)`
  3. `page.locator("css")`
- **Wait After**: [what to wait for]
- **Notes**: [special handling]
```

### Loop Recording

```markdown
### Loop: [Name]
- **Type**: pagination / dropdown / date_range
- **Iterator**: [how to get items]
- **Selection**: [how to select each]
- **Termination**: [how to detect end]
```

---

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| No termination check | Always check before clicking next |
| Hardcoded page count | Use dynamic detection |
| No wait after selection | Add `wait_for_load_state()` |
| Index-based selectors | Use role/text locators |
