#!/usr/bin/env python3
"""
Generate HTML preview page with 4 typography options as clickable cards.

Each card shows font samples with the typography applied.
User clicks their preferred card to make a selection.

Usage:
    echo '{"typography": [...], "project": "music player"}' | python typography-preview-generator.py

Output: HTML content to stdout
"""

import json
import sys
from typing import List, Dict


def output_error(message: str, exit_code: int = 1) -> None:
    """Output error message as JSON and exit."""
    print(json.dumps({"error": True, "message": message}))
    sys.exit(exit_code)


def read_input() -> dict:
    """Read and parse JSON input from stdin."""
    try:
        input_data = sys.stdin.read()
        if not input_data.strip():
            output_error("No input provided.")
        return json.loads(input_data)
    except json.JSONDecodeError as e:
        output_error(f"Invalid JSON input: {str(e)}")


def generate_font_import(typography: List[Dict]) -> str:
    """Generate Google Fonts import links."""
    imports = []
    for option in typography:
        if "google_fonts_url" in option:
            imports.append(f'<link rel="stylesheet" href="{option["google_fonts_url"]}">')
        else:
            # Build URL from font families
            families = []
            for key in ["display", "body", "mono"]:
                if key in option and "family" in option[key]:
                    family = option[key]["family"].replace(" ", "+")
                    weights = option[key].get("weights", [400, 500, 600, 700])
                    weights_str = ";".join(str(w) for w in weights)
                    families.append(f"family={family}:wght@{weights_str}")

            if families:
                url = f'https://fonts.googleapis.com/css2?{"&".join(families)}&display=swap'
                imports.append(f'<link rel="stylesheet" href="{url}">')

    return "\n    ".join(imports)


