# Crawler Workflow Plugin

Interactive crawler development using Chrome DevTools MCP.

## Prerequisites

1. **Chrome DevTools MCP** must be configured
2. Chrome running with `--remote-debugging-port=9222`

## Usage

```
/crawl
```

This starts a **user-led** workflow:

1. **Explore** - Navigate site with user guidance, record selectors
2. **Build** - Generate Playwright crawler from documentation
3. **Test** - Validate crawler output

## Workflow

```
User + Agent explore site together
        ↓
    crawl-path.md (documentation)
        ↓
    crawler-builder agent
        ↓
    crawler.py (generated code)
        ↓
    crawler-tester agent
        ↓
    Validated output
```

## Key Features

- **User-paced exploration** - Agent waits for user instruction at each step
- **Multiple locators** - Records 2-3 locator options per element (get_by_role preferred)
- **Loop detection** - Asks about pagination, dropdowns, date ranges
- **Termination conditions** - Documents how to know when loops end

## Files Generated

| File | Purpose |
|------|---------|
| `crawl-path.md` | Navigation steps, locators, loops, expected output |
| `crawler.py` | Generated Playwright crawler |

## Documentation

References are auto-loaded via skill `crawler-workflow:crawler-development`:
- Playwright locator best practices
- Loop and termination patterns
