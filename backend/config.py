"""
KalaSetu Backend Configuration.

Loads environment variables from the root .env file and provides
centralized application settings.
"""

from functools import lru_cache
from pathlib import Path
from typing import List
from pydantic_settings import BaseSettings
from pydantic import Field

# Directories
BACKEND_ROOT = Path(__file__).resolve().parent
PROJECT_ROOT = BACKEND_ROOT.parent
UPLOAD_DIR = BACKEND_ROOT / "uploads"


class Settings(BaseSettings):
    """Application settings with environment variable overrides."""

    app_name: str = "Artisan AI API"
    app_version: str = "1.0.0"
    app_description: str = "AI-Driven Market Linkage & Smart Cataloging Backend for Marginalized Artisans"
    debug: bool = False
    jwt_secret_key: str = Field(
        default="artisan-ai-security-token-secret-production-key-2026",
        description="Cryptographic secret key for signing JWT authentication tokens.",
    )
    jwt_algorithm: str = "HS256"
    jwt_expiry_seconds: int = 86400 * 30  # 30 days

    # Server
    host: str = "0.0.0.0"
    port: int = 8000

    # API Keys
    gemini_api_key: str = Field(
        default="",
        description="Google Gemini API key for multimodal embeddings and LLM pricing/cataloging.",
    )
    whisper_api_key: str = Field(
        default="",
        description="API key for Whisper speech-to-text transcription endpoint.",
    )

    # Voice Pipeline / Speech-to-Text Settings
    whisper_base_url: str = Field(
        default="https://api.openai.com/v1",
        description="Base URL of OpenAI-compatible Whisper transcription API.",
    )
    whisper_model: str = Field(
        default="whisper-large-v3",
        description="Whisper model identifier for audio transcription.",
    )
    stt_provider: str = Field(
        default="whisper",
        description="Transcription backend provider (whisper).",
    )
    default_language: str = Field(
        default="hi",
        description="Default source language code for voice notes.",
    )
    supported_languages: List[str] = Field(
        default=["hi", "ta", "bn", "mr", "te", "gu", "kn", "ml", "pa", "or"],
        description="Language codes accepted by the voice pipeline.",
    )

    # Groq Cloud LLM Settings
    groq_api_key: str = Field(
        default="",
        description="API key for Groq Cloud chat completions.",
    )
    groq_base_url: str = Field(
        default="https://api.groq.com/openai/v1",
        description="Base URL for Groq Cloud API.",
    )
    groq_chat_model: str = Field(
        default="openai/gpt-oss-120b",
        description="Groq model identifier for chat, cataloging, and assistance.",
    )
    llm_provider: str = Field(
        default="groq",
        description="Primary LLM provider: groq or gemini.",
    )

    def get_active_groq_key(self) -> str:
        """Resolve active Groq API key from groq_api_key or whisper_api_key."""
        return self.groq_api_key.strip() or self.whisper_api_key.strip()

    # Models
    llm_model: str = "gemini-3.6-flash"
    embedding_model: str = "gemini-embedding-001"

    # Database
    database_url: str = f"sqlite:///{BACKEND_ROOT / 'kalasetu.db'}"

    # Media Storage
    upload_dir: str = str(UPLOAD_DIR)
    static_url_prefix: str = "/uploads"

    # AWS & S3 Media Storage Settings
    aws_region: str = Field(default="ap-south-1", description="AWS region for S3 and Bedrock")
    s3_bucket_name: str = Field(default="", description="Optional Amazon S3 bucket name for cloud media storage")
    s3_custom_domain: str = Field(default="", description="Optional CloudFront or custom CDN domain for S3 media")

    # CORS
    cors_origins: List[str] = ["*"]
    cors_allow_credentials: bool = True
    cors_allow_methods: List[str] = ["*"]
    cors_allow_headers: List[str] = ["*"]

    model_config = {
        "env_file": str(PROJECT_ROOT / ".env"),
        "env_file_encoding": "utf-8",
        "extra": "ignore",
    }


@lru_cache()
def get_settings() -> Settings:
    """Return cached application settings."""
    return Settings()


def ensure_upload_dir() -> Path:
    """Ensure media upload directory exists. Uses /tmp in AWS Lambda."""
    import os
    if os.environ.get("AWS_LAMBDA_FUNCTION_NAME"):
        tmp_dir = Path("/tmp/uploads")
        tmp_dir.mkdir(parents=True, exist_ok=True)
        return tmp_dir
    UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
    return UPLOAD_DIR
