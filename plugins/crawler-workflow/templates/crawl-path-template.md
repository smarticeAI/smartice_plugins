# Crawl Path: [Site Name]
# v1.1 - Updated with locator priority format

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
- **Locators** (by priority - see references/playwright-locators.md):
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
- **Pagination**: [how to get next page, or "none"]

| Field | Locator (within row) | Type | Example |
|-------|---------------------|------|---------|
| [field1] | `row.get_by_role("cell").nth(0)` | text | [example] |
| [field2] | `row.locator("td.amount")` | number | [example] |

---

## Expected Output Format

```json
{
  "field1": "example value",
  "field2": 123,
  "items": [
    {
      "subfield1": "value",
      "subfield2": 456
    }
  ]
}
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

See `references/playwright-locators.md` for detailed guidance.

---

## Notes
[Any additional observations during exploration]
