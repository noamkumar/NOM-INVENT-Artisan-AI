"""
Database Configuration and Session Management.

Uses SQLite with SQLAlchemy 2.0. Creates tables on startup.
"""

from typing import Generator
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker, Session

from .config import get_settings

settings = get_settings()

# Resolve database URL (normalize legacy postgres:// to postgresql:// for SQLAlchemy 2.0)
db_url = settings.database_url
if db_url.startswith("postgres://"):
    db_url = db_url.replace("postgres://", "postgresql://", 1)

# Connect engine: use NullPool for serverless / PostgreSQL to avoid connection leakage in Lambda
is_sqlite = "sqlite" in db_url
if is_sqlite:
    engine = create_engine(
        db_url,
        connect_args={"check_same_thread": False},
        echo=settings.debug,
    )
else:
    from sqlalchemy.pool import NullPool
    engine = create_engine(
        db_url,
        poolclass=NullPool,
        pool_pre_ping=True,
        echo=settings.debug,
    )

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db() -> Generator[Session, None, None]:
    """FastAPI Dependency for database sessions."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db() -> None:
    """Create all tables (ArtisanDB, ProductDB, SocialDraftDB, OrderDB, BuyerInquiryDB) and ensure demo artisan exists."""
    # Import models so SQLAlchemy registers them with Base.metadata
    from .models.db_models import (  # noqa: F401
        ArtisanDB,
        ProductDB,
        SocialDraftDB,
        OrderDB,
        BuyerInquiryDB,
    )
    from datetime import datetime

    Base.metadata.create_all(bind=engine)

    # Ensure demo artisan exists so demo login and FK constraints always succeed
    db = SessionLocal()
    try:
        demo_phone = "9876543210"
        existing = db.query(ArtisanDB).filter(ArtisanDB.phone == demo_phone).first()
        if not existing:
            demo_artisan = ArtisanDB(
                id="artisan_01",
                name="Rameshwar Lal Kumhar",
                phone=demo_phone,
                craft_type="Terracotta Pottery",
                location_cluster="Kumhar Gram, Delhi NCR",
                state="Delhi",
                experience_years="25",
                pehchan_id="PEHCHAN-DL-0042",
                preferred_language="en",
                created_at=datetime.now(),
            )
            db.add(demo_artisan)
            db.commit()
    except Exception as e:
        db.rollback()
        print(f"Warning: Could not seed demo artisan: {e}")
    finally:
        db.close()
