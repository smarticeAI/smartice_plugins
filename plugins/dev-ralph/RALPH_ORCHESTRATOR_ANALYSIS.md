# Ralph Orchestrator vs Official Plugin: Analysis Report

A comparative analysis of two Ralph Wiggum implementations.

---

## Executive Summary

| Aspect | Official Plugin | Ralph Orchestrator |
|--------|-----------------|-------------------|
| **Type** | Claude Code plugin (bash hooks) | Standalone Python framework |
| **Scope** | In-session loops | Multi-agent orchestration |
| **Complexity** | ~200 lines bash | ~400 lines Python + adapters |
| **Agents** | Claude only | Claude, Gemini, Q Chat, ACP |
| **State** | Markdown frontmatter | Git + filesystem + metrics |
| **Completion** | `<promise>` tags | `[x] TASK_COMPLETE` marker |
| **Cost Tracking** | None | Built-in token/cost limits |
| **Checkpointing** | None | Git commits every N iterations |

---

## Architecture Comparison

### Official Plugin: Hook-Based

```
┌─────────────────────────────────────────────────────────┐
│                    Claude Code Session                   │
│                                                          │
│  /ralph-loop "task" ──► setup-ralph-loop.sh             │
│         │                     │                          │
│         │              Creates state file:               │
│         │              .claude/ralph-loop.local.md       │
│         │                     │                          │
│         ▼                     ▼                          │
│  Claude works ──► Tries to exit ──► Stop Hook            │
│         ▲                              │                 │
│         │                              │                 │
│         └──────── Blocks & feeds ──────┘                 │
│                   same prompt back                       │
│                                                          │
│  Completion: <promise>DONE</promise> detected            │
└─────────────────────────────────────────────────────────┘
```

**Key characteristics:**
- Runs inside existing Claude Code session
- Uses bash scripts for setup and hooks
- State stored in markdown file with YAML frontmatter
- Completion via XML-style promise tags
- No external dependencies beyond Claude Code

### Ralph Orchestrator: Process-Based

```
┌─────────────────────────────────────────────────────────┐
│                  Ralph Orchestrator (Python)             │
│                                                          │
│  ralph run ──► orchestrator.py (async main loop)        │
│         │                                                │
│         ▼                                                │
│  ┌─────────────────────────────────────────────┐        │
│  │            Adapter Layer                      │        │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐        │        │
│  │  │ Claude  │ │ Gemini  │ │   ACP   │        │        │
│  │  │ Adapter │ │ Adapter │ │ Adapter │        │        │
│  │  └─────────┘ └─────────┘ └─────────┘        │        │
│  └─────────────────────────────────────────────┘        │
│         │                                                │
│         ▼                                                │
│  Agent subprocess ──► Response ──► Completion check      │
│         ▲                              │                 │
│         │                              │                 │
│         └──────── Next iteration ──────┘                 │
│                                                          │
│  Completion: [x] TASK_COMPLETE in PROMPT.md              │
└─────────────────────────────────────────────────────────┘
```

**Key characteristics:**
- Standalone process that spawns agent subprocesses
- Python async architecture
- Multi-agent support with auto-detection
- Git-based checkpointing
- Comprehensive metrics and cost tracking

---

## Feature Comparison

### Completion Detection

| Feature | Official Plugin | Ralph Orchestrator |
|---------|-----------------|-------------------|
| **Mechanism** | Promise tags in output | Marker in prompt file |
| **Format** | `<promise>DONE</promise>` | `[x] TASK_COMPLETE` |
| **Detection** | Hook parses Claude's output | Orchestrator reads prompt |
| **Who marks complete** | Claude (in response) | Claude (edits prompt file) |

**Analysis:** The orchestrator's approach is interesting - Claude must actively edit the PROMPT.md file to mark completion. This is a file-based verification that's harder to fake than just outputting text.

### Iteration Control

| Feature | Official Plugin | Ralph Orchestrator |
|---------|-----------------|-------------------|
| **Max iterations** | `--max-iterations N` | `-i N` (default: 100) |
| **Runtime limit** | None | `-t SECONDS` (default: 4 hours) |
| **Cost limit** | None | Token/cost thresholds |
| **Error limit** | State file corruption | 5 consecutive errors |

**Analysis:** Orchestrator has significantly more safety controls, including runtime and cost limits that the plugin lacks.

### State Management

| Feature | Official Plugin | Ralph Orchestrator |
|---------|-----------------|-------------------|
| **State file** | `.claude/ralph-loop.local.md` | `.agent/` directory |
| **Format** | YAML frontmatter + prompt | Multiple files (metrics, prompts, memory) |
| **Checkpointing** | None | Git commits every N iterations |
| **Recovery** | Start fresh if corrupted | Rollback to last checkpoint |
| **Context persistence** | Claude's memory | Agent scratchpad file |

**Analysis:** Orchestrator provides much more robust state management with git-based recovery. The plugin relies on Claude's session context which is lost on crash.

### Multi-Agent Support

| Feature | Official Plugin | Ralph Orchestrator |
|---------|-----------------|-------------------|
| **Claude** | ✅ (only) | ✅ |
| **Gemini** | ❌ | ✅ |
| **Q Chat** | ❌ | ✅ |
| **ACP Protocol** | ❌ | ✅ |
| **Auto-detection** | N/A | ✅ |

