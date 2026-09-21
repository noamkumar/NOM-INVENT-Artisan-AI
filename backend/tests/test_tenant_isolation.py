"""
Multi-Tenant Security and Data Isolation Integration Tests.

Validates that:
1. Cryptographic HMAC-SHA256 JWT tokens are generated, signed, and validated.
2. Cross-artisan data separation: Artisan A cannot view or list Artisan B's orders or inquiries.
3. Cross-artisan mutation prevention: Artisan A receives 403 Forbidden when attempting to
   modify, pack, or ship Artisan B's orders, or accept Artisan B's wholesale RFPs.
4. Cross-artisan catalog protection: Artisan A receives 403 Forbidden when attempting to
   modify or delete Artisan B's products.
5. Consumer PII redaction: Public tracking requests mask phone numbers and street addresses.
"""

import sys
from pathlib import Path
from datetime import datetime

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

from fastapi.testclient import TestClient
import pytest

PROJECT_ROOT = Path(__file__).resolve().parents[2]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from backend.main import app
from backend.database import SessionLocal
from backend.models.db_models import ArtisanDB, ProductDB, OrderDB, BuyerInquiryDB
from backend.utils.security import create_access_token, decode_access_token

client = TestClient(app)


@pytest.fixture(scope="module")
def setup_test_tenants():
    """Create two distinct artisans with products, orders, and inquiries."""
    db = SessionLocal()

    # Clean up existing test fixtures if present
    db.query(OrderDB).filter(OrderDB.artisan_id.in_(["artisan_alpha", "artisan_beta"])).delete(synchronize_session=False)
    db.query(BuyerInquiryDB).filter(BuyerInquiryDB.artisan_id.in_(["artisan_alpha", "artisan_beta"])).delete(synchronize_session=False)
    db.query(ProductDB).filter(ProductDB.artisan_id.in_(["artisan_alpha", "artisan_beta"])).delete(synchronize_session=False)
    db.query(ArtisanDB).filter(ArtisanDB.id.in_(["artisan_alpha", "artisan_beta"])).delete(synchronize_session=False)
    db.commit()

    # Create Artisan Alpha
    artisan_a = ArtisanDB(
        id="artisan_alpha",
        name="Rameshwar Kumhar",
        phone="9810011111",
        craft_type="Pottery",
        location_cluster="Alwar, Rajasthan",
        state="Rajasthan",
        created_at=datetime.now(),
    )
    # Create Artisan Beta
    artisan_b = ArtisanDB(
        id="artisan_beta",
        name="Devi Meenakshi",
        phone="9820022222",
        craft_type="Textiles",
        location_cluster="Kanchipuram, Tamil Nadu",
        state="Tamil Nadu",
        created_at=datetime.now(),
    )
    db.add_all([artisan_a, artisan_b])
    db.commit()

    # Create Products
    prod_a = ProductDB(
        id="prod_alpha_pot_01",
        artisan_id="artisan_alpha",
        title="Terracotta Water Jug",
        price=450.0,
        category="Pottery",
        status="live",
    )
    prod_b = ProductDB(
        id="prod_beta_silk_01",
        artisan_id="artisan_beta",
        title="Pure Mulberry Silk Saree",
        price=6800.0,
        category="Textiles",
        status="live",
    )
    db.add_all([prod_a, prod_b])
    db.commit()

    # Create Orders
    order_a = OrderDB(
        id="ORD-ALPHA-1001",
        artisan_id="artisan_alpha",
        product_id="prod_alpha_pot_01",
        product_title="Terracotta Water Jug",
        buyer_name="Ananya Iyer",
        buyer_location="12 Anna Salai, Chennai, Tamil Nadu - 600002",
        buyer_phone="+91 9840112233",
        amount=450.0,
        quantity=1,
        status="newOrder",
    )
    order_b = OrderDB(
        id="ORD-BETA-2001",
        artisan_id="artisan_beta",
        product_id="prod_beta_silk_01",
        product_title="Pure Mulberry Silk Saree",
        buyer_name="Vikram Malhotra",
        buyer_location="84 Nariman Point, Mumbai, Maharashtra - 400021",
        buyer_phone="+91 9820556677",
        amount=6800.0,
        quantity=1,
        status="newOrder",
    )
    db.add_all([order_a, order_b])
    db.commit()

    # Create Inquiries
    inq_a = BuyerInquiryDB(
        id="INQ-ALPHA-3001",
        artisan_id="artisan_alpha",
        buyer_name="Jaipur Heritage Hotel",
        buyer_phone="+91 9829012345",
        quantity=200,
        target_price_per_unit=380.0,
        status="pending",
    )
    inq_b = BuyerInquiryDB(
        id="INQ-BETA-4001",
        artisan_id="artisan_beta",
        buyer_name="Chennai Silk Boutique",
        buyer_phone="+91 9841098765",
        quantity=50,
        target_price_per_unit=5500.0,
        status="pending",
    )
    db.add_all([inq_a, inq_b])
    db.commit()

    token_a = create_access_token(artisan_id="artisan_alpha", phone="9810011111")
    token_b = create_access_token(artisan_id="artisan_beta", phone="9820022222")

    yield {
        "artisan_a": artisan_a,
        "artisan_b": artisan_b,
        "token_a": token_a,
        "token_b": token_b,
        "order_a": order_a,
        "order_b": order_b,
        "inq_a": inq_a,
        "inq_b": inq_b,
        "prod_a": prod_a,
        "prod_b": prod_b,
    }

    # Teardown
    db.query(OrderDB).filter(OrderDB.artisan_id.in_(["artisan_alpha", "artisan_beta"])).delete(synchronize_session=False)
    db.query(BuyerInquiryDB).filter(BuyerInquiryDB.artisan_id.in_(["artisan_alpha", "artisan_beta"])).delete(synchronize_session=False)
    db.query(ProductDB).filter(ProductDB.artisan_id.in_(["artisan_alpha", "artisan_beta"])).delete(synchronize_session=False)
    db.query(ArtisanDB).filter(ArtisanDB.id.in_(["artisan_alpha", "artisan_beta"])).delete(synchronize_session=False)
    db.commit()
    db.close()


