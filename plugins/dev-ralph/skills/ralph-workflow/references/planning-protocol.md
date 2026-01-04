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
   - Verification checklist (bash commands)
   - Edge cases
   - Dependencies

## Writing Verification Checklists

**Define success before implementation.** Every spec should include executable bash commands that verify the feature is properly integrated. This follows TDD principles: know what success looks like before writing code.

### Principles

1. **Executable Commands**: Each verification must be a bash command returning 0 on success
2. **Integration Focus**: Verify new code is wired into the existing system
3. **Specific Patterns**: Use grep patterns that match actual code constructs
4. **Multiple Layers**: Check file existence, imports, registration, and usage

### Common Verification Patterns

```bash
# File existence
test -f path/to/new_file.ts

# Pattern exists in file (silent mode)
grep -q "pattern" file.ts

# Pattern with line numbers (for debugging)
grep -n "pattern" file.ts | grep -q "."

# Count matches (at least one required)
grep -c "pattern" file.ts | grep -q "^[1-9]"

# Multiple patterns (all must exist)
grep -q "pattern1" file.ts && grep -q "pattern2" file.ts
```

### Framework-Specific Patterns

**Node.js/Express:**
```bash
# Route is defined
grep -q "router\.\(get\|post\|put\|delete\)" src/routes/feature.ts
# Route is registered in app
grep -q "app.use.*featureRouter" src/app.ts
```

**Python/FastAPI:**
```bash
# Endpoint exists
grep -q "@app\.\(get\|post\|put\|delete\)" src/routers/feature.py
# Router included in main app
grep -q "app.include_router.*feature" src/main.py
```

**React/TypeScript:**
```bash
# Component is exported
grep -q "export.*ComponentName" src/components/Component.tsx
# Component is used
grep -q "<ComponentName" src/App.tsx
# Hook is exported and used
grep -q "export.*useFeature" src/hooks/useFeature.ts
```

**Go:**
```bash
# Handler function exists
grep -q "func.*HandlerName" internal/handlers/feature.go
# Handler is registered
grep -q "HandleFunc.*handlerName" cmd/server/main.go
```

**Claude Agent SDK:**
```bash
# Tool is defined
grep -q "name.*tool_name" src/agent.py
# Tool is registered with agent
grep -q "tools=\[.*tool_name" src/agent.py
```

### Interview Questions for Verification

During the planning interview, ask:

```
Question: Where should new components be registered?

Entry Points:
- Main application file (src/main.ts, src/app.py)
- Router configuration
- Dependency injection container
- Other (specify)
```

```
Question: What patterns indicate successful integration?

Integration Signals:
- Import statements
- Function/class registration
- Route/endpoint definitions
- Test file creation
- Other (specify)
```

### Auto-Detection

Detect project type to generate appropriate patterns:

| File Present | Project Type | Suggested Patterns |
|--------------|--------------|-------------------|
| `package.json` | Node.js | Express routes, React components |
| `pyproject.toml` | Python | FastAPI endpoints, imports |
| `go.mod` | Go | Handler functions, routes |
| `Cargo.toml` | Rust | Module declarations, use statements |

## Plan Generation

After specs are approved:

1. Analyze dependencies between specs
2. Order tasks by:
   - Dependencies (foundational first)
   - Complexity (simpler first builds momentum)
   - Value (high-value features prioritized)
3. Write to `.ralph/IMPLEMENTATION_PLAN.md`

## stdlib Definition

**stdlib is actual code, defined during planning via specs.**

Ask developer:

```
Question: What reusable utilities/patterns does this project need?

Examples:
- Error handling utilities (Result types, error classes)
- API client wrappers
- Validation helpers
- Common data transformations
- Logging/telemetry
- Testing utilities

Options:
- Yes, define stdlib modules now
- No, add them during build as needed
- Skip stdlib (use framework defaults)
```

If "Yes", for each module:
1. Ask for module name (e.g., "errors", "validation", "api-client")
2. Ask for purpose (what problem does it solve?)
3. Ask for key functions/classes needed
4. Ask for patterns to follow (e.g., "always return Result, never throw")

Create `specs/stdlib/[module-name].md` for each using the stdlib-spec template.

**Why stdlib matters:**
- Single source of truth for patterns
- Features import from stdlib, don't duplicate utilities
- When Ralph generates wrong patterns, update stdlib spec → Ralph regenerates
- Ralph builds stdlib BEFORE features

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

[x] .ralph/specs/stdlib/*.md   - N stdlib modules (or skipped)
[x] .ralph/specs/*.md          - N feature specs
[x] IMPLEMENTATION_PLAN.md     - stdlib as Phase 1, features after
[x] PROMPT.md                  - Configured

Ready: /ralph-build
```

**Note:** Ralph will build `src/stdlib/` from specs BEFORE building features.
