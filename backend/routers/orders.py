"""
Orders Management Router.

Provides persistent order tracking, status updating, and order creation.
"""

import uuid
from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models.db_models import OrderDB
from ..models.schemas import OrderCreate, OrderStatusUpdate, OrderResponse

router = APIRouter(prefix="/api/v1/orders", tags=["Orders"])


@router.get("", response_model=List[OrderResponse])
async def list_orders(
    artisan_id: Optional[str] = Query(None, description="Filter by owner artisan ID"),
    status: Optional[str] = Query(None, description="Filter by status (newOrder, packed, shipped, delivered, cancelled)"),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
):
    """
    List purchase orders for an artisan with optional status filtering.
    """
    query = db.query(OrderDB)
    if artisan_id:
        query = query.filter(OrderDB.artisan_id == artisan_id)
    if status:
        query = query.filter(OrderDB.status == status)

    items = query.order_by(OrderDB.placed_at.desc()).offset(offset).limit(limit).all()
    return items


@router.get("/{order_id}", response_model=OrderResponse)
async def get_order(order_id: str, db: Session = Depends(get_db)):
    """
    Get detailed order information by ID.
    """
    order = db.query(OrderDB).filter(OrderDB.id == order_id).first()
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Order '{order_id}' not found",
        )
    return order


@router.post("", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
async def create_order(payload: OrderCreate, db: Session = Depends(get_db)):
    """
    Create a new order for an artisan's handmade product.
    """
    order_id = f"ORD-{uuid.uuid4().hex[:8].upper()}"
    new_order = OrderDB(
        id=order_id,
        artisan_id=payload.artisan_id or "artisan_01",
        product_id=payload.product_id,
        product_title=payload.product_title,
        product_title_hi=payload.product_title_hi or "",
        product_category=payload.product_category,
        product_image_url=payload.product_image_url or "",
        buyer_name=payload.buyer_name,
        buyer_location=payload.buyer_location,
        buyer_phone=payload.buyer_phone or "",
        amount=payload.amount,
        quantity=payload.quantity,
        status=payload.status or "newOrder",
        placed_at=datetime.now(),
        created_at=datetime.now(),
        updated_at=datetime.now(),
    )
    db.add(new_order)
    db.commit()
    db.refresh(new_order)
    return new_order


@router.put("/{order_id}/status", response_model=OrderResponse)
async def update_order_status(
    order_id: str,
    payload: OrderStatusUpdate,
    db: Session = Depends(get_db),
):
    """
    Update fulfilment status of an order (newOrder -> packed -> shipped -> delivered).
    Automatically generates a tracking ID when transitioning to 'shipped' if not provided.
    """
    order = db.query(OrderDB).filter(OrderDB.id == order_id).first()
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Order '{order_id}' not found",
        )

    order.status = payload.status
    if payload.tracking_id:
        order.tracking_id = payload.tracking_id
    elif payload.status == "shipped" and not order.tracking_id:
        order.tracking_id = f"TRK-{uuid.uuid4().hex[:8].upper()}"

    if payload.status == "shipped" and not order.shipped_at:
        order.shipped_at = datetime.now()

    order.updated_at = datetime.now()
    db.commit()
    db.refresh(order)
    return order


@router.delete("/{order_id}", status_code=status.HTTP_200_OK)
async def delete_order(order_id: str, db: Session = Depends(get_db)):
    """
    Delete / cancel an order.
    """
    order = db.query(OrderDB).filter(OrderDB.id == order_id).first()
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Order '{order_id}' not found",
        )
    db.delete(order)
    db.commit()
    return {"deleted": True, "id": order_id}
