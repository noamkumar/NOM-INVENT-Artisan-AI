"""
Orders API Integration Tests.

Validates:
1. Create persistent order with custom or default artisan
2. Retrieve order by ID
3. List orders with optional status and artisan filters
4. Update order status through state machine (newOrder -> packed -> shipped -> delivered)
5. Auto tracking ID and shipped_at timestamp generation upon status transition to shipped
6. Order deletion and 404 handling
"""

import sys
from pathlib import Path

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

from fastapi.testclient import TestClient

PROJECT_ROOT = Path(__file__).resolve().parents[2]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from backend.main import app

client = TestClient(app)


def test_order_lifecycle():
    """Test full order creation, retrieval, status transition, and deletion."""
    # 1. Create a new order
    order_payload = {
        "artisan_id": "artisan_01",
        "product_title": "Handmade Blue Pottery Vase",
        "product_title_hi": "हस्तनिर्मित ब्लू पॉटरी फूलदान",
        "product_category": "Pottery",
        "product_image_url": "https://example.com/blue_pottery.jpg",
        "buyer_name": "Aditi Rao",
        "buyer_location": "Bandra West, Mumbai",
        "buyer_phone": "+91 98111 22233",
        "amount": 1850.0,
        "quantity": 2,
        "status": "newOrder",
    }
    create_res = client.post("/api/v1/orders", json=order_payload)
    assert create_res.status_code == 201, create_res.text
    order_data = create_res.json()

    order_id = order_data["id"]
    assert order_id.startswith("ORD-")
    assert order_data["buyer_name"] == "Aditi Rao"
    assert order_data["amount"] == 1850.0
    assert order_data["quantity"] == 2
    assert order_data["status"] == "newOrder"
    assert order_data["tracking_id"] is None
    assert order_data["shipped_at"] is None

    # 2. Get order by ID
    get_res = client.get(f"/api/v1/orders/{order_id}")
    assert get_res.status_code == 200
    assert get_res.json()["id"] == order_id

    # 3. List orders with filter
    list_res = client.get("/api/v1/orders", params={"artisan_id": "artisan_01", "status": "newOrder"})
    assert list_res.status_code == 200
    orders = list_res.json()
    assert any(o["id"] == order_id for o in orders)

    # 4. Advance status: newOrder -> packed
    pack_res = client.put(f"/api/v1/orders/{order_id}/status", json={"status": "packed"})
    assert pack_res.status_code == 200
    assert pack_res.json()["status"] == "packed"

    # 5. Advance status: packed -> shipped (should auto-generate tracking ID and timestamp)
    ship_res = client.put(f"/api/v1/orders/{order_id}/status", json={"status": "shipped"})
    assert ship_res.status_code == 200
    shipped_data = ship_res.json()
    assert shipped_data["status"] == "shipped"
    assert shipped_data["tracking_id"] is not None
    assert shipped_data["tracking_id"].startswith("TRK-")
    assert shipped_data["shipped_at"] is not None

    # 6. Advance status: shipped -> delivered
    deliver_res = client.put(f"/api/v1/orders/{order_id}/status", json={"status": "delivered"})
    assert deliver_res.status_code == 200
    assert deliver_res.json()["status"] == "delivered"

    # 7. Delete order
    del_res = client.delete(f"/api/v1/orders/{order_id}")
    assert del_res.status_code == 200
    assert del_res.json()["deleted"] is True

    # 8. Verify 404 after deletion
    get_again = client.get(f"/api/v1/orders/{order_id}")
    assert get_again.status_code == 404


def test_order_not_found():
    """Verify 404 returned for non-existent order ID."""
    res = client.get("/api/v1/orders/ORD-NONEXISTENT")
    assert res.status_code == 404