def generate_typography_preview_html(typography: List[Dict], project: str) -> str:
    """Generate the full HTML page with 4 typography option cards."""

    font_imports = generate_font_import(typography)

    # Generate option cards
    option_cards = ""
    for i, option in enumerate(typography):
        option_num = i + 1
        display_font = option["display"]["family"]
        body_font = option["body"]["family"]
        mono_font = option.get("mono", {}).get("family", "monospace")

        option_cards += f'''
        <div class="option-card" data-option="{option_num}" onclick="selectOption({option_num})">
            <div class="card-header">
                <span class="option-number">Option {option_num}</span>
                <div class="check-mark">&#10003;</div>
            </div>

            <div class="typography-preview">
                <div class="sample-heading" style="font-family: '{display_font}', serif;">
                    {project.title()}
                </div>

                <div class="sample-subheading" style="font-family: '{display_font}', serif;">
                    Beautiful typography makes all the difference
                </div>

                <div class="sample-body" style="font-family: '{body_font}', sans-serif;">
                    This is body text that demonstrates how your content will look.
                    Good typography creates hierarchy and guides the reader's eye.
                </div>

                <div class="sample-ui" style="font-family: '{body_font}', sans-serif;">
                    <button class="sample-button">Primary Action</button>
                    <span class="sample-link">Text Link</span>
                    <span class="sample-caption">Caption text</span>
                </div>

                <div class="sample-mono" style="font-family: '{mono_font}', monospace;">
                    const code = "example";
                </div>
            </div>

            <div class="typography-info">
                <h3>{option['name']}</h3>
                <p class="description">{option.get('description', '')}</p>
                <div class="font-stack">
                    <div class="font-item">
                        <span class="font-label">Display</span>
                        <span class="font-name" style="font-family: '{display_font}';">{display_font}</span>
                    </div>
                    <div class="font-item">
                        <span class="font-label">Body</span>
                        <span class="font-name" style="font-family: '{body_font}';">{body_font}</span>
                    </div>
                    <div class="font-item">
                        <span class="font-label">Mono</span>
                        <span class="font-name" style="font-family: '{mono_font}';">{mono_font}</span>
                    </div>
                </div>
            </div>
        </div>
        '''

    return f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Choose Your Typography - {project}</title>
    {font_imports}
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #0f0f0f;
            color: #ffffff;
            min-height: 100vh;
            padding: 2rem;
        }}

        .header {{
            text-align: center;
            margin-bottom: 2rem;
        }}

        .header h1 {{
            font-size: 1.75rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }}

        .header p {{
            color: #888;
            font-size: 0.95rem;
        }}

        .project-badge {{
            display: inline-block;
            background: #1a1a2e;
            color: #6366f1;
            padding: 0.25rem 0.75rem;
            border-radius: 12px;
            font-size: 0.8rem;
            margin-top: 0.75rem;
        }}

        .options-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 1.5rem;
            max-width: 1400px;
            margin: 0 auto;
        }}

        .option-card {{
            background: #1a1a1a;
            border: 2px solid #333;
            border-radius: 16px;
            overflow: hidden;
            cursor: pointer;
            transition: all 0.3s ease;
        }}

        .option-card:hover {{
            border-color: #555;
            transform: translateY(-4px);
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.4);
        }}

        .option-card.selected {{
            border-color: #6366f1;
            box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.3);
        }}

        .option-card.selected .check-mark {{
            opacity: 1;
            transform: scale(1);
        }}

        .card-header {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.75rem 1rem;
            background: rgba(255, 255, 255, 0.03);
            border-bottom: 1px solid #333;
        }}

        .option-number {{
            font-size: 0.75rem;
            font-weight: 600;
            color: #888;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }}

        .check-mark {{
            width: 24px;
            height: 24px;
            background: #6366f1;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 0.8rem;
            opacity: 0;
            transform: scale(0.5);
            transition: all 0.2s ease;
        }}

        .typography-preview {{
            padding: 1.5rem;
            background: #fafafa;
            color: #1a1a1a;
        }}

        .sample-heading {{
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            color: #1a1a1a;
        }}

        .sample-subheading {{
            font-size: 1rem;
            font-weight: 500;
            margin-bottom: 1rem;
            color: #444;
        }}

        .sample-body {{
            font-size: 0.9rem;
            line-height: 1.6;
            color: #555;
            margin-bottom: 1rem;
        }}

        .sample-ui {{
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1rem;
            flex-wrap: wrap;
        }}

        .sample-button {{
            background: #6366f1;
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 500;
            cursor: pointer;
        }}

        .sample-link {{
            color: #6366f1;
            text-decoration: underline;
            font-size: 0.85rem;
        }}

        .sample-caption {{
            color: #888;
            font-size: 0.75rem;
        }}

        .sample-mono {{
            background: #f0f0f0;
            padding: 0.5rem 0.75rem;
            border-radius: 6px;
            font-size: 0.8rem;
            color: #e11d48;
        }}

        .typography-info {{
            padding: 1rem;
            border-top: 1px solid #333;
        }}

        .typography-info h3 {{
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 0.25rem;
        }}

        .typography-info .description {{
            font-size: 0.8rem;
            color: #888;
            margin-bottom: 0.75rem;
            line-height: 1.4;
        }}

        .font-stack {{
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }}

        .font-item {{
            display: flex;
            justify-content: space-between;
            align-items: center;
        }}

        .font-label {{
            font-size: 0.7rem;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }}

        .font-name {{
            font-size: 0.85rem;
            color: #fff;
        }}

        .selection-banner {{
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            background: #1a1a2e;
            border-top: 1px solid #333;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transform: translateY(100%);
            transition: transform 0.3s ease;
        }}

        .selection-banner.visible {{
            transform: translateY(0);
        }}

        .selection-banner p {{
            color: #888;
        }}

        .selection-banner strong {{
            color: #6366f1;
        }}

        .selection-banner code {{
            background: #0f0f0f;
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-family: monospace;
            color: #10b981;
        }}

        .instructions {{
            text-align: center;
            margin-top: 2rem;
            padding: 1rem;
            background: #1a1a2e;
            border-radius: 12px;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }}

        .instructions p {{
            color: #888;
            font-size: 0.9rem;
        }}

        .instructions strong {{
            color: #6366f1;
        }}
    </style>
</head>
<body>
    <div class="header">
        <h1>Choose Your Typography</h1>
        <p>Click on the font pairing that best matches your vision</p>
        <div class="project-badge">{project}</div>
    </div>

    <div class="options-grid">
        {option_cards}
    </div>

    <div class="instructions">
        <p>Click a card to select it, then tell Claude: <strong>"I choose Option [number]"</strong></p>
    </div>

    <div class="selection-banner" id="selectionBanner">
        <p>Selected: <strong id="selectedName">None</strong></p>
        <p>Tell Claude: <code id="selectionCode">I choose Option X</code></p>
    </div>

    <script>
        let selectedOption = null;

        function selectOption(optionNum) {{
            document.querySelectorAll('.option-card').forEach(card => {{
                card.classList.remove('selected');
            }});

            const card = document.querySelector(`[data-option="${{optionNum}}"]`);
            card.classList.add('selected');
            selectedOption = optionNum;

            const typography = {json.dumps([t['name'] for t in typography])};
            document.getElementById('selectedName').textContent = typography[optionNum - 1];
            document.getElementById('selectionCode').textContent = `I choose Option ${{optionNum}}`;
            document.getElementById('selectionBanner').classList.add('visible');

            localStorage.setItem('typographySelection', JSON.stringify({{
                option: optionNum,
                name: typography[optionNum - 1]
            }}));
        }}
    </script>
</body>
</html>'''


def main():
    """Main entry point."""
    input_data = read_input()

    typography = input_data.get("typography")
    project = input_data.get("project", "web application")

    if not typography:
        output_error("Missing required field: typography")

    if len(typography) != 4:
        output_error(f"Expected 4 typography options, got {len(typography)}")

    html = generate_typography_preview_html(typography, project)
    print(html)


if __name__ == "__main__":
    main()
