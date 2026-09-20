"""
Market Linkage & B2B Wholesale Inquiries API Integration Tests.

Validates:
1. Submit B2B bulk inquiry from institutional buyer
2. Retrieve inquiry by ID
3. List inquiries with optional status and artisan filters
4. Accept inquiry with artisan response note
5. Reject inquiry with artisan response note
6. Status validation (reject invalid status values)
7. 404 error handling
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


def test_inquiry_lifecycle():
    """Test full B2B bulk procurement inquiry flow."""
    # 1. Submit inquiry
    inquiry_payload = {
        "artisan_id": "artisan_01",
        "buyer_name": "Vikram Sethi",
        "buyer_organization": "Tribal Crafts Emporium Ltd",
        "buyer_phone": "+91 99887 76655",
        "buyer_email": "procurement@tribalcrafts.in",
        "buyer_location": "Connaught Place, New Delhi",
        "craft_type": "Terracotta Pottery",
        "quantity": 150,
        "target_price_per_unit": 420.0,
        "message": "Seeking 150 units for festival gifting corporate hampers by Diwali.",
    }
    create_res = client.post("/api/v1/market/inquiries", json=inquiry_payload)
    assert create_res.status_code == 201, create_res.text
    data = create_res.json()

    inquiry_id = data["id"]
    assert inquiry_id.startswith("INQ-")
    assert data["buyer_name"] == "Vikram Sethi"
    assert data["buyer_organization"] == "Tribal Crafts Emporium Ltd"
    assert data["quantity"] == 150
    assert data["target_price_per_unit"] == 420.0
    assert data["status"] == "pending"

    # 2. Get inquiry by ID
    get_res = client.get(f"/api/v1/market/inquiries/{inquiry_id}")
    assert get_res.status_code == 200
    assert get_res.json()["id"] == inquiry_id

    # 3. List inquiries with pending filter
    list_res = client.get("/api/v1/market/inquiries", params={"artisan_id": "artisan_01", "status": "pending"})
    assert list_res.status_code == 200
    inquiries = list_res.json()
    assert any(i["id"] == inquiry_id for i in inquiries)

    # 4. Accept inquiry
    accept_payload = {
        "status": "accepted",
        "artisan_response_note": "Capacity confirmed for 150 units in 3 weeks. Production starts Monday.",
    }
    accept_res = client.put(f"/api/v1/market/inquiries/{inquiry_id}/status", json=accept_payload)
    assert accept_res.status_code == 200
    accepted_data = accept_res.json()
    assert accepted_data["status"] == "accepted"
    assert "Capacity confirmed" in accepted_data["artisan_response_note"]

    # 5. List with accepted filter
    accepted_list_res = client.get("/api/v1/market/inquiries", params={"status": "accepted"})
    assert accepted_list_res.status_code == 200
    assert any(i["id"] == inquiry_id for i in accepted_list_res.json())


def test_inquiry_rejection():
    """Test rejecting an inquiry with decline explanation."""
    inquiry_payload = {
        "artisan_id": "artisan_01",
        "buyer_name": "Rohan Mehra",
        "buyer_organization": "QuickBazaar Exports",
        "buyer_phone": "+91 91234 56789",
        "craft_type": "Terracotta Pottery",
        "quantity": 1000,
        "target_price_per_unit": 50.0,
        "message": "Urgent requirement within 48 hours.",
    }
    create_res = client.post("/api/v1/market/inquiries", json=inquiry_payload)
    assert create_res.status_code == 201
    inquiry_id = create_res.json()["id"]

    reject_res = client.put(
        f"/api/v1/market/inquiries/{inquiry_id}/status",
        json={
            "status": "rejected",
            "artisan_response_note": "Quantity too large for handmade terracotta kiln cycle within 48 hours.",
        },
    )
    assert reject_res.status_code == 200
    assert reject_res.json()["status"] == "rejected"


def test_inquiry_invalid_status_and_not_found():
    """Test invalid status validation and 404 responses."""
    # Test 404
    not_found = client.get("/api/v1/market/inquiries/INQ-DOESNOTEXIST")
    assert not_found.status_code == 404

    # Create dummy inquiry
    create_res = client.post(
        "/api/v1/market/inquiries",
        json={
            "buyer_name": "Test",
            "buyer_phone": "+91 90000 00000",
            "quantity": 10,
        },
    )
    assert create_res.status_code == 201
    inquiry_id = create_res.json()["id"]

    # Invalid status
    invalid_res = client.put(
        f"/api/v1/market/inquiries/{inquiry_id}/status",
        json={"status": "invalid_status_value"},
    )
    assert invalid_res.status_code == 400
