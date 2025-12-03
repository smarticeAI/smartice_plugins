"""
Design Council - Gemini API Scripts

Modular Python library for frontend code generation via Gemini 3 Pro API.
Following the pattern established by Anthropic's slack-gif-creator skill.

Modules:
- validators: Input validation and API key checks
- api_client: Pure Gemini API interaction
- prompt_builder: Design spec → prompt conversion
- response_parser: Extract code from API responses
- gemini_generate: Main entry point
"""

from .validators import validate_api_key, validate_design_spec, validate_framework
from .api_client import GeminiClient
from .prompt_builder import build_initial_prompt, build_iteration_prompt
from .response_parser import extract_code, extract_reasoning, parse_structured_output

__all__ = [
    "validate_api_key",
    "validate_design_spec",
    "validate_framework",
    "GeminiClient",
    "build_initial_prompt",
    "build_iteration_prompt",
    "extract_code",
    "extract_reasoning",
    "parse_structured_output",
]

__version__ = "1.0.0"
