import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/services/api_service.dart';
import '../models/order.dart';
import '../models/buyer_inquiry.dart';
import '../services/label_maker_service.dart';

class OrdersNotifier extends StateNotifier<List<Order>> {
  final ApiService _apiService;
  final String _artisanId;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  OrdersNotifier(this._apiService, this._artisanId) : super([]) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    try {
      final orders = await _apiService.getOrders(artisanId: _artisanId);
      state = orders;
    } catch (_) {
      // Retain existing state if network call fails
    } finally {
      _isLoading = false;
    }
  }

  Future<void> updateStatus(String orderId, OrderStatus newStatus, {String? trackingId}) async {
    // 1. Optimistic update in UI
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(
            status: newStatus,
            trackingId: trackingId ?? order.trackingId,
            shippedAt: newStatus == OrderStatus.shipped && order.shippedAt == null
                ? DateTime.now()
                : order.shippedAt,
          )
        else
          order,
    ];

    // Invalidate cached packaging label whenever order status changes
    LabelMakerService.invalidateCache(orderId);

    // 2. Persist to real backend
    try {
      final updated = await _apiService.updateOrderStatus(orderId, newStatus, trackingId: trackingId);
      state = [
        for (final order in state)
          if (order.id == orderId) updated else order,
      ];
    } catch (_) {
      // Backend error logged, state keeps optimistic update
    }
  }

  Future<Order> createOrder(Order order) async {
    final created = await _apiService.createOrder(order, artisanId: _artisanId);
    state = [created, ...state.where((o) => o.id != created.id)];
    return created;
  }
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<Order>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final userProfile = ref.watch(userProfileProvider);
  return OrdersNotifier(apiService, userProfile.id);
});

/// Currently selected filter chip (defaults to OrderStatus.newOrder at start of session, null = show all).
final selectedOrderFilterProvider = StateProvider<OrderStatus?>((ref) => OrderStatus.newOrder);

/// Filtered list of orders based on [selectedOrderFilterProvider].
final filteredOrdersProvider = Provider<List<Order>>((ref) {
  final orders = ref.watch(ordersProvider);
  final filter = ref.watch(selectedOrderFilterProvider);
  if (filter == null) return orders;
  return orders.where((o) => o.status == filter).toList();
});

/// Map of order count per OrderStatus (and null for all orders).
final orderCountsByStatusProvider = Provider<Map<OrderStatus?, int>>((ref) {
  final orders = ref.watch(ordersProvider);
  final counts = <OrderStatus?, int>{null: orders.length};
  for (final status in OrderStatus.values) {
    counts[status] = orders.where((o) => o.status == status).length;
  }
  return counts;
});

// ─────────────────────────────────────────────────────────────────────────────
// B2B Wholesale Buyer Inquiries State Management
// ─────────────────────────────────────────────────────────────────────────────

class InquiriesNotifier extends StateNotifier<List<BuyerInquiry>> {
  final ApiService _apiService;
  final String _artisanId;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  InquiriesNotifier(this._apiService, this._artisanId) : super([]) {
    loadInquiries();
  }

  Future<void> loadInquiries() async {
    _isLoading = true;
    try {
      final list = await _apiService.getBuyerInquiries(artisanId: _artisanId);
      state = list;
    } catch (_) {
      // Retain existing state if error
    } finally {
      _isLoading = false;
    }
  }

  Future<void> acceptInquiry(String id, {String? note}) async {
    // Optimistic update
    state = [
      for (final inq in state)
        if (inq.id == id)
          inq.copyWith(
            status: BuyerInquiryStatus.accepted,
            artisanResponseNote: note ?? inq.artisanResponseNote,
            updatedAt: DateTime.now(),
          )
        else
          inq,
    ];

    try {
      final updated = await _apiService.updateBuyerInquiryStatus(id, 'accepted', responseNote: note);
      state = [
        for (final inq in state)
          if (inq.id == id) updated else inq,
      ];
    } catch (_) {}
  }

  Future<void> rejectInquiry(String id, {String? note}) async {
    // Optimistic update
    state = [
      for (final inq in state)
        if (inq.id == id)
          inq.copyWith(
            status: BuyerInquiryStatus.rejected,
            artisanResponseNote: note ?? inq.artisanResponseNote,
            updatedAt: DateTime.now(),
          )
        else
          inq,
    ];

    try {
      final updated = await _apiService.updateBuyerInquiryStatus(id, 'rejected', responseNote: note);
      state = [
        for (final inq in state)
          if (inq.id == id) updated else inq,
      ];
    } catch (_) {}
  }
}

final inquiriesProvider =
    StateNotifierProvider<InquiriesNotifier, List<BuyerInquiry>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final userProfile = ref.watch(userProfileProvider);
  return InquiriesNotifier(apiService, userProfile.id);
});