**Analysis:** Orchestrator is agent-agnostic, allowing you to use cheaper models for iteration-heavy tasks.

### Developer Experience

| Feature | Official Plugin | Ralph Orchestrator |
|---------|-----------------|-------------------|
| **Installation** | Pre-installed in Claude Code | `uv sync` or pip |
| **Invocation** | `/ralph-loop "prompt"` | `ralph run` |
| **Inline prompt** | ✅ First argument | ✅ `-p "prompt"` |
| **Status check** | `head .claude/ralph-loop.local.md` | `ralph status` |
| **Cancel** | `/cancel-ralph` | Ctrl+C or `ralph clean` |
| **Dry run** | ❌ | ✅ `-d` |
| **Verbose logging** | ❌ | ✅ `-v` |

---

## Unique Features

### Official Plugin Only

1. **In-session operation** - Works within existing Claude Code session
2. **Zero setup** - Already installed, just invoke
3. **Promise-based completion** - Semantic completion signals
4. **Lightweight** - No external dependencies

### Ralph Orchestrator Only

1. **Cost tracking** - Real-time token usage and spending limits
2. **Git checkpointing** - Automatic commits for recovery
3. **Multi-agent** - Switch between Claude, Gemini, Q Chat
4. **Agent scratchpad** - Persistent context across iterations
5. **Prompt archiving** - Tracks prompt evolution over time
6. **ACP protocol** - Generic agent integration standard
7. **Rich terminal UI** - Syntax highlighting, formatted output
8. **Metrics export** - JSON telemetry for analysis
9. **Docker/K8s support** - Production deployment options
10. **920+ tests** - Comprehensive test coverage

---

## Use Case Recommendations

### Use Official Plugin When:

- ✅ Quick, interactive development loops
- ✅ Tasks requiring Claude Code's tools (file editing, bash, etc.)
- ✅ You want zero setup overhead
- ✅ Task is likely to complete in <20 iterations
- ✅ Cost is not a primary concern

### Use Ralph Orchestrator When:

- ✅ Long-running autonomous tasks (hours/overnight)
- ✅ Need cost controls and limits
- ✅ Want to use cheaper models for some tasks
- ✅ Need robust recovery from failures
- ✅ Production/CI environment
- ✅ Want detailed metrics and logging
- ✅ Multi-project orchestration

---

## Integration Possibilities

### Combining Both Approaches

For LingLong Agent, we could:

1. **Use plugin for development** - Quick TDD loops during coding
2. **Use orchestrator for production** - Autonomous task execution for users

### Learning from Orchestrator for Our Design

Features worth adopting:

| Orchestrator Feature | Adaptation for LingLong |
|---------------------|------------------------|
| Cost tracking | Track API costs per task |
| Git checkpointing | Commit at phase boundaries |
| Agent scratchpad | Persist context in database |
| Metrics export | Send telemetry to analytics |
| Multi-agent | Route to different bots by task type |

---

## Completion Mechanism Deep Dive

### Plugin: Output-Based Detection

```bash
# stop-hook.sh
PROMISE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s')
if [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
  echo "✅ Ralph loop: Detected <promise>$COMPLETION_PROMISE</promise>"
  rm "$RALPH_STATE_FILE"
  exit 0
fi
```

**Pros:**
- Claude can signal completion semantically
- Promise text can describe what was achieved

**Cons:**
- Claude could output false promises
- Detection is regex-based

### Orchestrator: File-Based Detection

```python
# orchestrator.py
def check_completion(prompt_content: str) -> bool:
    """Check for [x] TASK_COMPLETE marker in prompt"""
    return "[x] TASK_COMPLETE" in prompt_content or "- [x] TASK_COMPLETE" in prompt_content
```

**Pros:**
- Claude must actively edit a file
- More intentional action required
- File changes are git-tracked

**Cons:**
- Less semantic (just a checkbox)
- Requires Claude to have file write access

---

## Recommendations for RALPH_DESIGN.md

Based on this analysis, additions to our design:

### 1. Hybrid Completion Detection

Combine both approaches:
```markdown
Completion requires BOTH:
1. Output: <promise>DONE</promise> in response
2. File: [x] TASK_COMPLETE in .claude/task-checklist.md

This dual-gate prevents accidental completion.
```

### 2. Cost Awareness

Add to prompt:
```markdown
## Cost Awareness

Track your iteration count. If approaching limit:
- Prioritize remaining critical work
- Document what's incomplete
- Don't waste iterations on polish
```

### 3. Checkpoint Behavior

Add to prompt:
```markdown
## Checkpoints

At natural boundaries (phase completion, major feature done):
- Commit changes: `git add . && git commit -m "Phase N complete"`
- This allows recovery if something goes wrong later
```

---

## Conclusion

| Dimension | Winner |
|-----------|--------|
| **Simplicity** | Official Plugin |
| **Robustness** | Ralph Orchestrator |
| **Flexibility** | Ralph Orchestrator |
| **Integration** | Official Plugin (Claude Code native) |
| **Production-readiness** | Ralph Orchestrator |
| **Developer experience** | Tie (different use cases) |

**Bottom line:** The official plugin is better for interactive development workflows. Ralph Orchestrator is better for autonomous, long-running, production tasks. For LingLong Agent, we should learn from both - using plugin-style hooks for UX with orchestrator-style safety controls.

---

*Created: 2026-01-02*
*Status: Analysis Complete*
