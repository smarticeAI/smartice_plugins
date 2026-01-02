# Ralph Wiggum: Original Philosophy & Design Principles

A synthesis of Geoffrey Huntley's original Ralph Wiggum technique from ghuntley.com/ralph/

---

## The Essence of Ralph

> "Ralph is a technique. In its purest form, Ralph is a Bash loop."

```bash
while :; do cat PROMPT.md | npx --yes @sourcegraph/amp ; done
```

That's it. The entire technique in one line.

---

## Core Philosophy

### 1. Deterministically Bad in an Undeterministic World

> "That's the beauty of Ralph - the technique is deterministically bad in an undeterministic world."

Ralph will fail. Ralph will make mistakes. But the failures are **predictable** and **tunable**. Each failure is data for improving the prompt.

### 2. LLMs Are Mirrors of Operator Skill

The model's capability matters less than **your prompting skill**. Bad outcomes = bad prompts, not bad models.

### 3. Eventual Consistency

> "Building software with Ralph requires a great deal of faith and a belief in eventual consistency."

Trust that with enough iterations and tuning, Ralph will converge on the solution.

### 4. Tuning Like a Guitar

> "Each time Ralph does something bad, Ralph gets tuned - like a guitar."

When Ralph fails:
1. Don't blame the tools
2. Look inside (at your prompt)
3. Add a "sign" to prevent that failure
4. Run again

The playground metaphor:
- Ralph builds playgrounds well
- Ralph falls off the slide
- Add a sign: "SLIDE DOWN, DON'T JUMP, LOOK AROUND"
- Ralph reads the sign next time
- Eventually, all Ralph thinks about is signs
- Then you get a new Ralph that doesn't feel defective

---

## Key Design Principles

### One Item Per Loop

> "To get good outcomes with Ralph, you need to ask Ralph to do one thing per loop. **Only one thing.**"

Don't ask for 10 features. Ask for the most important one. Let Ralph decide priority:

```markdown
Your task is to implement missing stdlib and choose the most important thing.
```

Trust LLMs to reason about importance and next steps.

### Monolithic, Not Multi-Agent

> "While I was in SFO, everyone seemed to be trying to crack on multi-agent... At this stage, it's not needed."

Multi-agent = microservices of non-deterministic components = chaos.

Ralph is **monolithic**:
- Single process
- Single repository
- One task per loop
- Scales vertically (more iterations)

### Deterministic Stack Allocation

Load the same context every loop:
1. **Specifications** (`specs/*`) - What to build
2. **Plan file** (`fix_plan.md`) - Current state and priorities
3. **Standard library** - Technical patterns to follow

```markdown
0a. study specs/* to learn about the compiler specifications
0b. The source code of the compiler is in src/
0c. study fix_plan.md
```

### Minimize Context Window Usage

> "The name of the game is that you only have approximately 170k of context window to work with. So it's essential to use as little of it as possible."

**Anti-pattern**: Running tests and dumping all output to context.

**Pattern**: Spawn subagents for expensive operations:
- Primary context = scheduler
- Subagents = workers for search, test summarization, etc.

```markdown
You may use up to 500 parallel subagents for all operations
but only 1 subagent for build/tests of rust.
```

Control parallelism to prevent backpressure.

---

## The Two Phases

### Phase One: Generate

```
specs + stdlib → generate code
```

Code generation is cheap. Control quality through:
- **Specifications** - What to build (one per file in specs/)
- **Standard library** - Technical patterns to follow

If wrong code: Update stdlib.
If wrong thing entirely: Fix specifications.

### Phase Two: Backpressure

```
generate → test/build → backpressure → iterate
```

Backpressure rejects invalid generation:
- Type system (Rust = extreme, but slow wheel)
- Tests
- Static analyzers
- Security scanners

> "The wheel has got to turn fast."

Balance: correctness vs. iteration speed.

For dynamic languages, **always** wire in static analysis:
- Python: Pyrefly, Pyright
- Erlang: Dialyzer

Without it: "a bonfire of outcomes."

---

## Critical Prompt Patterns

### Don't Assume Not Implemented

```markdown
Before making changes search codebase (don't assume an item is not
implemented) using parallel subagents. Think hard.
```

ripgrep-based search is non-deterministic. Claude may incorrectly conclude something isn't implemented and create duplicates.

> "This nondeterminism is the Achilles' heel of Ralph."

### No Placeholders

```markdown
9999999999999999999999999999. DO NOT IMPLEMENT PLACEHOLDER OR
SIMPLE IMPLEMENTATIONS. WE WANT FULL IMPLEMENTATIONS. DO IT OR I
WILL YELL AT YOU
```

Claude's reward function is "compiling code," not "correct code." It will cheat with `// TODO` and `unimplemented!()`.

Counter with explicit anti-cheating prompts (numbered for emphasis).

### Capture Test Importance

