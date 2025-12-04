#!/usr/bin/env python3
"""
Gemini 3 Pro API client for frontend code generation.

Main entry point that orchestrates the modular components:
- validators: Input validation
- api_client: Gemini API interaction
- prompt_builder: Prompt construction
- response_parser: Response extraction

Reads design specification from stdin as JSON, calls Gemini API,
and outputs generated code to stdout.

Requires: GEMINI_API_KEY environment variable

Usage:
    echo '{"design_spec": "...", "framework": "react"}' | python gemini_generate.py

    # Or with the hyphenated name (symlink)
    echo '{"design_spec": "...", "framework": "react"}' | python gemini-generate.py
"""

import json
import sys
from typing import Optional

# Import modular components
from validators import (
    validate_api_key,
    validate_design_spec,
    get_api_key
)
from api_client import GeminiClient, APIConfig
from prompt_builder import build_initial_prompt
from response_parser import (
    extract_code,
    parse_structured_output,
    estimate_lines_of_code
)


def output_error(message: str, exit_code: int = 1) -> None:
    """Output error message as JSON and exit."""
    print(json.dumps({
        "error": True,
        "message": message
    }))
    sys.exit(exit_code)


def output_result(result: dict) -> None:
    """Output result as JSON."""
    print(json.dumps(result, indent=2))


def read_input() -> dict:
    """Read and parse JSON input from stdin."""
    try:
        input_data = sys.stdin.read()
        if not input_data.strip():
            output_error("No input provided. Expected JSON with design_spec.")

        return json.loads(input_data)

    except json.JSONDecodeError as e:
        output_error(f"Invalid JSON input: {str(e)}")


def main():
    """Main entry point."""
    # Step 1: Read input
    design_spec = read_input()

    # Step 2: Validate input
    validation_errors = validate_design_spec(design_spec)
    if validation_errors:
        output_error(f"Validation errors: {'; '.join(validation_errors)}")

    # Step 3: Validate API key
    is_valid, error = validate_api_key()
    if not is_valid:
        output_error(error)

    api_key = get_api_key()

    # Step 4: Build prompt
    spec_text = design_spec.get("design_spec") or design_spec.get("description", "")
    framework = design_spec.get("framework", "react")
    context = design_spec.get("context")
    feedback = design_spec.get("feedback")

    prompt = build_initial_prompt(
        design_spec=spec_text,
        framework=framework,
        context=context,
        feedback=feedback
    )

    # Step 5: Call Gemini API with auto-continuation for large responses
    client = GeminiClient(api_key)
    response = client.generate_with_continuation(prompt)

    if not response.success:
        output_error(response.error_message)

    # Step 6: Parse response
    parsed = extract_code(response.data)

    if parsed.error:
        output_error(parsed.error)

    # Step 7: Build result
    structured = parse_structured_output(response.data)
    lines_of_code = estimate_lines_of_code(response.data)

    result = {
        "error": False,
        "code": parsed.code,
        "finish_reason": parsed.finish_reason,
        "usage": parsed.usage,
        "lines_of_code": lines_of_code,
        "components_count": len(structured.get("components", [])),
        "has_styles": structured.get("styles") is not None
    }

    output_result(result)


if __name__ == "__main__":
    main()
