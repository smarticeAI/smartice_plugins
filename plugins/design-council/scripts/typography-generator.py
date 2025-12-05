#!/usr/bin/env python3
"""
Generate 4 typography pairing variations using Gemini API.

Takes mood, aesthetic, project description and generates font pairings.
Outputs JSON with 4 typography options for user selection.

Usage:
    echo '{"mood": "Warm & Cozy", "aesthetic": "minimalist", "project": "pomodoro timer"}' | python typography-generator.py
"""

import json
import sys
from typing import Optional

from api_client import GeminiClient, APIConfig
from validators import validate_api_key, get_api_key


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
            output_error("No input provided.")
        return json.loads(input_data)
    except json.JSONDecodeError as e:
        output_error(f"Invalid JSON input: {str(e)}")


def build_typography_prompt(mood: str, aesthetic: str, project: str) -> str:
    """Build prompt for Gemini to generate 4 typography pairings."""

    return f"""You are a professional typography designer creating font pairings for a {project}.

## Design Context
- **Mood**: {mood}
- **Aesthetic**: {aesthetic}
- **Project**: {project}

## Task
Generate exactly 4 typography pairing options. Each pairing must include:
1. A **display/heading** font for titles and headers
2. A **body** font for paragraphs and UI text
3. An optional **mono** font for code or technical content

## Requirements
- Use only Google Fonts (freely available)
- Ensure readability and accessibility
- Each pairing should have distinct character while fitting the mood
- Include appropriate font weights

## Generation Approach
- **Option 1**: Classic, safe choice that broadly appeals
- **Option 2**: More distinctive/characterful pairing
- **Option 3**: Modern, clean pairing
- **Option 4**: Creative/unexpected pairing that still works

## Output Format
Return ONLY valid JSON in this exact structure (no markdown, no explanation):

{{
  "typography": [
    {{
      "name": "Pairing Name",
      "description": "Brief description of this pairing's character",
      "display": {{
        "family": "Font Name",
        "weights": [500, 600, 700],
        "style": "serif|sans-serif|display"
      }},
      "body": {{
        "family": "Font Name",
        "weights": [400, 500, 600],
        "style": "sans-serif|serif"
      }},
      "mono": {{
        "family": "Font Name",
        "weights": [400, 500]
      }},
      "google_fonts_url": "https://fonts.googleapis.com/css2?family=..."
    }},
    // ... 3 more pairings
  ]
}}

## Google Fonts URL Format
The URL should include all fonts with their weights:
`https://fonts.googleapis.com/css2?family=Font+Name:wght@400;500;600&family=Other+Font:wght@400;700&display=swap`

## Popular Font Suggestions (but don't limit to these)
**Display/Headings**: Playfair Display, Fraunces, DM Serif Display, Outfit, Plus Jakarta Sans, Space Grotesk, Unbounded, Sora
**Body**: Inter, DM Sans, Nunito Sans, Source Sans 3, Work Sans, Rubik, Manrope, Public Sans
**Mono**: JetBrains Mono, Fira Code, Source Code Pro, IBM Plex Mono

Generate the 4 typography pairings now. Output ONLY the JSON, no other text."""


def extract_typography(response_data: dict) -> dict:
    """Extract typography JSON from Gemini response."""
    try:
        candidate = response_data.get("candidates", [{}])[0]
        content = candidate.get("content", {})
        parts = content.get("parts", [])
        text = "".join(part.get("text", "") for part in parts)

        text = text.strip()

        # Remove markdown code blocks if present
        if text.startswith("```json"):
            text = text[7:]
        if text.startswith("```"):
            text = text[3:]
        if text.endswith("```"):
            text = text[:-3]

        text = text.strip()

        return json.loads(text)

    except (json.JSONDecodeError, KeyError, IndexError) as e:
        return {"error": f"Failed to parse typography response: {str(e)}"}


def validate_typography(typography_data: dict) -> Optional[str]:
    """Validate the typography structure."""
    if "error" in typography_data:
        return typography_data["error"]

    if "typography" not in typography_data:
        return "Response missing 'typography' key"

    typography = typography_data["typography"]
    if not isinstance(typography, list) or len(typography) != 4:
        return f"Expected 4 typography options, got {len(typography) if isinstance(typography, list) else 'non-list'}"

    for i, option in enumerate(typography):
        if "name" not in option:
            return f"Typography option {i+1} missing 'name'"
        if "display" not in option:
            return f"Typography option {i+1} missing 'display'"
        if "body" not in option:
            return f"Typography option {i+1} missing 'body'"

        for key in ["display", "body"]:
            font = option[key]
            if "family" not in font:
                return f"Typography option {i+1} {key} missing 'family'"

    return None


def main():
    """Main entry point."""
    input_data = read_input()

    mood = input_data.get("mood")
    aesthetic = input_data.get("aesthetic", "modern")
    project = input_data.get("project", "web application")

    if not mood:
        output_error("Missing required field: mood")

    # Validate API key
    is_valid, error = validate_api_key()
    if not is_valid:
        output_error(error)

    api_key = get_api_key()

    # Build prompt
    prompt = build_typography_prompt(mood=mood, aesthetic=aesthetic, project=project)

    # Call Gemini API
    config = APIConfig(
        temperature=0.8,
        max_output_tokens=4096,
        timeout=60
    )
    client = GeminiClient(api_key, config)
    response = client.generate(prompt)

    if not response.success:
        output_error(f"Gemini API error: {response.error_message}")

    # Extract and validate typography
    typography_data = extract_typography(response.data)

    validation_error = validate_typography(typography_data)
    if validation_error:
        output_error(f"Invalid typography response: {validation_error}")

    # Output result
    output_result({
        "error": False,
        "typography": typography_data["typography"],
        "input": {
            "mood": mood,
            "aesthetic": aesthetic,
            "project": project
        }
    })


if __name__ == "__main__":
    main()
