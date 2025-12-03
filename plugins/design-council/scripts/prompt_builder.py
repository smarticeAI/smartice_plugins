"""
Design spec to prompt conversion.

Handles:
- Building initial generation prompts
- Building iteration prompts with feedback
- Template management
"""

from typing import Optional


INITIAL_PROMPT_TEMPLATE = """You are an expert frontend developer. Generate production-ready code based on the following design specification.

## Framework
{framework}

## Design Specification
{design_spec}

{context_section}
{feedback_section}
## Requirements
1. Generate complete, working code - no placeholders or TODOs
2. Use distinctive typography (avoid Inter, Roboto, Arial, system fonts)
3. Create a cohesive color palette with CSS variables
4. Include appropriate animations and transitions
5. Ensure accessibility (aria-labels, semantic HTML, keyboard navigation)
6. Make it responsive for mobile and desktop
7. Follow modern best practices for the framework

## Output Format
Return the code in clearly labeled sections:
- Main component(s)
- Styles (if separate)
- Any utility functions
- Import statements needed

Generate the code now:"""


ITERATION_PROMPT_TEMPLATE = """The previous code generation scored {score}/10. Apply these specific fixes:

## Critical Fixes (must address)
{critical_fixes}

## Major Fixes (should address)
{major_fixes}

## Preserve (do not change)
{preserve_list}

## Original Design Specification
{design_spec}

## Framework
{framework}

IMPORTANT: Only make the changes listed above. The rest of the code is correct and should remain unchanged.

Regenerate with these fixes applied:"""


def build_initial_prompt(
    design_spec: str,
    framework: str = "react",
    context: Optional[str] = None,
    feedback: Optional[str] = None
) -> str:
    """
    Build the initial code generation prompt.

    Args:
        design_spec: The design specification text
        framework: Target framework (react, vue, svelte, html, nextjs)
        context: Optional existing codebase context
        feedback: Optional feedback from previous attempts

    Returns:
        Formatted prompt string
    """
    # Build context section
    context_section = ""
    if context:
        context_section = f"""## Existing Context
{context}

"""

    # Build feedback section
    feedback_section = ""
    if feedback:
        feedback_section = f"""## Feedback to Address (from previous iteration)
{feedback}

"""

    return INITIAL_PROMPT_TEMPLATE.format(
        framework=framework,
        design_spec=design_spec,
        context_section=context_section,
        feedback_section=feedback_section
    )


def build_iteration_prompt(
    design_spec: str,
    framework: str,
    score: float,
    critical_fixes: list,
    major_fixes: list,
    preserve_list: list
) -> str:
    """
    Build an iteration prompt with specific fixes.

    Args:
        design_spec: Original design specification
        framework: Target framework
        score: Previous review score
        critical_fixes: List of critical issues to fix
        major_fixes: List of major issues to fix
        preserve_list: List of elements to preserve

    Returns:
        Formatted iteration prompt
    """
    # Format critical fixes
    critical_str = "\n".join(
        f"{i+1}. {fix}" for i, fix in enumerate(critical_fixes)
    ) if critical_fixes else "None - all critical issues resolved"

    # Format major fixes
    major_str = "\n".join(
        f"{i+1}. {fix}" for i, fix in enumerate(major_fixes)
    ) if major_fixes else "None - all major issues resolved"

    # Format preserve list
    preserve_str = "\n".join(
        f"- {item}" for item in preserve_list
    ) if preserve_list else "- All current implementations are acceptable"

    return ITERATION_PROMPT_TEMPLATE.format(
        score=score,
        critical_fixes=critical_str,
        major_fixes=major_str,
        preserve_list=preserve_str,
        design_spec=design_spec,
        framework=framework
    )


def build_simple_prompt(description: str, framework: str = "react") -> str:
    """
    Build a simple prompt for quick generation without full spec.

    Args:
        description: Brief description of what to generate
        framework: Target framework

    Returns:
        Simple prompt string
    """
    return f"""Generate a {framework} component based on this description:

{description}

Requirements:
- Production-ready code
- Distinctive typography (avoid generic fonts)
- Accessible (ARIA labels, keyboard navigation)
- Responsive design
- Well-commented code

Generate the code:"""
