"""
Extract code and metadata from API responses.

Handles:
- Extracting generated code from Gemini responses
- Extracting reasoning/explanations
- Parsing structured output
"""

import re
from typing import Optional
from dataclasses import dataclass


@dataclass
class ParsedResponse:
    """Structured parsed response."""
    code: str
    reasoning: Optional[str] = None
    finish_reason: str = "UNKNOWN"
    usage: Optional[dict] = None
    error: Optional[str] = None


def extract_code(response: dict) -> ParsedResponse:
    """
    Extract generated code from Gemini API response.

    Args:
        response: Raw API response dictionary

    Returns:
        ParsedResponse with extracted code
    """
    try:
        candidates = response.get("candidates", [])
        if not candidates:
            return ParsedResponse(
                code="",
                error="No candidates in response"
            )

        content = candidates[0].get("content", {})
        parts = content.get("parts", [])

        if not parts:
            return ParsedResponse(
                code="",
                error="No parts in response content"
            )

        generated_text = parts[0].get("text", "")
        finish_reason = candidates[0].get("finishReason", "UNKNOWN")
        usage = response.get("usageMetadata", {})

        return ParsedResponse(
            code=generated_text,
            finish_reason=finish_reason,
            usage=usage
        )

    except (KeyError, IndexError) as e:
        return ParsedResponse(
            code="",
            error=f"Failed to parse response: {str(e)}"
        )


def extract_reasoning(response: dict) -> Optional[str]:
    """
    Extract reasoning/explanation from response if present.

    Args:
        response: Raw API response dictionary

    Returns:
        Reasoning text or None
    """
    parsed = extract_code(response)

    if parsed.error:
        return None

    text = parsed.code

    # Look for reasoning patterns
    patterns = [
        r"## Reasoning\n(.*?)(?=##|\Z)",
        r"## Explanation\n(.*?)(?=##|\Z)",
        r"### Why\n(.*?)(?=###|\Z)",
    ]

    for pattern in patterns:
        match = re.search(pattern, text, re.DOTALL)
        if match:
            return match.group(1).strip()

    return None


def parse_structured_output(response: dict) -> dict:
    """
    Parse response into structured output format.

    Args:
        response: Raw API response dictionary

    Returns:
        Dictionary with code, components, styles, etc.
    """
    parsed = extract_code(response)

    if parsed.error:
        return {
            "error": True,
            "message": parsed.error
        }

    text = parsed.code

    # Extract different sections
    result = {
        "error": False,
        "raw_code": text,
        "components": [],
        "styles": None,
        "utilities": None,
        "imports": None,
        "finish_reason": parsed.finish_reason,
        "usage": parsed.usage
    }

    # Extract component sections
    component_pattern = r"```(?:tsx?|jsx?|vue|svelte)\n(.*?)```"
    components = re.findall(component_pattern, text, re.DOTALL)
    result["components"] = components

    # Extract CSS/styles
    style_pattern = r"```(?:css|scss|sass)\n(.*?)```"
    styles = re.findall(style_pattern, text, re.DOTALL)
    if styles:
        result["styles"] = "\n\n".join(styles)

    # Extract utility functions
    util_pattern = r"## (?:Utility|Utils|Helpers).*?```(?:ts|js)\n(.*?)```"
    utils = re.findall(util_pattern, text, re.DOTALL)
    if utils:
        result["utilities"] = "\n\n".join(utils)

    # Extract imports
    import_pattern = r"^import\s+.*$"
    imports = re.findall(import_pattern, text, re.MULTILINE)
    if imports:
        result["imports"] = "\n".join(imports)

    return result


def extract_code_blocks(text: str) -> list[dict]:
    """
    Extract all code blocks from text with their languages.

    Args:
        text: Text containing code blocks

    Returns:
        List of dicts with 'language' and 'code' keys
    """
    pattern = r"```(\w*)\n(.*?)```"
    matches = re.findall(pattern, text, re.DOTALL)

    return [
        {"language": lang or "text", "code": code.strip()}
        for lang, code in matches
    ]


def estimate_lines_of_code(response: dict) -> int:
    """
    Estimate total lines of code in response.

    Args:
        response: Raw API response dictionary

    Returns:
        Estimated line count
    """
    parsed = extract_code(response)

    if parsed.error:
        return 0

    code_blocks = extract_code_blocks(parsed.code)

    total_lines = sum(
        len(block["code"].split("\n"))
        for block in code_blocks
    )

    return total_lines
