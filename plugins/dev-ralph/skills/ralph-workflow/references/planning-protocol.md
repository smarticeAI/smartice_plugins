# Planning Protocol

Structured interview protocol for the `/ralph-plan` command.

## Interview Structure

### 1. Task Understanding

First, understand what the developer wants to build:

```
Question: What are you building?
Options:
- Web application (frontend)
- API/backend service
- Full-stack application
- CLI tool
- Library/package
- Other
```

Follow-up based on selection to understand scope.

### 2. Core Features

Break down into major features:

```
Question: What are the main features?
(Multi-select or free text)
```

Each feature becomes a spec file.

### 3. Technology Stack

```
Question: What technology stack?

Language/Framework:
- React + TypeScript
- Vue 3 + TypeScript
- Node.js + Express
- Python + FastAPI
- Other

Build Tool:
- Vite
- webpack
- esbuild
- Other

Testing:
- Vitest
- Jest
- pytest
- Other
```

### 4. Architecture

```
Question: Architecture preferences?

Structure:
- Feature-based modules
- Layer-based (MVC, etc.)
- Clean architecture
- No preference

State Management (if frontend):
- React Context
- Redux
- Zustand
- Other
```

### 5. Quality Requirements

```
Question: Quality requirements?

Test Coverage:
- 80% (recommended)
- 90%
- 70%
- Custom

Type Checking:
- Strict mode
- Standard
- Minimal
```

## Spec Generation

For each feature identified:

1. Create spec file: `.ralph/specs/feature-[name].md`
2. Include:
   - Overview
   - Requirements (numbered list)
   - Acceptance criteria (checkboxes)
   - Edge cases
   - Dependencies

## Plan Generation

After specs are approved:

1. Analyze dependencies between specs
2. Order tasks by:
   - Dependencies (foundational first)
   - Complexity (simpler first builds momentum)
   - Value (high-value features prioritized)
3. Write to `.ralph/IMPLEMENTATION_PLAN.md`

## stdlib Population

Ask developer:

```
Question: Should I analyze for coding patterns?

Options:
- Yes, scan codebase and suggest patterns
- No, I'll add patterns manually later
- Skip stdlib for now
```

If yes, look for:
- Error handling patterns
- API call patterns
- State management patterns
- Testing patterns

## PROMPT.md Configuration

Based on answers:
- Set type-check command based on stack
- Set lint command
- Set test command
- Set coverage threshold
- Configure placeholder patterns

## Checklist Gate Display

After all files created:

```
Planning Complete! Checklist Gate:
═══════════════════════════════════

[x] .ralph/specs/*.md     - N spec files
[x] IMPLEMENTATION_PLAN.md - N items
[x] stdlib/*.md           - N patterns (or skipped)
[x] PROMPT.md             - Configured

Ready: /ralph-build
```
