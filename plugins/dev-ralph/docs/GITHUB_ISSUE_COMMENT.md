# GitHub Issue Comment: Plugin-Defined Agents Tool Execution

**For issue:** [#4462](https://github.com/anthropics/claude-code/issues/4462) or [#7032](https://github.com/anthropics/claude-code/issues/7032)

---

## Additional Finding: Plugin-Defined Agents vs Built-in Agents

I've done systematic testing and found that **plugin-defined agents** (agents defined in `.md` files in plugin directories) exhibit the sandboxing behavior, while **built-in agents** work correctly.

### Test Results

| Agent Type | Source | `tools:` field | Bash/Write persists? |
|------------|--------|----------------|---------------------|
| `general-purpose` | Built-in | N/A | ✅ Yes |
| `Explore` | Built-in | N/A | ✅ Yes |
| `pr-review-toolkit:code-reviewer` | Plugin (claude-code-plugins) | **Not specified** | ✅ Yes |
| `pr-review-toolkit:code-simplifier` | Plugin (claude-code-plugins) | **Not specified** | ✅ Yes |
| `plugin-dev:plugin-validator` | Plugin (claude-plugins-official) | `["Read", "Grep", "Glob", "Bash"]` | ❌ No |
| `plugin-dev:skill-reviewer` | Plugin (claude-plugins-official) | `["Read", "Grep", "Glob"]` | ❌ No |
| Custom `verification-auditor` | Plugin (smartice-plugin-market) | YAML list with Bash | ❌ No |

### Key Observation

**When the `tools:` field is explicitly specified in a plugin agent's YAML frontmatter, tools appear to run in a sandboxed/simulated mode** - the agent claims success but no filesystem changes occur.

**When the `tools:` field is omitted**, the agent inherits all tools and they execute correctly on the real filesystem.

### Evidence

1. `plugin-dev:plugin-validator` has `tools: ["Read", "Grep", "Glob", "Bash"]` - agent claims `echo "test" > file.txt` succeeded, but file doesn't exist
2. `pr-review-toolkit:code-reviewer` has **no** `tools:` field - same command actually creates the file
3. `design-council:opus-reviewer` has `tools: Read, Glob, Grep` (no Bash) - agent correctly says "I cannot execute bash commands"

### Hypothesis

When you specify an explicit `tools:` field:
- The tools are provided to the agent in a sandboxed/simulated execution context
- Tool calls are processed but don't affect the real filesystem

When you omit the `tools:` field:
- The agent inherits all tools from the parent context
- Tools execute in the real filesystem context

### Workaround

Use the built-in `general-purpose` agent instead of custom plugin agents for operations that need real filesystem access:

```python
Task(
  subagent_type="general-purpose",  # Works
  prompt="Your verification instructions here..."
)

# Instead of:
Task(
  subagent_type="my-plugin:my-agent",  # May be sandboxed
  prompt="..."
)
```

Or remove the `tools:` field from your plugin agent definition (untested - may require Claude Code restart to take effect).

### Environment

- Claude Code version: Latest as of 2026-01-05
- Tested across multiple plugin marketplaces (claude-code-plugins, claude-plugins-official, smartice-plugin-market)
- Affects both JSON array format (`tools: ["Read", "Bash"]`) and YAML list format

---

This may be related to or the same root cause as #13605 (Custom plugin subagents cannot access MCP tools).
