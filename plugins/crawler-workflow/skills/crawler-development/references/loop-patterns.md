# Loop Patterns & Termination Conditions
# v1.0 - 循环模式与终止条件参考

## Overview

Crawlers often need to iterate through multiple items:
- Multiple pages (pagination)
- Multiple stores/accounts (dropdown selection)
- Multiple dates (date range)
- Multiple tabs or categories

This document explains how to identify, document, and implement these patterns.

---

## Loop Types

### 1. Pagination (翻页)

**Pattern**: Click "next" repeatedly until no more pages.

```
Page 1 → Page 2 → Page 3 → ... → Last Page (STOP)
```

**Termination Conditions**:
| Condition | Detection Code |
|-----------|----------------|
| "Next" button disabled | `await page.get_by_role("button", name="下一页").is_disabled()` |
| "Next" button hidden | `not await page.get_by_role("button", name="下一页").is_visible()` |
| No data message | `await page.get_by_text("暂无数据").is_visible()` |
| Page number equals total | Compare current page to total pages |
| Same data as previous | Compare extracted data |

**Code Pattern**:
```python
all_data = []
while True:
    # Extract current page data
    page_data = await extract_page_data(page)
    all_data.extend(page_data)

    # Check termination
    next_btn = page.get_by_role("button", name="下一页")
    if await next_btn.is_disabled() or not await next_btn.is_visible():
        break

    # Go to next page
    await next_btn.click()
    await page.wait_for_load_state("networkidle")
```

---

### 2. Dropdown Iteration (下拉选择遍历)

**Pattern**: Select each option in dropdown, extract data, repeat.

```
Store A → Store B → Store C → ... → Last Store (STOP)
```

**Get All Options**:
```python
# Method 1: Standard select element
options = await page.locator("select#store option").all_text_contents()
values = await page.locator("select#store option").evaluate_all(
    "options => options.map(o => o.value)"
)

# Method 2: Custom dropdown (click to open, then get items)
await page.get_by_role("combobox").click()
options = await page.locator(".dropdown-item").all_text_contents()
```

**Termination Condition**: All options processed (known list).

**Code Pattern**:
```python
# Get all options first
options = await page.locator("select#store option").all()
option_values = []
for opt in options:
    value = await opt.get_attribute("value")
    text = await opt.text_content()
    option_values.append({"value": value, "text": text})

# Iterate through each
all_data = []
for opt in option_values:
    # Select option
    await page.select_option("select#store", value=opt["value"])
    await page.wait_for_load_state("networkidle")

    # Extract data
    data = await extract_data(page)
    data["store"] = opt["text"]
    all_data.append(data)
```

---

### 3. Date Range Iteration (日期范围遍历)

**Pattern**: Iterate from start date to end date.

```
2025-01-01 → 2025-01-02 → ... → 2025-01-07 (STOP)
```

**Termination Condition**: Current date > end date.

**Code Pattern**:
```python
from datetime import datetime, timedelta

start_date = datetime(2025, 1, 1)
end_date = datetime(2025, 1, 7)
current_date = start_date

all_data = []
while current_date <= end_date:
    date_str = current_date.strftime("%Y-%m-%d")

    # Set date in UI
    await page.get_by_label("日期").fill(date_str)
    await page.get_by_role("button", name="查询").click()
    await page.wait_for_load_state("networkidle")

    # Extract data
    data = await extract_data(page)
    data["date"] = date_str
    all_data.append(data)

    # Next date
    current_date += timedelta(days=1)
```

---

### 4. Tab/Category Iteration (标签页/分类遍历)

**Pattern**: Click each tab, extract data.

```
Tab 1 → Tab 2 → Tab 3 → ... → Last Tab (STOP)
```

**Get All Tabs**:
```python
tabs = await page.get_by_role("tab").all()
```

