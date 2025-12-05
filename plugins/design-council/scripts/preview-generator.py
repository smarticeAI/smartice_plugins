#!/usr/bin/env python3
"""
Generate HTML preview page with 4 palette options as clickable cards.

Each card shows a mini mockup of the UI with the palette applied.
User clicks their preferred card to make a selection.

Usage:
    echo '{"palettes": [...], "project": "music player", "type": "palette"}' | python preview-generator.py

Output: HTML content to stdout
"""

import json
import sys
from typing import List, Dict

# Project type to mockup component mapping
MOCKUP_COMPONENTS = {
    "timer": ["timer-display", "control-buttons", "progress-ring"],
    "pomodoro": ["timer-display", "control-buttons", "progress-ring", "session-indicator"],
    "music": ["album-art", "waveform", "player-controls", "playlist-item"],
    "player": ["album-art", "waveform", "player-controls", "playlist-item"],
    "dashboard": ["stat-card", "nav-sidebar", "data-table", "chart-placeholder"],
    "chat": ["message-bubble", "input-field", "avatar", "sidebar-contact"],
    "shop": ["product-card", "price-tag", "cart-button", "rating-stars"],
    "ecommerce": ["product-card", "price-tag", "cart-button", "rating-stars"],
    "form": ["input-field", "dropdown", "checkbox", "submit-button"],
    "landing": ["hero-section", "feature-card", "cta-button", "testimonial"],
    "blog": ["article-card", "author-avatar", "tag-pill", "read-more-link"],
    "default": ["nav-header", "hero-section", "feature-card", "cta-button"]
}


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


def detect_project_type(project: str) -> str:
    """Detect project type from description."""
    project_lower = project.lower()
    for key in MOCKUP_COMPONENTS.keys():
        if key in project_lower:
            return key
    return "default"