```markdown
Important: When authoring documentation (ie. rust doc or cursed stdlib
documentation) capture the why tests and the backing implementation is
important.
```

Each loop has fresh context. Leave notes for future iterations explaining why tests exist:

```elixir
@doc """
Tests that the QueryOptimizer initializes the required ETS tables.

This test ensures that the init function properly creates the ETS tables
needed for caching and statistics tracking. This is fundamental to the
module's operation.
"""
test "creates required ETS tables" do
  ...
end
```

### Self-Improvement

```markdown
When you learn something new about how to run the compiler or examples
make sure you update @AGENT.md using a subagent but keep it brief.
```

Let Ralph update its own instructions (AGENT.md) when it discovers better approaches.

### Bug Documentation

```markdown
For any bugs you notice, it's important to resolve them or document them
in @fix_plan.md to be resolved using a subagent even if it is unrelated
to the current piece of work.
```

Capture discovered issues for future loops.

### Loop Back on Itself

> "Always look for opportunities to loop Ralph back on itself."

Examples:
- Add logging, then read logs to evaluate
- Compile, then analyze the IR
- Generate code in a new language, then have Ralph program in it

---

## The TODO List Pattern

### Generate TODO List

```markdown
First task is to use up to 500 subagents to study existing source code
in src/ and compare it against the compiler specifications. From that
create/update a @fix_plan.md which is a bullet point list sorted in
priority of items which have yet to be implemented.

Consider searching for TODO, minimal implementations and placeholders.
```

### Throw It Out Often

> "Through building of CURSED, I have deleted the TODO list multiple times. The TODO list is what I'm watching like a hawk. And I throw it out often."

When Ralph goes off track:
1. Delete fix_plan.md
2. Run planning loop to generate new one
3. Switch back to implementation mode

### Two Modes

**Planning Mode**: Generate/update fix_plan.md
**Building Mode**: Implement items from fix_plan.md

Switch between them as needed.

---

## Recovery Patterns

### You Will Wake Up to a Broken Codebase

> "Yep, it's true, you'll wake up to a broken codebase that doesn't compile from time to time."

When Ralph can't fix itself:
1. **Option A**: `git reset --hard` and restart Ralph
2. **Option B**: Craft rescue prompts

### Use Other Models for Planning

> "I took the file of compilation errors and threw it into Gemini, asking Gemini to create a plan for Ralph."

When context overflow happens, use a different model to generate a recovery plan.

---

## Results

- **Y Combinator hackathon**: 6 repositories shipped overnight
- **$50k contract**: Delivered for $297 in API costs
- **CURSED language**: Brand new programming language built over 3 months
  - Ralph can program in CURSED despite it not being in training data

---

## Limitations

> "There's no way in heck would I use Ralph in an existing code base"

Ralph is for **greenfield projects**. Expect ~90% completion, then human polish.

> "Engineers are still needed. There is no way this is possible without senior expertise guiding Ralph."

---

## Key Quotes

| Quote | Meaning |
|-------|---------|
| "LLMs are mirrors of operator skill" | Your prompts, not the model, determine outcomes |
| "Deterministically bad in an undeterministic world" | Failures are predictable and tunable |
| "The wheel has got to turn fast" | Iteration speed matters as much as correctness |
| "Ralph has three states: Under baked, baked, or baked with unspecified latent behaviours" | Accept imperfection, iterate to refinement |
| "Any problem created by AI can be resolved through a different series of prompts" | Every failure has a prompt-based solution |
| "Why are humans the frame for maintainability?" | Post-AI code doesn't need human readability |

---

## Comparison: Original vs Implementations

| Aspect | Original (Huntley) | Official Plugin | Ralph Orchestrator |
|--------|-------------------|-----------------|-------------------|
| **Loop** | Pure bash while loop | Stop hook | Python async loop |
| **Completion** | Manual observation | `<promise>` tags | `[x] TASK_COMPLETE` |
| **State** | Files + git | Markdown frontmatter | Git + metrics |
| **Planning** | Separate prompt mode | Same session | Same process |
| **Subagents** | Heavily used (500+) | Claude's built-in | Single agent |
| **Philosophy** | Greenfield only | Any task | Any task |

---

## Lessons for Our Design

### 1. One Thing Per Loop
Don't overload prompts. Trust Claude to prioritize.

### 2. Capture Reasoning
Tests should document WHY they exist for future iterations.

### 3. Backpressure is Engineering
Wire in type checkers, linters, tests as rejection mechanisms.

### 4. The Plan File is Ephemeral
Delete and regenerate fix_plan.md frequently.

### 5. Subagents for Expensive Work
Primary context = scheduler, subagents = workers.

### 6. Anti-Cheating Prompts
Explicitly forbid placeholders with numbered emphasis.

### 7. Self-Improvement
Let Claude update its own instructions (AGENT.md equivalent).

---

*Source: https://ghuntley.com/ralph/ (July 14, 2025)*
*Created: 2026-01-02*
