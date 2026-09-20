"""
AWS Lambda Entrypoint for Artisan AI FastAPI Application.

Uses Mangum ASGI adapter to bridge Amazon API Gateway HTTP API v2 payloads
directly to the FastAPI application.
"""

import sys
import types
from pathlib import Path

CURRENT_DIR = Path(__file__).resolve().parent

# Ensure the function directory and project root are in sys.path
if str(CURRENT_DIR) not in sys.path:
    sys.path.insert(0, str(CURRENT_DIR))
ROOT_DIR = CURRENT_DIR.parent
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

# When packaged with CodeUri: backend/, CURRENT_DIR is at the root of /var/task.
# Register 'backend' in sys.modules so `from backend.x import y` resolves identically.
if "backend" not in sys.modules:
    backend_pkg = types.ModuleType("backend")
    backend_pkg.__path__ = [str(CURRENT_DIR)]
    backend_pkg.__file__ = str(CURRENT_DIR / "__init__.py")
    sys.modules["backend"] = backend_pkg

from mangum import Mangum
from backend.main import app

# Handler invoked by AWS Lambda
handler = Mangum(app, lifespan="off")