def generate_component_html(component: str, option_num: int) -> str:
    """Generate HTML for a specific mockup component."""
    components = {
        "timer-display": f'''
            <div class="timer-display" style="font-size: 2.5rem; font-weight: 700; color: var(--text-primary-{option_num}); text-align: center; padding: 1rem;">
                25:00
            </div>''',

        "control-buttons": f'''
            <div class="control-buttons" style="display: flex; gap: 0.5rem; justify-content: center;">
                <button style="background: var(--accent-primary-{option_num}); color: var(--bg-primary-{option_num}); border: none; padding: 0.5rem 1rem; border-radius: 6px; font-weight: 600;">Start</button>
                <button style="background: var(--bg-tertiary-{option_num}); color: var(--text-secondary-{option_num}); border: 1px solid var(--border-default-{option_num}); padding: 0.5rem 1rem; border-radius: 6px;">Reset</button>
            </div>''',

        "progress-ring": f'''
            <div class="progress-ring" style="width: 60px; height: 60px; border-radius: 50%; border: 4px solid var(--bg-tertiary-{option_num}); border-top-color: var(--accent-primary-{option_num}); margin: 0.5rem auto;"></div>''',

        "session-indicator": f'''
            <div class="session-indicator" style="display: flex; gap: 0.25rem; justify-content: center; margin-top: 0.5rem;">
                <span style="width: 8px; height: 8px; border-radius: 50%; background: var(--accent-primary-{option_num});"></span>
                <span style="width: 8px; height: 8px; border-radius: 50%; background: var(--border-default-{option_num});"></span>
                <span style="width: 8px; height: 8px; border-radius: 50%; background: var(--border-default-{option_num});"></span>
            </div>''',

        "album-art": f'''
            <div class="album-art" style="width: 80px; height: 80px; background: linear-gradient(135deg, var(--accent-primary-{option_num}), var(--accent-secondary-{option_num})); border-radius: 8px; margin: 0 auto;"></div>''',

        "waveform": f'''
            <div class="waveform" style="display: flex; gap: 2px; align-items: center; justify-content: center; height: 30px; margin: 0.5rem 0;">
                {"".join([f'<div style="width: 3px; height: {12 + (i*5) % 20}px; background: var(--accent-primary-{option_num}); border-radius: 2px;"></div>' for i in range(12)])}
            </div>''',

        "player-controls": f'''
            <div class="player-controls" style="display: flex; gap: 1rem; justify-content: center; align-items: center;">
                <span style="color: var(--text-secondary-{option_num});">&#9198;</span>
                <span style="width: 32px; height: 32px; background: var(--accent-primary-{option_num}); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: var(--bg-primary-{option_num});">&#9654;</span>
                <span style="color: var(--text-secondary-{option_num});">&#9197;</span>
            </div>''',

        "playlist-item": f'''
            <div class="playlist-item" style="background: var(--bg-tertiary-{option_num}); padding: 0.5rem; border-radius: 6px; display: flex; align-items: center; gap: 0.5rem;">
                <div style="width: 24px; height: 24px; background: var(--accent-secondary-{option_num}); border-radius: 4px;"></div>
                <div style="flex: 1;">
                    <div style="font-size: 0.7rem; color: var(--text-primary-{option_num});">Song Title</div>
                    <div style="font-size: 0.6rem; color: var(--text-secondary-{option_num});">Artist</div>
                </div>
            </div>''',

        "stat-card": f'''
            <div class="stat-card" style="background: var(--bg-tertiary-{option_num}); padding: 0.75rem; border-radius: 8px; text-align: center;">
                <div style="font-size: 1.25rem; font-weight: 700; color: var(--accent-primary-{option_num});">2,847</div>
                <div style="font-size: 0.65rem; color: var(--text-secondary-{option_num});">Total Users</div>
            </div>''',

        "nav-sidebar": f'''
            <div class="nav-sidebar" style="background: var(--bg-secondary-{option_num}); padding: 0.5rem; border-radius: 6px;">
                <div style="padding: 0.25rem 0.5rem; background: var(--accent-primary-{option_num}); color: var(--bg-primary-{option_num}); border-radius: 4px; font-size: 0.65rem; margin-bottom: 0.25rem;">Dashboard</div>
                <div style="padding: 0.25rem 0.5rem; color: var(--text-secondary-{option_num}); font-size: 0.65rem;">Settings</div>
            </div>''',

        "data-table": f'''
            <div class="data-table" style="font-size: 0.6rem; border: 1px solid var(--border-default-{option_num}); border-radius: 6px; overflow: hidden;">
                <div style="display: flex; background: var(--bg-tertiary-{option_num}); padding: 0.25rem 0.5rem; color: var(--text-secondary-{option_num});">
                    <span style="flex: 1;">Name</span><span style="flex: 1;">Status</span>
                </div>
                <div style="display: flex; padding: 0.25rem 0.5rem; color: var(--text-primary-{option_num});">
                    <span style="flex: 1;">Item A</span><span style="flex: 1; color: var(--success-{option_num});">Active</span>
                </div>
            </div>''',

        "chart-placeholder": f'''
            <div class="chart" style="height: 40px; display: flex; align-items: flex-end; gap: 4px; padding: 0.5rem;">
                <div style="flex: 1; height: 60%; background: var(--accent-primary-{option_num}); border-radius: 2px;"></div>
                <div style="flex: 1; height: 80%; background: var(--accent-primary-{option_num}); border-radius: 2px;"></div>
                <div style="flex: 1; height: 45%; background: var(--accent-secondary-{option_num}); border-radius: 2px;"></div>
                <div style="flex: 1; height: 90%; background: var(--accent-primary-{option_num}); border-radius: 2px;"></div>
            </div>''',

        "nav-header": f'''
            <div class="nav-header" style="display: flex; justify-content: space-between; align-items: center; padding: 0.5rem; border-bottom: 1px solid var(--border-default-{option_num});">
                <div style="font-weight: 700; color: var(--text-primary-{option_num}); font-size: 0.8rem;">Logo</div>
                <div style="display: flex; gap: 0.5rem; font-size: 0.65rem; color: var(--text-secondary-{option_num});">
                    <span>Home</span><span>About</span>
                </div>
            </div>''',

        "hero-section": f'''
            <div class="hero" style="text-align: center; padding: 1rem;">
                <div style="font-size: 1rem; font-weight: 700; color: var(--text-primary-{option_num}); margin-bottom: 0.25rem;">Hero Title</div>
                <div style="font-size: 0.65rem; color: var(--text-secondary-{option_num});">Subtitle text here</div>
            </div>''',

        "feature-card": f'''
            <div class="feature-card" style="background: var(--bg-secondary-{option_num}); padding: 0.75rem; border-radius: 8px; border: 1px solid var(--border-default-{option_num});">
                <div style="width: 24px; height: 24px; background: var(--accent-primary-{option_num}); border-radius: 6px; margin-bottom: 0.5rem;"></div>
                <div style="font-size: 0.75rem; font-weight: 600; color: var(--text-primary-{option_num});">Feature</div>
                <div style="font-size: 0.6rem; color: var(--text-secondary-{option_num});">Description</div>
            </div>''',

        "cta-button": f'''
            <button style="background: var(--accent-primary-{option_num}); color: var(--bg-primary-{option_num}); border: none; padding: 0.5rem 1.25rem; border-radius: 6px; font-weight: 600; font-size: 0.75rem; margin: 0.5rem auto; display: block;">
                Get Started
            </button>''',

        "input-field": f'''
            <input type="text" placeholder="Enter text..." style="width: 100%; padding: 0.5rem; background: var(--bg-tertiary-{option_num}); border: 1px solid var(--border-default-{option_num}); border-radius: 6px; color: var(--text-primary-{option_num}); font-size: 0.7rem; outline: none;" />''',

        "message-bubble": f'''
            <div style="background: var(--accent-primary-{option_num}); color: var(--bg-primary-{option_num}); padding: 0.5rem 0.75rem; border-radius: 12px 12px 4px 12px; font-size: 0.7rem; max-width: 80%; margin-left: auto;">
                Hello there!
            </div>''',

        "product-card": f'''
            <div class="product-card" style="background: var(--bg-secondary-{option_num}); border-radius: 8px; overflow: hidden; border: 1px solid var(--border-default-{option_num});">
                <div style="height: 50px; background: linear-gradient(135deg, var(--accent-secondary-{option_num}), var(--accent-primary-{option_num}));"></div>
                <div style="padding: 0.5rem;">
                    <div style="font-size: 0.75rem; font-weight: 600; color: var(--text-primary-{option_num});">Product</div>
                    <div style="font-size: 0.8rem; font-weight: 700; color: var(--accent-primary-{option_num});">$29.99</div>
                </div>
            </div>''',

        "avatar": f'''
            <div style="width: 32px; height: 32px; border-radius: 50%; background: linear-gradient(135deg, var(--accent-primary-{option_num}), var(--accent-secondary-{option_num}));"></div>''',

        "tag-pill": f'''
            <span style="background: var(--accent-secondary-{option_num}); color: var(--text-primary-{option_num}); padding: 0.2rem 0.5rem; border-radius: 12px; font-size: 0.6rem;">Tag</span>''',

        "testimonial": f'''
            <div style="background: var(--bg-secondary-{option_num}); padding: 0.75rem; border-radius: 8px; border-left: 3px solid var(--accent-primary-{option_num});">
                <div style="font-size: 0.65rem; color: var(--text-secondary-{option_num}); font-style: italic;">"Great product!"</div>
                <div style="font-size: 0.6rem; color: var(--text-tertiary-{option_num}); margin-top: 0.25rem;">- Customer</div>
            </div>'''
    }

    return components.get(component, f'<div style="color: var(--text-secondary-{option_num}); font-size: 0.6rem;">[{component}]</div>')


