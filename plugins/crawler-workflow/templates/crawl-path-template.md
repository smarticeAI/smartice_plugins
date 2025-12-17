# Crawl Path: [Site Name]
# v1.3 - References moved to skill

> Generated during exploratory phase
> Date: [YYYY-MM-DD]

## Overview
- **Target URL**: [starting URL]
- **Purpose**: [what data to extract]
- **Auth Required**: Yes / No

---

## Navigation Steps

### Step 1: [Action Name]
- **Action**: navigate / click / fill / wait / hover
- **Target**: [description of element in user-visible terms]
- **Locators** (by priority - see skill docs):
  1. `page.get_by_role(...)` or `page.get_by_text(...)`
  2. `page.locator("css selector")`
  3. `page.locator("xpath")` (if needed)
- **Wait After**: [ms or element to wait for]
- **Notes**: [special handling]

### Step 2: [Action Name]
- **Action**:
- **Target**:
- **Locators**:
  1.
  2.
- **Wait After**:
- **Notes**:

<!-- Add more steps as needed -->

---

## Loops & Termination

> IMPORTANT: Document ALL iteration patterns here. See skill docs for guidance.

### Loop 1: [Name, e.g., "Store Selection" / "Pagination" / "Date Range"]

- **Type**: pagination / dropdown_iteration / date_range / checkbox_iteration / tab_iteration
- **What to iterate**: [e.g., "All stores in dropdown", "All pages of results", "Each day from start to end"]

#### Iterator
- **Source**: [where to get the list of items]
  - For dropdown: `page.locator("select#store option")` → get all options
  - For pagination: page numbers or "next" button
  - For date range: start date → end date
- **Get all items**:
  ```python
  # Example: Get all dropdown options
  options = await page.locator("select#store option").all_text_contents()
  ```

#### Select/Navigate Action
- **How to select each item**:
  ```python
  # Example: Select dropdown option
  await page.select_option("select#store", value=option_value)
  ```
- **Wait after selection**: [what to wait for after each selection]

#### Termination Condition
- **How to know when done**:
  - [ ] All items in list processed
  - [ ] "Next" button disabled/hidden
  - [ ] Reached last page number
  - [ ] Empty results returned
  - [ ] Date reached end date
  - [ ] Other: [describe]

- **Detection locator**:
  ```python
  # Example: Check if "next" button is disabled
  is_last = await page.get_by_role("button", name="下一页").is_disabled()

  # Example: Check if no more data
  no_data = await page.get_by_text("暂无数据").is_visible()
  ```

#### Data per Iteration
- **What to extract in each iteration**: [field names]
- **Accumulate or replace**: accumulate / replace

---

### Loop 2: [Nested Loop, if any]

- **Type**: [pagination inside store selection, etc.]
- **Parent Loop**: Loop 1 (Store Selection)
- **Relationship**: For each store, iterate all pages

#### Iterator
- **Source**: [same format as above]

#### Termination Condition
- **Detection**: [same format as above]

---

### Loop Summary Table

| Loop | Type | Items | Termination | Nested In |
|------|------|-------|-------------|-----------|
| 1. Store Selection | dropdown | ~10 stores | all options done | - |
| 2. Pagination | pagination | unknown | "next" disabled | Loop 1 |
| 3. Date Range | date_range | 7 days | reached end date | - |

---

## Data Extraction

### Field: [Field Name]
- **Location**: [where on page, user-visible description]
- **Locators**:
  1. `page.get_by_role(...).text_content()`
  2. `page.locator("css").text_content()`
- **Type**: text / number / date / boolean
- **Example Value**: [actual value seen]
- **Transform**: [any parsing needed, e.g., "remove $ prefix"]

### Field: [Field Name]
- **Location**:
- **Locators**:
  1.
- **Type**:
- **Example Value**:

---

## List/Table Extraction (if applicable)

### Table: [Table Name]
- **Container Locator**: `page.get_by_role("table")` or `page.locator("...")`
- **Row Locator**: `page.get_by_role("row")` or `page.locator("tr")`
- **Within Loop**: [which loop, if any]

| Field | Locator (within row) | Type | Example |
|-------|---------------------|------|---------|
| [field1] | `row.get_by_role("cell").nth(0)` | text | [example] |
| [field2] | `row.locator("td.amount")` | number | [example] |

---

## Expected Output Format

```json
{
  "store_name": "门店A",
  "date": "2025-01-01",
  "summary": {
    "field1": "value",
    "field2": 123
  },
  "items": [
    {
      "subfield1": "value",
      "subfield2": 456
    }
  ]
}
```

**Output Structure with Loops**:
```json
[
  {
    "store": "门店A",
    "pages": [
      { "page": 1, "items": [...] },
      { "page": 2, "items": [...] }
    ]
  },
  {
    "store": "门店B",
    "pages": [...]
  }
]
```

---

## Special Handling

### Iframes
- [ ] Site uses iframes
- Frame locator: `page.frame_locator("[name='frame-name']")`

### Dynamic Content
- [ ] Content loads dynamically
- Wait strategy: `page.get_by_text("加载完成").wait_for()`

### Popups/Modals
- [ ] Site shows popups
- Dismiss locator: `page.get_by_role("button", name="关闭")`

### Authentication
- [ ] Requires login
- Login preserved via: CDP session / cookies

---

## Locator Selection Notes

When recording locators, prefer in this order:
1. **Role-based**: `get_by_role()` - most stable
2. **Label-based**: `get_by_label()` - for form inputs
3. **Text-based**: `get_by_text()` - for visible text
4. **Attribute-based**: `locator("[attr='value']")` - for unique attributes
5. **CSS/XPath**: Last resort - avoid long chains

See skill documentation for detailed guidance.

---

## Notes
[Any additional observations during exploration]
