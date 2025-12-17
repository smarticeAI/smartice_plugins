# Playwright Locator Best Practices
# v1.0 - Playwright 定位器最佳实践参考

## Locator Priority (优先级)

When recording selectors in crawl-path.md, **always record multiple locators** in this priority order:

| Priority | Method | Example | When to Use |
|----------|--------|---------|-------------|
| 1 | `get_by_role()` | `page.get_by_role("button", name="提交")` | Buttons, links, form controls |
| 2 | `get_by_label()` | `page.get_by_label("用户名")` | Form inputs with labels |
| 3 | `get_by_text()` | `page.get_by_text("营销中心")` | Text links, menu items |
| 4 | `get_by_placeholder()` | `page.get_by_placeholder("请输入")` | Inputs without labels |
| 5 | `get_by_test_id()` | `page.get_by_test_id("submit-btn")` | Elements with data-testid |
| 6 | CSS Selector | `page.locator("a[href*='marketing']")` | Attribute-based selection |
| 7 | XPath | `page.locator("//button")` | Last resort for complex DOM |

## Core Principle

**Prefer "user-visible" locators** because they are:
- More stable (don't depend on DOM structure)
- More readable (code is self-documenting)
- Closer to user perspective

## Recording Format

For EVERY interactive element in crawl-path.md, record like this:

```markdown
## Step N: [Action Description]
- **Action**: click / fill / hover / wait
- **Target**: "营销中心" navigation link
- **Locators** (by priority):
  1. `page.get_by_role("link", name="营销中心")`
  2. `page.get_by_text("营销中心")`
  3. `page.locator("a[href*='marketing/home']")`
- **Wait After**: page load / element visible
- **Notes**: [any special handling]
```

## Common Patterns

### Buttons
```python
# Best
page.get_by_role("button", name="提交")
page.get_by_role("button", name=re.compile("submit", re.IGNORECASE))

# Fallback
page.locator("button.submit-btn")
```

### Links/Navigation
```python
# Best
page.get_by_role("link", name="营销中心")

# Fallback
page.locator("a[href*='marketing']")
```

### Form Inputs
```python
# Best - with label
page.get_by_label("用户名")

# With placeholder
page.get_by_placeholder("请输入手机号")

# Fallback
page.locator("input[name='username']")
```

### Dropdowns/Selects
```python
# Best
page.get_by_role("combobox", name="选择门店")

# Fallback
page.locator("select#store-selector")
```

### Tables
```python
# Row by content
page.get_by_role("row").filter(has_text="订单号12345")

# Cell within row
row = page.get_by_role("row").filter(has_text="12345")
cell = row.get_by_role("cell").nth(2)
```

### Dynamic Content
```python
# Wait for element
await page.get_by_text("加载完成").wait_for()

# Wait for specific state
await page.get_by_role("button", name="提交").wait_for(state="visible")
```

## What to AVOID

```python
# BAD - Too fragile, breaks when DOM changes
page.locator("#tsf > div:nth-child(2) > div.A8SBwf > input")
page.locator("body > div:nth-child(3) > button")

# BAD - Index-based without context
page.locator("button").nth(5)

# GOOD - Semantic and stable
page.get_by_role("textbox", name="搜索")
page.get_by_role("button", name="提交")
```

## Combining Locators

```python
# AND - must match both
button = page.get_by_role("button").and_(page.get_by_title("Subscribe"))

# Filter - narrow down
row = page.get_by_role("listitem").filter(has_text="Product A")

# Within - scoped search
modal = page.locator(".modal")
submit = modal.get_by_role("button", name="确认")
```

## Debugging Tips

When a locator doesn't work:

1. **Check visibility**: Element might be hidden or in iframe
2. **Check timing**: Element might not be loaded yet
3. **Check frame**: Element might be inside an iframe
4. **Use DevTools**: Right-click element → Copy → Copy selector (as starting point only)

## Quick Reference Table

| Element Type | Recommended Locator |
|--------------|---------------------|
| Button | `get_by_role("button", name="...")` |
| Link | `get_by_role("link", name="...")` |
| Text Input | `get_by_label("...")` or `get_by_placeholder("...")` |
| Checkbox | `get_by_role("checkbox", name="...")` |
| Radio | `get_by_role("radio", name="...")` |
| Dropdown | `get_by_role("combobox", name="...")` |
| Heading | `get_by_role("heading", name="...")` |
| List Item | `get_by_role("listitem").filter(has_text="...")` |
| Table Row | `get_by_role("row").filter(has_text="...")` |
| Any by text | `get_by_text("...")` |