def test_jwt_issuance_and_signature_verification(setup_test_tenants):
    """Verify cryptographic JWT signing, tamper prevention, and claim decoding."""
    token = setup_test_tenants["token_a"]
    claims = decode_access_token(token)
    assert claims["sub"] == "artisan_alpha"
    assert claims["role"] == "artisan"
    assert claims["phone"] == "9810011111"

    # Verify tampering with signature is rejected
    tampered_token = token[:-4] + "WXYZ"
    with pytest.raises(ValueError, match="tampered"):
        decode_access_token(tampered_token)


def test_cross_artisan_orders_data_isolation(setup_test_tenants):
    """Artisan Alpha must ONLY see Alpha's orders; Artisan Beta must ONLY see Beta's orders."""
    token_a = setup_test_tenants["token_a"]
    token_b = setup_test_tenants["token_b"]

    # 1. Artisan Alpha fetches orders
    res_a = client.get("/api/v1/orders", headers={"Authorization": f"Bearer {token_a}"})
    assert res_a.status_code == 200, res_a.text
    orders_a = res_a.json()
    order_ids_a = [o["id"] for o in orders_a]

    assert "ORD-ALPHA-1001" in order_ids_a
    assert "ORD-BETA-2001" not in order_ids_a  # STRICT TENANT ISOLATION

    # 2. Artisan Beta fetches orders
    res_b = client.get("/api/v1/orders", headers={"Authorization": f"Bearer {token_b}"})
    assert res_b.status_code == 200, res_b.text
    orders_b = res_b.json()
    order_ids_b = [o["id"] for o in orders_b]

    assert "ORD-BETA-2001" in order_ids_b
    assert "ORD-ALPHA-1001" not in order_ids_b  # STRICT TENANT ISOLATION


def test_cross_artisan_order_mutation_forbidden(setup_test_tenants):
    """Artisan Alpha must receive 403 Forbidden when attempting to pack or ship Beta's order."""
    token_a = setup_test_tenants["token_a"]

    # Alpha tries to update Beta's order
    res = client.patch(
        "/api/v1/orders/ORD-BETA-2001/status",
        json={"status": "packed"},
        headers={"Authorization": f"Bearer {token_a}"},
    )
    assert res.status_code == 403, f"Expected 403 Forbidden but got {res.status_code}: {res.text}"
    assert "Forbidden" in res.json()["detail"]


def test_cross_artisan_inquiry_isolation(setup_test_tenants):
    """Artisan Alpha must NOT see Artisan Beta's confidential B2B pricing inquiries."""
    token_a = setup_test_tenants["token_a"]
    token_b = setup_test_tenants["token_b"]

    # Alpha lists inquiries
    res_a = client.get("/api/v1/market/inquiries", headers={"Authorization": f"Bearer {token_a}"})
    assert res_a.status_code == 200
    inqs_a = [i["id"] for i in res_a.json()]
    assert "INQ-ALPHA-3001" in inqs_a
    assert "INQ-BETA-4001" not in inqs_a

    # Beta lists inquiries
    res_b = client.get("/api/v1/market/inquiries", headers={"Authorization": f"Bearer {token_b}"})
    assert res_b.status_code == 200
    inqs_b = [i["id"] for i in res_b.json()]
    assert "INQ-BETA-4001" in inqs_b
    assert "INQ-ALPHA-3001" not in inqs_b


def test_cross_artisan_inquiry_mutation_forbidden(setup_test_tenants):
    """Artisan Alpha cannot accept or reject Beta's wholesale inquiry."""
    token_a = setup_test_tenants["token_a"]

    res = client.patch(
        "/api/v1/market/inquiries/INQ-BETA-4001/status",
        json={"status": "accepted", "artisan_response_note": "Malicious accept"},
        headers={"Authorization": f"Bearer {token_a}"},
    )
    assert res.status_code == 403
    assert "Forbidden" in res.json()["detail"]


def test_cross_artisan_product_mutation_forbidden(setup_test_tenants):
    """Artisan Alpha cannot update or delete Artisan Beta's catalog product."""
    token_a = setup_test_tenants["token_a"]

    # Try to modify Beta's product
    res_put = client.put(
        "/api/v1/products/prod_beta_silk_01",
        json={"title": "Hacked Title", "price": 100.0},
        headers={"Authorization": f"Bearer {token_a}"},
    )
    assert res_put.status_code == 403
    assert "Forbidden" in res_put.json()["detail"]

    # Try to delete Beta's product
    res_del = client.delete(
        "/api/v1/products/prod_beta_silk_01",
        headers={"Authorization": f"Bearer {token_a}"},
    )
    assert res_del.status_code == 403
    assert "Forbidden" in res_del.json()["detail"]


def test_consumer_pii_masking_on_public_tracking(setup_test_tenants):
    """Unauthenticated public parcel tracking must mask customer phone and street address."""
    # Anonymous customer tracks an order
    res = client.get("/api/v1/orders/ORD-ALPHA-1001")
    assert res.status_code == 200
    data = res.json()

    # Verify PII is masked
    assert data["buyer_phone"] == "******2233"  # Masked digits
    assert "12 Anna Salai" not in data["buyer_location"]  # Street address masked
    assert "Chennai" in data["buyer_location"]  # City preserved for transit info
