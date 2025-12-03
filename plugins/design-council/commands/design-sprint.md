---
description: "Orchestrate multi-model frontend design: Opus plans, Gemini codes, Opus reviews"
argument-hint: "[description] --rounds=3 --framework=react"
model: opus
---

# Design Sprint Orchestration

Execute a full design sprint with turn-based rounds of planning, generation, and review.

## Configuration

Parse arguments from $ARGUMENTS:
- **Description**: The main design request (required)
- **--rounds=N**: Maximum iteration rounds (default: 3)
- **--framework=X**: Target framework - react/vue/svelte/html/nextjs (default: react)
- **--strict**: Require score > 8 to pass (default: false, uses 7.0)
- **--output=DIR**: Output directory for generated files (default: current directory)
- **--context=TEXT**: Additional context about existing codebase

Arguments provided: $ARGUMENTS

## Phase 1: Design Specification

First, create a comprehensive design specification using the design-strategist agent.

Launch the **design-strategist** agent with the following task:

```
Create a frontend design specification for:

$ARGUMENTS

Framework target: [extracted --framework or react]
Additional context: [extracted --context or none]

Output a complete JSON design specification covering:
- Aesthetic direction and tone
- Typography (fonts, scale, line-heights)
- Color palette (primary, secondary, semantic, neutrals)
- Spacing system
- Motion/animation principles
- Component patterns
- Accessibility requirements

Be opinionated and distinctive - avoid generic "AI slop" patterns.
```

Store the design specification for use in subsequent phases.

## Phase 2: Code Generation (Gemini)

Call the Gemini API to generate frontend code.

Execute the gemini-generate.py script:

```bash
echo '{"design_spec": "[SPEC FROM PHASE 1]", "framework": "[FRAMEWORK]", "context": "[CONTEXT]"}' | python3 ${CLAUDE_PLUGIN_ROOT}/scripts/gemini-generate.py
```

If the API call fails, stop immediately and report the error (fail-fast).

Store the generated code for review.

## Phase 3: Code Review (Opus)

Launch the **opus-reviewer** agent to evaluate the generated code:

```
Review this generated frontend code against the design specification.

## Design Specification
[SPEC FROM PHASE 1]

## Generated Code
[CODE FROM PHASE 2]

Evaluate:
1. Design Fidelity (30%): Typography, colors, spacing match spec
2. Code Quality (25%): Structure, patterns, maintainability
3. Accessibility (25%): WCAG compliance, keyboard nav, ARIA
4. Completeness (20%): All features, no placeholders, responsive

Output structured JSON with:
- Scores for each dimension (1-10)
- Overall weighted score
- Pass/fail decision (threshold: 7.0, or 8.0 if --strict)
- List of issues (critical/major/minor)
- Specific fix recommendations
```

## Phase 4: Adaptation (if not passed)

If the review score is below threshold and rounds remain:

Launch the **adaptation-advisor** agent:

```
Analyze this code review and prepare iteration guidance.

## Review Results
[REVIEW FROM PHASE 3]

## Current Code
[CODE FROM PHASE 2]

## Design Specification
[SPEC FROM PHASE 1]

## Round Status
Current round: [N] of [MAX_ROUNDS]

Provide:
1. Priority fixes for next iteration
2. Elements to preserve (working code)
3. Specific Gemini prompt for regeneration
4. User progress message
```

Then return to Phase 2 with the updated prompt.

## Phase 5: Output

When the review passes OR maximum rounds reached:

### If Passed:

Present the final code to the user:

```
Design Sprint Complete!

Final Score: [SCORE]/10
Rounds Used: [N] of [MAX_ROUNDS]

Quality Summary:
- Design Fidelity: [SCORE]/10
- Code Quality: [SCORE]/10
- Accessibility: [SCORE]/10
- Completeness: [SCORE]/10

Generated Files:
[LIST OF COMPONENTS/FILES]
```

Ask user to confirm output directory, then write files using the Write tool.

### If Maximum Rounds Reached (not passed):

```
Design Sprint finished after [MAX_ROUNDS] rounds.

Final Score: [SCORE]/10 (below [THRESHOLD] threshold)

Remaining Issues:
[LIST CRITICAL/MAJOR ISSUES]

Options:
1. Accept code with known limitations
2. Continue with manual iteration
3. Restart with simplified requirements

The generated code is available below for manual use if desired.
```

## Round Tracking

Display progress at each phase:

```
═══════════════════════════════════════════════════
  DESIGN SPRINT: Round [N] of [MAX_ROUNDS]
═══════════════════════════════════════════════════

[Current Phase]: [Status]
Score Target: [THRESHOLD]
```

## Error Handling

### Gemini API Failure
```
ERROR: Gemini API call failed

[ERROR MESSAGE]

The design sprint cannot continue without code generation.

Troubleshooting:
1. Verify GEMINI_API_KEY environment variable is set
2. Check API quota at https://makersuite.google.com/
3. Retry with: /design-sprint [same arguments]
```

### Invalid Arguments
```
ERROR: Invalid arguments

Usage: /design-sprint "[description]" [options]

Options:
  --rounds=N      Maximum rounds (default: 3)
  --framework=X   Target framework (default: react)
  --strict        Require score > 8 to pass
  --output=DIR    Output directory
  --context=TEXT  Additional codebase context

Example:
/design-sprint "Dashboard with charts and data tables" --framework=react --rounds=3
```

## File Output Structure

When writing files, organize as:

```
[output-dir]/
├── components/
│   ├── [ComponentName].tsx
│   └── ...
├── styles/
│   └── globals.css (or tailwind additions)
├── hooks/
│   └── [useHookName].ts (if needed)
└── utils/
    └── [utilName].ts (if needed)
```

## Example Execution

```
User: /design-sprint "Modern dashboard for agricultural sensor data with
      real-time charts, dark theme, and mobile support" --rounds=3 --framework=react

═══════════════════════════════════════════════════
  DESIGN SPRINT: Round 1 of 3
═══════════════════════════════════════════════════

[Design Strategist]: Creating specification...
✓ Aesthetic: Industrial-organic hybrid
✓ Typography: Space Grotesk + IBM Plex Mono
✓ Colors: Forest green primary, amber alerts

[Gemini 3 Pro]: Generating code...
✓ Generated 12 components, 847 lines

[Opus Reviewer]: Evaluating quality...
- Design Fidelity: 7/10
- Code Quality: 8/10
- Accessibility: 5/10 (critical issues)
- Completeness: 7/10
Overall: 6.7/10 - NEEDS ITERATION

[Adaptation Advisor]: Preparing round 2...
Focus: Accessibility fixes (focus states, ARIA labels)

═══════════════════════════════════════════════════
  DESIGN SPRINT: Round 2 of 3
═══════════════════════════════════════════════════

[Gemini 3 Pro]: Regenerating with fixes...
✓ Updated 12 components

[Opus Reviewer]: Re-evaluating...
- Design Fidelity: 8/10
- Code Quality: 8/10
- Accessibility: 8/10
- Completeness: 8/10
Overall: 8.0/10 - PASSED!

═══════════════════════════════════════════════════
  DESIGN SPRINT COMPLETE
═══════════════════════════════════════════════════

Final Score: 8.0/10
Rounds Used: 2 of 3

Ready to write files to ./components/
Proceed? (y/n)
```
