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


GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

DEFAULT_CONFIG = {
    "temperature": 0.7,
    "max_output_tokens": 8192,
    "top_p": 0.95,
    "top_k": 40,
}


@dataclass
class APIConfig:
    """Configuration for Gemini API calls."""
    temperature: float = 0.7
    max_output_tokens: int = 8192
    top_p: float = 0.95
    top_k: int = 40
    timeout: int = 120


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