**Code Pattern**:
```python
tabs = await page.get_by_role("tab").all()

all_data = []
for tab in tabs:
    tab_name = await tab.text_content()

    # Click tab
    await tab.click()
    await page.wait_for_load_state("networkidle")

    # Extract data
    data = await extract_data(page)
    data["category"] = tab_name
    all_data.append(data)
```

---

### 5. Checkbox/Filter Iteration (复选框/筛选器遍历)

**Pattern**: Toggle each checkbox, extract data.

```python
checkboxes = await page.get_by_role("checkbox").all()

for checkbox in checkboxes:
    label = await checkbox.get_attribute("aria-label")

    # Check the checkbox
    await checkbox.check()
    await page.wait_for_load_state("networkidle")

    # Extract data
    data = await extract_data(page)
    data["filter"] = label
    all_data.append(data)

    # Uncheck for next iteration (if needed)
    await checkbox.uncheck()
```

---

## Nested Loops (嵌套循环)

When you need to combine multiple loops:

```
Store A:
  Page 1 → Page 2 → Page 3
Store B:
  Page 1 → Page 2
Store C:
  Page 1
```

**Code Pattern**:
```python
stores = await get_all_stores(page)

all_data = []
for store in stores:
    # Select store
    await select_store(page, store)

    # Inner loop: pagination
    store_data = {"store": store, "pages": []}
    page_num = 1

    while True:
        # Extract page data
        page_data = await extract_page_data(page)
        store_data["pages"].append({
            "page": page_num,
            "items": page_data
        })

        # Check if more pages
        if not await has_next_page(page):
            break

        await go_to_next_page(page)
        page_num += 1

    all_data.append(store_data)
```

---

## Termination Detection Patterns

### Button State Detection

```python
# Disabled button
is_disabled = await page.get_by_role("button", name="下一页").is_disabled()

# Hidden button
is_hidden = not await page.get_by_role("button", name="下一页").is_visible()

# Button with specific class
has_disabled_class = await page.locator("button.next-btn.disabled").count() > 0
```

### Empty State Detection

```python
# "No data" message
no_data = await page.get_by_text("暂无数据").is_visible()
no_data = await page.get_by_text("没有更多了").is_visible()

# Empty table
row_count = await page.locator("table tbody tr").count()
is_empty = row_count == 0

# Empty list
item_count = await page.locator(".list-item").count()
is_empty = item_count == 0
```

### Page Number Detection

```python
# Current page vs total pages
current = await page.locator(".current-page").text_content()
total = await page.locator(".total-pages").text_content()
is_last = int(current) >= int(total)

# Active page indicator
active_page = await page.locator(".pagination .active").text_content()
```

### Data Comparison

```python
# Compare with previous page to detect duplicates
previous_data = None
while True:
    current_data = await extract_data(page)

    if current_data == previous_data:
        break  # Same data = no more pages

    all_data.extend(current_data)
    previous_data = current_data

    await go_to_next_page(page)
```

---

## Recording Checklist

When exploring a site, ask these questions for each potential loop:

1. **What needs to iterate?**
   - [ ] Pages (pagination)
   - [ ] Dropdown options
   - [ ] Date range
   - [ ] Tabs/categories
   - [ ] Checkboxes/filters

2. **How to get the list of items?**
   - Dropdown: Get all `<option>` elements
   - Tabs: Get all tab elements
   - Pagination: Unknown count, use while loop

3. **How to select/navigate to each item?**
   - Click? Select? Fill date?

4. **How to know when done?**
   - Button disabled/hidden?
   - No data message?
   - Reached end of list?
   - Date past end date?

5. **Is there nesting?**
   - For each store, paginate?
   - For each date, check all stores?

---

## Common Mistakes

| Mistake | Problem | Solution |
|---------|---------|----------|
| No termination check | Infinite loop | Always check before next iteration |
| Check after action | Miss last page data | Check BEFORE clicking next |
| Hardcoded page count | Breaks when data changes | Use dynamic detection |
| No wait after selection | Data not loaded | Add `wait_for_load_state()` |
| Modify list while iterating | Skip items | Get all items first, then iterate |
