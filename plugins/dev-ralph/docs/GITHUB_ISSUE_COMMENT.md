# GitHub Issue Comment: Plugin-Defined Agents Tool Execution

**For issue:** [#4462](https://github.com/anthropics/claude-code/issues/4462)

---

## Root Cause Found: Explicit `tools:` Field Causes Sandboxing

After systematic testing, I found that **plugin-defined agents with an explicit `tools:` field** run in sandboxed mode where tool operations don't persist to the filesystem.

### Test Results

| Agent | `tools:` field | Bash/Write persists? |
|-------|----------------|---------------------|
| `pr-review-toolkit:code-reviewer` | **Not specified** | ✅ Yes |
| `pr-review-toolkit:code-simplifier` | **Not specified** | ✅ Yes |
| `plugin-dev:plugin-validator` | `["Read", "Grep", "Glob", "Bash"]` | ❌ No |
| `plugin-dev:skill-reviewer` | `["Read", "Grep", "Glob"]` | ❌ No |
| Custom `verification-auditor` | YAML list with Bash | ❌ No |

### The Pattern

- **With explicit `tools:` field** → Tools run in sandboxed/simulated mode (claims success, nothing persists)
- **Without `tools:` field** → Agent inherits all tools and they execute on real filesystem

### The Fix

**Remove the `tools:` field from the agent's YAML frontmatter:**

```yaml
# BEFORE (broken - sandboxed):
---
name: my-agent
model: sonnet
tools:
  - Read
  - Bash
  - Write
color: cyan
---

# AFTER (working - real execution):
---
name: my-agent
model: sonnet
color: cyan
---
```

### Confirmed Working

After removing the `tools:` field and restarting Claude Code:

| Check | Before | After |
|-------|--------|-------|
| Bash execution | Sandboxed | ✅ Real |
| File writes | Not persisted | ✅ Persisted |
| Tool accuracy | Fabricated outputs | ✅ Accurate |

Our verification-auditor agent now correctly:
- Runs `pytest` and reports accurate test counts
- Writes 120-line verification reports to disk
- Detects placeholders with correct file:line locations

### Environment

- Claude Code: Latest as of 2026-01-05
- Tested across multiple plugin marketplaces
- Affects both JSON array and YAML list formats for `tools:`

### Workaround

If you need to restrict tools, use built-in `general-purpose` agent instead:

```python
Task(
  subagent_type="general-purpose",
  prompt="Your instructions here..."
)
```

But ideally, just omit the `tools:` field entirely.
