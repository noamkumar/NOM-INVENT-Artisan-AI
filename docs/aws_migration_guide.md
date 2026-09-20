# Artisan AI — AWS Serverless Cloud Migration Guide

This document outlines the production migration path from the local FastAPI backend to a scalable, cost-effective AWS Serverless architecture for **Artisan AI**.

---

## 1. High-Level Architecture Overview

```
                        +----------------------------+
                        |   Artisan AI Flutter App   |
                        |   (Android / iOS / Web)    |
                        +--------------+-------------+
                                       |
                   HTTPS (REST API)    |   Direct Image Upload
                                       |   (Pre-signed URLs)
                                       v
         +--------------------------------------------------------+
         |               Amazon CloudFront (CDN)                  |
         +-----------------------------+--------------------------+
                                       |
                                       v
         +--------------------------------------------------------+
         |            Amazon API Gateway (HTTP API v2)            |
         +-----------------------------+--------------------------+
                                       |
                                       v
         +--------------------------------------------------------+
         |                 AWS Lambda (ARM64)                     |
         |         FastAPI wrapped via Mangum ASGI Adapter        |
         +------+----------------------+-------------------+------+
                |                      |                   |
                v                      v                   v
     +--------------------+   +-----------------+   +------------------+
     |   Amazon Aurora    |   |    Amazon S3    |   |   Amazon Bedrock  |
     | PostgreSQL Serverless| | (Product Media) |   |  / Groq / Gemini |
     +--------------------+   +-----------------+   +------------------+
```

---

## 2. Component Migration Mapping

| Current Local Component | Target AWS Architecture | Purpose & Rationale |
| :--- | :--- | :--- |
| **FastAPI (`backend/main.py`)** | **AWS Lambda + Mangum** | Zero-idle-cost compute. Mangum translates API Gateway v2 payloads directly into ASGI requests. |
| **SQLite (`kalasetu.db`)** | **Amazon Aurora PostgreSQL Serverless v2** | Relational integrity for artisan catalogs, orders, and inquiries, auto-scaling to zero when inactive. |
| **Local uploads (`/uploads`)** | **Amazon S3 + CloudFront** | S3 stores high-resolution artisan craft photography; CloudFront provides low-latency edge caching. |
| **Local ML & Background Rembg** | **Lambda Container Image or Bedrock** | Heavy ML (rembg, background isolation) runs inside an AWS Lambda Docker container with 2048 MB memory. |
| **Direct Groq / Gemini Calls** | **Amazon Bedrock or Secrets Manager** | Bedrock Claude 3 Haiku / Llama 3 for catalog generation, or store API keys securely in AWS Secrets Manager. |
| **Static Assets** | **S3 + CloudFront** | Fast global distribution of catalogs, lookbooks, and media assets. |

---

## 3. Step-by-Step Migration Plan

### Phase 1: Wrap FastAPI with Mangum
Mangum allows the existing FastAPI application to run inside AWS Lambda with zero code changes to routes:

```python
# backend/lambda_handler.py
from mangum import Mangum
from backend.main import app

# Handler called by AWS Lambda runtime
handler = Mangum(app, lifespan="off")
```

Add `mangum>=0.17.0` to `requirements.txt`.

### Phase 2: Database Migration (SQLite -> PostgreSQL)
1. **Engine change**: In `backend/database.py`, switch `DATABASE_URL` from `sqlite:///./kalasetu.db` to:
   ```
   postgresql+psycopg2://<user>:<password>@<aurora-endpoint>:5432/artisan_ai
   ```
2. **Connection Pooling**: Use AWS RDS Proxy or `NullPool` in SQLAlchemy for serverless Lambda execution to prevent connection exhaustion.

### Phase 3: Media & S3 Direct Uploads
Instead of uploading multi-megabyte images through the API Lambda:
1. Flutter client requests an upload pre-signed URL:
   `POST /api/v1/media/presign-upload`
2. Lambda generates an S3 PUT URL with an expiration of 15 minutes.
3. Flutter client uploads directly to S3 via HTTP PUT:
   ```dart
   await http.put(Uri.parse(presignedUrl), body: imageBytes, headers: {'Content-Type': 'image/jpeg'});
   ```
4. S3 triggers an event to run background removal or thumbnail generation via an asynchronous Lambda worker.

### Phase 4: AI & Machine Learning on AWS
- **Text & Cataloging**: Use **Amazon Bedrock** (Converse API) using IAM role authentication—no API keys in source code.
  - Recommended Model: `anthropic.claude-3-haiku-20240307-v1:0` (ultra-fast, extremely cost-effective for multi-lingual catalog descriptions).
- **Background Removal**: Package `rembg[cpu]` and `onnxruntime` in an AWS Lambda Container Image (ECR) with 2048MB memory and 15s timeout.

### Phase 5: Infrastructure as Code (AWS SAM / Terraform)
Example `template.yaml` for AWS SAM:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: Artisan AI Serverless Backend

Globals:
  Function:
    Timeout: 29
    MemorySize: 1024
    Runtime: python3.11
    Architectures:
      - arm64

Resources:
  ArtisanApiFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: ./
      Handler: backend.lambda_handler.handler
      Environment:
        Variables:
          DATABASE_URL: !Ref DatabaseSecret
          GROQ_API_KEY: !Ref GroqApiKey
      Events:
        ApiEvent:
          Type: HttpApi
          Properties:
            Path: /{proxy+}
            Method: ANY
```

---

## 4. Security & Environment Variable Management

1. **Never commit secrets**: In AWS, store credentials in **AWS Systems Manager Parameter Store** (free) or **AWS Secrets Manager**.
2. **CORS & Emulator Access**: In production, configure API Gateway CORS for the registered domains and mobile scheme:
   ```yaml
   CorsConfiguration:
     AllowOrigins:
       - '*'
     AllowMethods:
       - GET
       - POST
       - PUT
       - DELETE
     AllowHeaders:
       - Content-Type
       - Authorization
   ```

---

## 5. Cost Estimation (Hackathon & MVP Tier)

| Service | Estimated Monthly Usage | Estimated Cost |
| :--- | :--- | :--- |
| **AWS Lambda** | 1,000,000 requests / month | **$0.00** (Free Tier includes 1M reqs/mo) |
| **Amazon API Gateway** | 1,000,000 requests / month | **$1.00** |
| **Amazon S3** | 10 GB storage + transfers | **$0.25** |
| **Amazon Aurora Serverless v2** | 0.5 ACU min (or Neon/Supabase Free PG) | **$0.00** (using Free PostgreSQL tier) |
| **Total** | | **<$2.00 / month** |
