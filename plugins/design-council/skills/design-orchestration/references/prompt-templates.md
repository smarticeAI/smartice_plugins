# Prompt Templates Reference

Effective prompt patterns for each agent in the Design Council workflow.

## Design Strategist Prompts

### Basic Design Request

```
Create a design specification for: [DESCRIPTION]

Consider:
- Target audience: [AUDIENCE]
- Tone/mood: [TONE]
- Key features: [FEATURES]
- Technical constraints: [CONSTRAINTS]

Output a complete design spec with typography, colors, spacing, motion, and component patterns.
```

### Design with Existing Context

```
Create a design specification for: [DESCRIPTION]

Existing design context:
- Current color palette: [COLORS]
- Typography in use: [FONTS]
- Design system: [SYSTEM NAME]

The new design should complement and extend the existing patterns while introducing fresh elements for [NEW FEATURE].
```

### Redesign/Refresh

```
Create an updated design specification for: [EXISTING COMPONENT/PAGE]

Current issues:
- [ISSUE 1]
- [ISSUE 2]

Goals for redesign:
- [GOAL 1]
- [GOAL 2]

Preserve:
- [ELEMENT TO KEEP]
- [ANOTHER ELEMENT]

Provide a design spec that addresses the issues while maintaining brand consistency.
```

## Gemini Code Generation Prompts

### Initial Generation

```
You are an expert frontend developer. Generate production-ready code based on this design specification:

## Framework
[FRAMEWORK]

## Design Specification
[FULL SPEC JSON]

## Requirements
1. Generate complete, working code - no placeholders or TODOs
2. Use the exact fonts, colors, and spacing from the spec
3. Include proper accessibility (aria-labels, semantic HTML, keyboard nav)
4. Make responsive for mobile, tablet, and desktop
5. Add smooth transitions following the motion spec

## Output Format
Provide clearly labeled sections:
- Component code
- Styles (CSS/Tailwind)
- Any utility functions
- Import statements

Generate the code now.
```

### Iteration Generation

```
The previous code generation scored [SCORE]/10. Apply these specific fixes:

## Critical Fixes (must address)
1. [FIX 1 with code example]
2. [FIX 2 with code example]

## Major Fixes (should address)
1. [FIX 3]
2. [FIX 4]

## Preserve (do not change)
- [WORKING ELEMENT 1]
- [WORKING ELEMENT 2]

IMPORTANT: Only make the changes listed above. The rest of the code is correct and should remain unchanged.

Regenerate with these fixes applied.
```

### Framework-Specific Hints

**React**:
```
Use React 18+ patterns:
- Functional components with hooks
- useState, useEffect, useMemo as needed
- Proper prop typing (TypeScript if applicable)
- React.forwardRef for input components
```

**Vue 3**:
```
Use Vue 3 Composition API:
- <script setup> syntax
- ref(), computed(), watch()
- defineProps(), defineEmits()
- Template refs for DOM access
```

**Svelte**:
```
Use Svelte 4 patterns:
- Reactive declarations ($:)
- Component props with export let
- Stores for shared state
- Transitions and animations
```

## Opus Reviewer Prompts

### Standard Review

```
Review this generated frontend code against the design specification.

## Design Specification
[SPEC JSON]

## Generated Code
[CODE]

Evaluate across these dimensions:
1. Design Fidelity (30%): Does code match the spec?
2. Code Quality (25%): Is it well-structured and maintainable?
3. Accessibility (25%): Is it accessible to all users?
4. Completeness (20%): Is it production-ready?

Provide:
- Score (1-10) for each dimension with evidence
- List of issues (critical/major/minor)
- Specific fix recommendations
- Overall pass/fail (threshold: 7.0)

Output as structured JSON.
```

### Focused Review

```
Review this code focusing specifically on [FOCUS AREA]:

## Code
[CODE]

Concentrate on:
- [SPECIFIC ASPECT 1]
- [SPECIFIC ASPECT 2]

Provide detailed feedback on these aspects only.
```

### Comparative Review

```
Compare these two code versions and determine which better implements the design spec:

## Version A
[CODE A]

## Version B
[CODE B]

## Design Specification
[SPEC]

Analyze:
1. Which better matches the design spec?
2. Which has better code quality?
3. Which is more accessible?
4. Recommendation: Use Version A or B?
```

## Adaptation Advisor Prompts

### Standard Adaptation

```
Analyze this code review and prepare iteration guidance:

## Review Results
[REVIEW JSON]

## Current Code
[CODE]

## Design Specification
[SPEC]

Provide:
1. Summary of current status
2. Prioritized list of fixes
3. Specific iteration prompt for Gemini
4. Elements to preserve
5. User-facing progress message

Output as structured JSON.
```

### Final Round Adaptation

```
This is the final iteration round. Analyze the review and determine:

## Review Results
[REVIEW JSON]

1. If score >= 7.0: Prepare final code for output
2. If score < 7.0: Identify the most critical remaining issues

For passing code, provide:
- Summary of achieved quality
- Any minor improvements user could make manually
- File structure recommendation

For failing code, provide:
- Honest assessment of gaps
- Recommendation: Accept with caveats or restart with simpler spec
```

## User Communication Templates

### Sprint Start

```
Starting Design Sprint for: [DESCRIPTION]

Configuration:
- Framework: [FRAMEWORK]
- Rounds: [N]
- Strict mode: [YES/NO]

Phase 1: Creating design specification...
```

### Round Progress

```
**Round [N] of [TOTAL]**

[AGENT] is working...

Previous score: [SCORE]
Target: 7.0+ to pass

Key focus this round:
- [FOCUS ITEM 1]
- [FOCUS ITEM 2]
```

### Sprint Complete (Pass)

```
Design Sprint Complete!

Final Score: [SCORE]/10
Rounds Used: [N] of [TOTAL]

Quality Summary:
- Design Fidelity: [SCORE]
- Code Quality: [SCORE]
- Accessibility: [SCORE]
- Completeness: [SCORE]

Generated Files:
- [FILE 1]
- [FILE 2]

Ready to write to: [OUTPUT DIR]
Proceed? (y/n)
```

### Sprint Complete (Fail)

```
Design Sprint finished after [N] rounds.

Final Score: [SCORE]/10 (below 7.0 threshold)

The code has these remaining issues:
- [ISSUE 1]
- [ISSUE 2]

Options:
1. Accept code with known issues
2. Restart with simplified requirements
3. Manual iteration (code provided below)

What would you like to do?
```

## Error Handling Prompts

### API Error

```
Gemini API Error: [ERROR MESSAGE]

Troubleshooting:
1. Check GEMINI_API_KEY is set correctly
2. Verify API quota has not been exceeded
3. Check network connectivity

To retry: /design-sprint --retry
```

### Timeout

```
Code generation timed out after [N] seconds.

This can happen with:
- Very complex designs
- Slow network connections
- API rate limiting

Options:
1. Retry with same spec
2. Simplify design requirements
3. Split into smaller components
```
