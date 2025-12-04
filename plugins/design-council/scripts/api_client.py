"""
Pure Gemini API interaction.

Handles:
- API calls with proper error handling
- Rate limiting and retry logic
- Timeout management
"""

import json
import urllib.request
import urllib.error
from typing import Optional
from dataclasses import dataclass


GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-preview:generateContent"

DEFAULT_CONFIG = {
    "temperature": 0.7,
    "max_output_tokens": 32768,  # Increased from 8192 for larger code generation
    "top_p": 0.95,
    "top_k": 40,
}


@dataclass
class APIConfig:
    """Configuration for Gemini API calls."""
    temperature: float = 0.7
    max_output_tokens: int = 32768  # Increased from 8192
    top_p: float = 0.95
    top_k: int = 40
    timeout: int = 180  # Increased for larger responses


@dataclass
class APIResponse:
    """Structured API response."""
    success: bool
    data: Optional[dict] = None
    error_message: Optional[str] = None
    status_code: Optional[int] = None


class GeminiClient:
    """
    Client for Gemini API interactions.

    Usage:
        client = GeminiClient(api_key)
        response = client.generate(prompt)
    """

    def __init__(self, api_key: str, config: Optional[APIConfig] = None):
        """
        Initialize the Gemini client.

        Args:
            api_key: Gemini API key
            config: Optional API configuration
        """
        self.api_key = api_key
        self.config = config or APIConfig()
        self.base_url = GEMINI_API_URL

    def generate(self, prompt: str) -> APIResponse:
        """
        Generate content from a prompt.

        Args:
            prompt: The prompt to send to Gemini

        Returns:
            APIResponse with success status and data or error
        """
        url = f"{self.base_url}?key={self.api_key}"

        payload = {
            "contents": [{
                "parts": [{
                    "text": prompt
                }]
            }],
            "generationConfig": {
                "temperature": self.config.temperature,
                "maxOutputTokens": self.config.max_output_tokens,
                "topP": self.config.top_p,
                "topK": self.config.top_k,
            }
        }

        headers = {
            "Content-Type": "application/json"
        }

        data = json.dumps(payload).encode("utf-8")
        request = urllib.request.Request(url, data=data, headers=headers, method="POST")

        try:
            with urllib.request.urlopen(request, timeout=self.config.timeout) as response:
                result = json.loads(response.read().decode("utf-8"))
                return APIResponse(success=True, data=result)

        except urllib.error.HTTPError as e:
            error_body = e.read().decode("utf-8") if e.fp else str(e)
            return APIResponse(
                success=False,
                error_message=f"HTTP Error {e.code}: {error_body}",
                status_code=e.code
            )

        except urllib.error.URLError as e:
            return APIResponse(
                success=False,
                error_message=f"URL Error: {str(e.reason)}"
            )

        except TimeoutError:
            return APIResponse(
                success=False,
                error_message=f"Request timed out after {self.config.timeout} seconds"
            )

        except Exception as e:
            return APIResponse(
                success=False,
                error_message=f"Unexpected error: {str(e)}"
            )

    def generate_with_retry(self, prompt: str, max_retries: int = 3) -> APIResponse:
        """
        Generate with automatic retry on failure.

        Args:
            prompt: The prompt to send
            max_retries: Maximum number of retry attempts

        Returns:
            APIResponse from the last attempt
        """
        import time

        last_response = None

        for attempt in range(max_retries):
            response = self.generate(prompt)

            if response.success:
                return response

            last_response = response

            # Don't retry on client errors (4xx)
            if response.status_code and 400 <= response.status_code < 500:
                return response

            # Exponential backoff
            if attempt < max_retries - 1:
                wait_time = (2 ** attempt) * 1  # 1s, 2s, 4s
                time.sleep(wait_time)

        return last_response

    def generate_with_continuation(self, prompt: str, max_continuations: int = 3) -> APIResponse:
        """
        Generate content with automatic continuation if truncated.

        If the response is truncated (MAX_TOKENS), automatically continues
        generation by sending the partial response back with a continuation prompt.

        Args:
            prompt: The initial prompt to send
            max_continuations: Maximum continuation attempts (default: 3)

        Returns:
            APIResponse with combined content from all continuations
        """
        full_text = ""
        current_prompt = prompt
        continuation_count = 0

        while continuation_count <= max_continuations:
            response = self.generate(current_prompt)

            if not response.success:
                # If we have partial content, return it with a warning
                if full_text:
                    response.data = self._build_combined_response(full_text, "PARTIAL")
                    response.success = True
                return response

            # Extract text and finish reason from response
            text, finish_reason = self._extract_content(response.data)

            if text:
                full_text += text

            # Check if we need to continue
            if finish_reason != "MAX_TOKENS":
                # Generation complete
                if full_text:
                    response.data = self._build_combined_response(full_text, finish_reason)
                return response

            # Need to continue - build continuation prompt
            continuation_count += 1
            if continuation_count > max_continuations:
                # Hit max continuations, return what we have
                response.data = self._build_combined_response(full_text, "MAX_CONTINUATIONS")
                return response

            # Build continuation prompt
            current_prompt = self._build_continuation_prompt(prompt, full_text)

        return response

    def _extract_content(self, data: dict) -> tuple:
        """Extract text content and finish reason from API response."""
        try:
            candidate = data.get("candidates", [{}])[0]
            finish_reason = candidate.get("finishReason", "UNKNOWN")

            content = candidate.get("content", {})
            parts = content.get("parts", [])
            text = "".join(part.get("text", "") for part in parts)

            return text, finish_reason
        except (KeyError, IndexError, TypeError):
            return "", "ERROR"

    def _build_combined_response(self, full_text: str, finish_reason: str) -> dict:
        """Build a response structure with combined text."""
        return {
            "candidates": [{
                "content": {
                    "parts": [{"text": full_text}]
                },
                "finishReason": finish_reason
            }]
        }

    def _build_continuation_prompt(self, original_prompt: str, partial_response: str) -> str:
        """Build a prompt to continue truncated generation."""
        # Find a good breakpoint (end of a line or code block)
        last_newline = partial_response.rfind('\n')
        if last_newline > len(partial_response) - 200:
            context = partial_response[last_newline-500:] if last_newline > 500 else partial_response
        else:
            context = partial_response[-500:]

        return f"""Continue generating from where you left off. Here's the context:

ORIGINAL REQUEST:
{original_prompt[:1000]}...

YOUR PARTIAL RESPONSE ENDED WITH:
```
{context}
```

IMPORTANT: Continue EXACTLY from where you stopped. Do not repeat any code. Do not add explanations. Just continue the code/content seamlessly."""
