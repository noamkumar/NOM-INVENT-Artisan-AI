"""
Storage Service.

Handles saving and retrieving uploaded images and audio files.
"""

import os
import uuid
import aiofiles
from pathlib import Path
from fastapi import UploadFile

from ..config import get_settings, ensure_upload_dir

settings = get_settings()


class StorageService:
    """Manages file storage in backend/uploads directory or Amazon S3."""

    def __init__(self):
        self.settings = settings
        self.upload_dir = ensure_upload_dir()
        self.s3_bucket = settings.s3_bucket_name.strip()
        self.s3_client = None
        if self.s3_bucket:
            try:
                import boto3
                self.s3_client = boto3.client("s3", region_name=settings.aws_region)
            except Exception as e:
                print(f"[StorageService] Warning: Could not initialize S3 client: {e}")

    async def save_upload(self, file: UploadFile, subfolder: str = "images") -> str:
        """
        Save an uploaded file and return its accessible relative path or S3 URL.

        Args:
            file: FastAPI UploadFile object
            subfolder: Subfolder within uploads (images, audio, etc.)

        Returns:
            URL (e.g. /uploads/images/xyz.jpg or https://bucket.s3.region.amazonaws.com/images/xyz.jpg)
        """
        ext = Path(file.filename or "file.jpg").suffix.lower()
        if not ext:
            ext = ".jpg"

        filename = f"{uuid.uuid4().hex}{ext}"

        # If S3 is configured, upload directly to S3
        if self.s3_client and self.s3_bucket:
            s3_key = f"{subfolder}/{filename}"
            content = await file.read()
            import io
            content_type = file.content_type or "application/octet-stream"
            try:
                self.s3_client.upload_fileobj(
                    io.BytesIO(content),
                    self.s3_bucket,
                    s3_key,
                    ExtraArgs={"ContentType": content_type},
                )
                if self.settings.s3_custom_domain:
                    domain = self.settings.s3_custom_domain.rstrip("/")
                    return f"{domain}/{s3_key}"
                return f"https://{self.s3_bucket}.s3.{self.settings.aws_region}.amazonaws.com/{s3_key}"
            except Exception as e:
                print(f"[StorageService] S3 upload error: {e}. Falling back to local storage.")

        # Local storage fallback
        target_dir = self.upload_dir / subfolder
        target_dir.mkdir(parents=True, exist_ok=True)
        file_path = target_dir / filename

        async with aiofiles.open(file_path, "wb") as out_file:
            content = await file.read()
            await out_file.write(content)

        return f"{settings.static_url_prefix}/{subfolder}/{filename}"

    def generate_presigned_upload_url(
        self,
        filename: str,
        subfolder: str = "images",
        expires_in: int = 900,
    ) -> dict | None:
        """
        Generate an Amazon S3 presigned PUT URL for direct client uploads.
        """
        if not self.s3_client or not self.s3_bucket:
            return None

        ext = Path(filename).suffix.lower() or ".jpg"
        unique_key = f"{subfolder}/{uuid.uuid4().hex}{ext}"
        try:
            url = self.s3_client.generate_presigned_url(
                "put_object",
                Params={"Bucket": self.s3_bucket, "Key": unique_key},
                ExpiresIn=expires_in,
            )
            file_url = f"https://{self.s3_bucket}.s3.{self.settings.aws_region}.amazonaws.com/{unique_key}"
            return {
                "upload_url": url,
                "file_url": file_url,
                "s3_key": unique_key,
                "expires_in": expires_in,
            }
        except Exception as e:
            print(f"[StorageService] Failed to generate presigned URL: {e}")
            return None

    def get_local_path_from_url(self, url: str) -> Path | None:
        """
        Convert a relative URL (e.g. /uploads/images/abc.jpg) to a local Path.
        """
        if not url:
            return None

        clean_url = url.replace("\\", "/")
        if clean_url.startswith(settings.static_url_prefix):
            rel_path = clean_url[len(settings.static_url_prefix):].lstrip("/")
            local_path = self.upload_dir / rel_path
            if local_path.exists():
                return local_path

        # Check if direct local path exists
        direct_path = Path(url)
        if direct_path.exists():
            return direct_path

        return None
