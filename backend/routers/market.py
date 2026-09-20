"""
Market Linkage & B2B Wholesale Inquiries Router.

Provides endpoints for institutional buyers, cooperatives, and retail brands
to submit bulk product procurement inquiries to artisans, and for artisans
to manage and respond to them.
"""

import uuid
from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models.db_models import BuyerInquiryDB
from ..models.schemas import (
    BuyerInquiryCreate,
    BuyerInquiryStatusUpdate,
    BuyerInquiryResponse,
)

router = APIRouter(prefix="/api/v1/market", tags=["Market Linkage & B2B"])


@router.post("/inquiries", response_model=BuyerInquiryResponse, status_code=status.HTTP_201_CREATED)
async def submit_inquiry(payload: BuyerInquiryCreate, db: Session = Depends(get_db)):
    """
    Wholesale / institutional buyer submits a bulk procurement inquiry to an artisan.
    """
    inquiry_id = f"INQ-{uuid.uuid4().hex[:8].upper()}"
    new_inquiry = BuyerInquiryDB(
        id=inquiry_id,
        artisan_id=payload.artisan_id or "artisan_01",
        product_id=payload.product_id,
        buyer_name=payload.buyer_name,
        buyer_organization=payload.buyer_organization or "",
        buyer_phone=payload.buyer_phone,
        buyer_email=payload.buyer_email or "",
        buyer_location=payload.buyer_location or "",
        craft_type=payload.craft_type or "Handicrafts",
        quantity=payload.quantity,
        target_price_per_unit=payload.target_price_per_unit,
        message=payload.message or "",
        status="pending",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    )
    db.add(new_inquiry)
    db.commit()
    db.refresh(new_inquiry)
    return new_inquiry


@router.get("/inquiries", response_model=List[BuyerInquiryResponse])
async def list_inquiries(
    artisan_id: Optional[str] = Query(None, description="Filter by artisan ID"),
    status: Optional[str] = Query(None, description="Filter by status (pending, accepted, rejected)"),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
):
    """
    List B2B buyer inquiries received by an artisan.
    """
    query = db.query(BuyerInquiryDB)
    if artisan_id:
        query = query.filter(BuyerInquiryDB.artisan_id == artisan_id)
    if status:
        query = query.filter(BuyerInquiryDB.status == status)

    return query.order_by(BuyerInquiryDB.created_at.desc()).offset(offset).limit(limit).all()


@router.get("/inquiries/{inquiry_id}", response_model=BuyerInquiryResponse)
async def get_inquiry(inquiry_id: str, db: Session = Depends(get_db)):
    """
    Get detailed B2B inquiry specifications.
    """
    inquiry = db.query(BuyerInquiryDB).filter(BuyerInquiryDB.id == inquiry_id).first()
    if not inquiry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Inquiry '{inquiry_id}' not found",
        )
    return inquiry


@router.put("/inquiries/{inquiry_id}/status", response_model=BuyerInquiryResponse)
async def update_inquiry_status(
    inquiry_id: str,
    payload: BuyerInquiryStatusUpdate,
    db: Session = Depends(get_db),
):
    """
    Artisan accepts or rejects a B2B bulk inquiry with an optional response note.
    """
    inquiry = db.query(BuyerInquiryDB).filter(BuyerInquiryDB.id == inquiry_id).first()
    if not inquiry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Inquiry '{inquiry_id}' not found",
        )

    if payload.status not in ("pending", "accepted", "rejected"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Status must be 'pending', 'accepted', or 'rejected'",
        )

    inquiry.status = payload.status
    if payload.artisan_response_note:
        inquiry.artisan_response_note = payload.artisan_response_note
    inquiry.updated_at = datetime.now()
    db.commit()
    db.refresh(inquiry)
    return inquiry