def generate_mockup_html(components: List[str], option_num: int) -> str:
    """Generate the mockup HTML for a single option card."""
    component_html = "\n".join([generate_component_html(c, option_num) for c in components])
    return f'''
        <div class="mockup-content" style="display: flex; flex-direction: column; gap: 0.5rem;">
            {component_html}
        </div>
    '''


def generate_palette_preview_html(
    palettes: List[Dict],
    project: str,
    output_file: str = "palette-selection.json"
) -> str:
    """Generate the full HTML page with 4 palette option cards."""

    project_type = detect_project_type(project)
    components = MOCKUP_COMPONENTS.get(project_type, MOCKUP_COMPONENTS["default"])

    # Generate CSS variables for each palette
    css_vars = ""
    for i, palette in enumerate(palettes):
        option_num = i + 1
        colors = palette["colors"]
        css_vars += f"""
        /* Option {option_num}: {palette['name']} */
        --bg-primary-{option_num}: {colors['bg_primary']};
        --bg-secondary-{option_num}: {colors['bg_secondary']};
        --bg-tertiary-{option_num}: {colors['bg_tertiary']};
        --text-primary-{option_num}: {colors['text_primary']};
        --text-secondary-{option_num}: {colors['text_secondary']};
        --text-tertiary-{option_num}: {colors['text_tertiary']};
        --accent-primary-{option_num}: {colors['accent_primary']};
        --accent-secondary-{option_num}: {colors['accent_secondary']};
        --border-default-{option_num}: {colors['border_default']};
        --border-focus-{option_num}: {colors['border_focus']};
        --success-{option_num}: {colors['success']};
        --error-{option_num}: {colors['error']};
        """

    # Generate option cards
    option_cards = ""
    for i, palette in enumerate(palettes):
        option_num = i + 1
        mockup_html = generate_mockup_html(components, option_num)
        colors = palette["colors"]

        # Generate color swatches
        swatch_colors = ["bg_primary", "bg_secondary", "text_primary", "accent_primary", "accent_secondary"]
        swatches = "".join([
            f'<div class="swatch" style="background: {colors[c]};" title="{c}"></div>'
            for c in swatch_colors
        ])

        option_cards += f'''
        <div class="option-card" data-option="{option_num}" onclick="selectOption({option_num})"
             style="--card-bg: {colors['bg_primary']}; --card-border: {colors['border_default']};">
            <div class="card-header">
                <span class="option-number">Option {option_num}</span>
                <div class="check-mark">&#10003;</div>
            </div>
            <div class="mockup-container" style="background: {colors['bg_primary']};">
                {mockup_html}
            </div>
            <div class="palette-info">
                <h3>{palette['name']}</h3>
                <p>{palette.get('description', '')}</p>
                <div class="swatches">{swatches}</div>
            </div>
        </div>
        '''

    return f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Choose Your Palette - {project}</title>
    <style>
        :root {{
            {css_vars}
        }}

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
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
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
            position: relative;
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

        .mockup-container {{
            padding: 1rem;
            min-height: 180px;
        }}

        .palette-info {{
            padding: 1rem;
            border-top: 1px solid #333;
        }}

        .palette-info h3 {{
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 0.25rem;
        }}

        .palette-info p {{
            font-size: 0.8rem;
            color: #888;
            margin-bottom: 0.75rem;
            line-height: 1.4;
        }}

        .swatches {{
            display: flex;
            gap: 6px;
        }}

        .swatch {{
            width: 24px;
            height: 24px;
            border-radius: 6px;
            border: 1px solid rgba(255, 255, 255, 0.1);
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
        <h1>Choose Your Color Palette</h1>
        <p>Click on the option that best matches your vision</p>
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
            // Remove previous selection
            document.querySelectorAll('.option-card').forEach(card => {{
                card.classList.remove('selected');
            }});

            // Select new card
            const card = document.querySelector(`[data-option="${{optionNum}}"]`);
            card.classList.add('selected');
            selectedOption = optionNum;

            // Update banner
            const palettes = {json.dumps([p['name'] for p in palettes])};
            document.getElementById('selectedName').textContent = palettes[optionNum - 1];
            document.getElementById('selectionCode').textContent = `I choose Option ${{optionNum}}`;
            document.getElementById('selectionBanner').classList.add('visible');

            // Save selection to localStorage for reference
            localStorage.setItem('paletteSelection', JSON.stringify({{
                option: optionNum,
                name: palettes[optionNum - 1]
            }}));
        }}
    </script>
</body>
</html>'''


def main():
    """Main entry point."""
    input_data = read_input()

    palettes = input_data.get("palettes")
    project = input_data.get("project", "web application")
    preview_type = input_data.get("type", "palette")

    if not palettes:
        output_error("Missing required field: palettes")

    if len(palettes) != 4:
        output_error(f"Expected 4 palettes, got {len(palettes)}")

    # Generate HTML
    html = generate_palette_preview_html(palettes, project)

    # Output raw HTML (not JSON wrapped)
    print(html)


if __name__ == "__main__":
    main()
