"""
Input validation and API key checks.

Validates:
- GEMINI_API_KEY environment variable
- Design specification structure
- Framework selection
"""

import os
from typing import List, Optional


SUPPORTED_FRAMEWORKS = ["react", "vue", "svelte", "html", "nextjs"]


def validate_api_key() -> tuple[bool, Optional[str]]:
    """
    Check if GEMINI_API_KEY environment variable is set.

    Returns:
        Tuple of (is_valid, error_message)
    """
    api_key = os.environ.get("GEMINI_API_KEY")

    if not api_key:
        return False, (
            "GEMINI_API_KEY environment variable not set. "
            "Please set it with: export GEMINI_API_KEY='your-api-key'\n"
            "Get your API key from: https://makersuite.google.com/app/apikey"
        )

    if len(api_key) < 20:
        return False, "GEMINI_API_KEY appears to be invalid (too short)"

    return True, None


def validate_design_spec(spec: dict) -> List[str]:
    """
    Validate design specification structure.

    Args:
        spec: Design specification dictionary

    Returns:
        List of error messages (empty if valid)
    """
    errors = []

    if not isinstance(spec, dict):
        return ["Design spec must be a dictionary"]

    # Check for required field
    if not spec.get("design_spec") and not spec.get("description"):
        errors.append("Missing 'design_spec' or 'description' field")

    # Validate framework if provided
    framework = spec.get("framework")
    if framework:
        is_valid, error = validate_framework(framework)
        if not is_valid:
            errors.append(error)

    # Check for iteration context
    feedback = spec.get("feedback")
    if feedback and not isinstance(feedback, str):
        errors.append("'feedback' must be a string")

    context = spec.get("context")
    if context and not isinstance(context, str):
        errors.append("'context' must be a string")

    return errors


def validate_framework(framework: str) -> tuple[bool, Optional[str]]:
    """
    Validate framework selection.

    Args:
        framework: Framework name

    Returns:
        Tuple of (is_valid, error_message)
    """
    if not framework:
        return True, None  # Default will be used

    framework_lower = framework.lower().strip()

    if framework_lower not in SUPPORTED_FRAMEWORKS:
        return False, (
            f"Unsupported framework '{framework}'. "
            f"Supported: {', '.join(SUPPORTED_FRAMEWORKS)}"
        )

    return True, None


def get_api_key() -> str:
    """
    Get the API key from environment.

    Returns:
        API key string

    Raises:
        ValueError: If API key is not set
    """
    is_valid, error = validate_api_key()
    if not is_valid:
        raise ValueError(error)

    return os.environ["GEMINI_API_KEY"]
