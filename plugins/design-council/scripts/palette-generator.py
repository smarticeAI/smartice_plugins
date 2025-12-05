#!/usr/bin/env python3
"""
Generate 4 color palette variations using Gemini API.

Takes mood, aesthetic, project description, and optional reference colors.
Outputs JSON with 4 palette options for user selection.

Usage:
    echo '{"mood": "Warm & Cozy", "aesthetic": "minimalist", "project": "pomodoro timer"}' | python palette-generator.py

    # With reference colors from user's uploaded image:
    echo '{"mood": "...", "reference_colors": ["#FAF6F1", "#C4704A"]}' | python palette-generator.py
"""

import json
import sys
from typing import Optional, List

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
            output_error("No input provided. Expected JSON with mood, aesthetic, project.")
        return json.loads(input_data)
    except json.JSONDecodeError as e:
        output_error(f"Invalid JSON input: {str(e)}")


def build_palette_prompt(
    mood: str,
    aesthetic: str,
    project: str,
    reference_colors: Optional[List[str]] = None
) -> str:
    """Build prompt for Gemini to generate 4 palette variations."""

    reference_section = ""
    if reference_colors:
        colors_str = ", ".join(reference_colors)
        reference_section = f"""
## Reference Colors (User Provided)
The user provided these colors as inspiration: {colors_str}

Generate variations based on these colors:
- **Option 1**: Closest match to the reference colors
- **Options 2-4**: Creative variations that maintain the same mood but explore different directions
"""
    else:
        reference_section = """
## Generation Approach
Since no reference colors were provided, generate 4 distinct palette options that all fit the mood and aesthetic, but each with a unique character:
- **Option 1**: The most classic/safe choice for this mood
- **Option 2**: A bolder, more vibrant interpretation
- **Option 3**: A subtle, sophisticated variation
- **Option 4**: A creative/unexpected take that still fits the mood
"""

    return f"""You are a professional UI/UX designer creating color palettes for a {project}.

## Design Context
- **Mood**: {mood}
- **Aesthetic**: {aesthetic}
- **Project**: {project}
{reference_section}

## Task
Generate exactly 4 color palette options. Each palette must include all the following color variables:

### Required Colors (12 total per palette)
1. `bg_primary` - Main background color
2. `bg_secondary` - Secondary/card background
3. `bg_tertiary` - Tertiary background (modals, dropdowns)
4. `text_primary` - Main text color
5. `text_secondary` - Secondary/muted text
6. `text_tertiary` - Placeholder/disabled text
7. `accent_primary` - Primary action color (buttons, links)
8. `accent_secondary` - Secondary accent
9. `border_default` - Default border color
10. `border_focus` - Focus state border
11. `success` - Success state color
12. `error` - Error state color

## Output Format
Return ONLY valid JSON in this exact structure (no markdown, no explanation):

{{
  "palettes": [
    {{
      "name": "Palette Name",
      "description": "Brief description of this palette's character",
      "colors": {{
        "bg_primary": "#HEXCODE",
        "bg_secondary": "#HEXCODE",
        "bg_tertiary": "#HEXCODE",
        "text_primary": "#HEXCODE",
        "text_secondary": "#HEXCODE",
        "text_tertiary": "#HEXCODE",
        "accent_primary": "#HEXCODE",
        "accent_secondary": "#HEXCODE",
        "border_default": "#HEXCODE",
        "border_focus": "#HEXCODE",
        "success": "#HEXCODE",
        "error": "#HEXCODE"
      }}
    }},
    // ... 3 more palettes
  ]
}}

## Design Guidelines
- Ensure sufficient contrast ratios (WCAG AA minimum)
- Background colors should work together without harsh transitions
- Accent colors should pop against backgrounds
- Text colors must be readable on their respective backgrounds
- Each palette should feel cohesive and intentional
- Names should be evocative (e.g., "Warm Sunset", "Nordic Frost", "Urban Dusk")

Generate the 4 palettes now. Output ONLY the JSON, no other text."""


def extract_palettes(response_data: dict) -> dict:
    """Extract palette JSON from Gemini response."""
    try:
        candidate = response_data.get("candidates", [{}])[0]
        content = candidate.get("content", {})
        parts = content.get("parts", [])
        text = "".join(part.get("text", "") for part in parts)

        # Try to parse as JSON directly
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
        return {"error": f"Failed to parse palette response: {str(e)}"}


def validate_palettes(palettes_data: dict) -> Optional[str]:
    """Validate the palette structure."""
    if "error" in palettes_data:
        return palettes_data["error"]

    if "palettes" not in palettes_data:
        return "Response missing 'palettes' key"

    palettes = palettes_data["palettes"]
    if not isinstance(palettes, list) or len(palettes) != 4:
        return f"Expected 4 palettes, got {len(palettes) if isinstance(palettes, list) else 'non-list'}"

    required_colors = [
        "bg_primary", "bg_secondary", "bg_tertiary",
        "text_primary", "text_secondary", "text_tertiary",
        "accent_primary", "accent_secondary",
        "border_default", "border_focus",
        "success", "error"
    ]

    for i, palette in enumerate(palettes):
        if "name" not in palette:
            return f"Palette {i+1} missing 'name'"
        if "colors" not in palette:
            return f"Palette {i+1} missing 'colors'"

        colors = palette["colors"]
        for color_name in required_colors:
            if color_name not in colors:
                return f"Palette {i+1} ({palette['name']}) missing color '{color_name}'"

    return None


def main():
    """Main entry point."""
    # Step 1: Read input
    input_data = read_input()

    # Step 2: Validate required fields
    mood = input_data.get("mood")
    aesthetic = input_data.get("aesthetic", "modern")
    project = input_data.get("project", "web application")
    reference_colors = input_data.get("reference_colors")

    if not mood:
        output_error("Missing required field: mood")

    # Step 3: Validate API key
    is_valid, error = validate_api_key()
    if not is_valid:
        output_error(error)

    api_key = get_api_key()

    # Step 4: Build prompt
    prompt = build_palette_prompt(
        mood=mood,
        aesthetic=aesthetic,
        project=project,
        reference_colors=reference_colors
    )

    # Step 5: Call Gemini API
    config = APIConfig(
        temperature=0.8,  # Slightly higher for creative variation
        max_output_tokens=4096,  # Palettes are much smaller than code
        timeout=60
    )
    client = GeminiClient(api_key, config)
    response = client.generate(prompt)

    if not response.success:
        output_error(f"Gemini API error: {response.error_message}")

    # Step 6: Extract and validate palettes
    palettes_data = extract_palettes(response.data)

    validation_error = validate_palettes(palettes_data)
    if validation_error:
        output_error(f"Invalid palette response: {validation_error}")

    # Step 7: Output result
    output_result({
        "error": False,
        "palettes": palettes_data["palettes"],
        "input": {
            "mood": mood,
            "aesthetic": aesthetic,
            "project": project,
            "has_reference": reference_colors is not None
        }
    })


if __name__ == "__main__":
    main()
