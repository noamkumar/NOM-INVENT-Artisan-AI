import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalasetu/core/providers/app_providers.dart';
import 'package:kalasetu/data/services/api_service.dart';
import 'package:kalasetu/features/orders/models/order.dart';
import 'package:kalasetu/features/orders/models/buyer_inquiry.dart';
import 'package:kalasetu/features/orders/providers/orders_provider.dart';
import 'package:kalasetu/features/orders/screens/my_orders_screen.dart';

class FakeTestApiService extends MockApiService {
  final List<Order> _orders = [
    Order(
      id: 'ORD-TEST01',
      artisanId: 'artisan_01',
      productTitle: 'Terracotta Water Pot',
      productCategory: 'Pottery',
      productImagePath: '',
      buyerName: 'Aarav Patel',
      buyerLocation: 'Ahmedabad, Gujarat',
      amount: 950.0,
      quantity: 1,
      status: OrderStatus.newOrder,
      placedAt: DateTime(2026, 9, 20, 10, 0),
    ),
  ];

  final List<BuyerInquiry> _inquiries = [
    BuyerInquiry(
      id: 'INQ-TEST01',
      artisanId: 'artisan_01',
      buyerName: 'Pooja Hegde',
      buyerOrganization: 'FabIndia Regional Procurement',
      buyerPhone: '+91 98765 00000',
      buyerEmail: 'pooja@fabindia.com',
      buyerLocation: 'Connaught Place, New Delhi',
      craftType: 'Terracotta Pottery',
      quantity: 200,
      targetPricePerUnit: 350.0,
      message: 'Looking for 200 units for festive Diwali collection.',
      status: BuyerInquiryStatus.pending,
      artisanResponseNote: '',
      createdAt: DateTime(2026, 9, 20, 11, 0),
    ),
  ];

  @override
  Future<List<Order>> getOrders({String? artisanId, String? status}) async {
    return List.from(_orders);
  }

  @override
  Future<Order> updateOrderStatus(String orderId, OrderStatus status, {String? trackingId}) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final updated = _orders[idx].copyWith(
        status: status,
        trackingId: trackingId ?? 'TRK-AUTO1234',
        shippedAt: status == OrderStatus.shipped ? DateTime.now() : _orders[idx].shippedAt,
      );
      _orders[idx] = updated;
      return updated;
    }
    throw Exception('Not found');
  }

  @override
  Future<List<BuyerInquiry>> getBuyerInquiries({String? artisanId, String? status}) async {
    return List.from(_inquiries);
  }

  @override
  Future<BuyerInquiry> updateBuyerInquiryStatus(String inquiryId, String status, {String? responseNote}) async {
    final idx = _inquiries.indexWhere((i) => i.id == inquiryId);
    if (idx != -1) {
      final updated = _inquiries[idx].copyWith(
        status: BuyerInquiryStatusX.fromString(status),
        artisanResponseNote: responseNote ?? _inquiries[idx].artisanResponseNote,
        updatedAt: DateTime.now(),
      );
      _inquiries[idx] = updated;
      return updated;
    }
    throw Exception('Not found');
  }
}

void main() {
  group('Order & BuyerInquiry Model Unit Tests', () {
    test('Order serialization from and to JSON matches backend API specification', () {
      final json = {
        'id': 'ORD-9876ABCD',
        'artisan_id': 'artisan_01',
        'product_id': 'prod_001',
        'product_title': 'Dhokra Brass Tribal Figurine',
        'product_title_hi': 'ढोकरा पीतल आदिवासी मूर्ति',
        'product_category': 'Metalwork',
        'product_image_url': 'https://api.artisanai.in/uploads/dhokra.jpg',
        'buyer_name': 'Kavita Sundaram',
        'buyer_location': 'Mylapore, Chennai',
        'buyer_phone': '+91 94444 55555',
        'amount': 2400.0,
        'quantity': 2,
        'status': 'packed',
        'placed_at': '2026-09-20T10:30:00.000',
        'shipped_at': null,
        'tracking_id': null,
      };

      final order = Order.fromJson(json);
      expect(order.id, 'ORD-9876ABCD');
      expect(order.artisanId, 'artisan_01');
      expect(order.productTitle, 'Dhokra Brass Tribal Figurine');
      expect(order.amount, 2400.0);
      expect(order.quantity, 2);
      expect(order.status, OrderStatus.packed);
      expect(order.buyerCity, 'Chennai');

      final serialized = order.toJson();
      expect(serialized['id'], 'ORD-9876ABCD');
      expect(serialized['status'], 'packed');
      expect(serialized['buyer_name'], 'Kavita Sundaram');
    });

    test('BuyerInquiry serialization from and to JSON matches backend API specification', () {
      final json = {
        'id': 'INQ-1234EFGH',
        'artisan_id': 'artisan_01',
        'product_id': 'prod_002',
        'buyer_name': 'Rajesh Singhania',
        'buyer_organization': 'Khadi Gramodyog Bhavan',
        'buyer_phone': '+91 98222 33333',
        'buyer_email': 'rajesh@khadibhavan.org',
        'buyer_location': 'Regal Building, New Delhi',
        'craft_type': 'Terracotta Pottery',
        'quantity': 500,
        'target_price_per_unit': 280.0,
        'message': 'Institutional order for national handicraft exhibition.',
        'status': 'pending',
        'artisan_response_note': '',
        'created_at': '2026-09-20T12:00:00.000',
      };

      final inquiry = BuyerInquiry.fromJson(json);
      expect(inquiry.id, 'INQ-1234EFGH');
      expect(inquiry.buyerOrganization, 'Khadi Gramodyog Bhavan');
      expect(inquiry.quantity, 500);
      expect(inquiry.targetPricePerUnit, 280.0);
      expect(inquiry.status, BuyerInquiryStatus.pending);

      final serialized = inquiry.toJson();
      expect(serialized['id'], 'INQ-1234EFGH');
      expect(serialized['status'], 'pending');
      expect(serialized['quantity'], 500);
    });
  });

  group('Orders & Inquiries UI Widget Tests', () {
    testWidgets('MyOrdersScreen displays Direct Orders and B2B Inquiries tabs and accepts inquiry', (tester) async {
      final fakeApi = FakeTestApiService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(fakeApi),
          ],
          child: const MaterialApp(
            home: MyOrdersScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify tabs exist
      expect(find.text('orders_tab_direct'), findsOneWidget);
      expect(find.text('orders_tab_b2b'), findsOneWidget);

      // Verify direct order is rendered on Tab 1
      expect(find.text('Terracotta Water Pot'), findsOneWidget);
      expect(find.text('Aarav Patel'), findsOneWidget);

      // Switch to B2B Wholesale Inquiries tab
      await tester.tap(find.text('orders_tab_b2b'));
      await tester.pumpAndSettle();

      // Verify inquiry card rendered
      expect(find.text('Pooja Hegde'), findsOneWidget);
      expect(find.text('FabIndia Regional Procurement'), findsOneWidget);
      expect(find.text('200 Units'), findsOneWidget);
      expect(find.text('Target: ₹350/ea'), findsOneWidget);
      expect(find.text('Pending Review'), findsOneWidget);
      expect(find.text('inquiry_accept_btn'), findsOneWidget);
      expect(find.text('inquiry_decline_btn'), findsOneWidget);

      // Tap Accept Inquiry button
      await tester.tap(find.text('inquiry_accept_btn'));
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.text('Accept'), findsOneWidget);
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      // Verified inquiry updated to accepted
      expect(find.text('Accepted'), findsOneWidget);
    });
  });
}
