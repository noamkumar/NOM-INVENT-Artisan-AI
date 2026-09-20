/// Represents the fulfilment status of an artisan order.
enum OrderStatus { newOrder, packed, shipped, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get labelKey {
    switch (this) {
      case OrderStatus.newOrder:   return 'order_status_new';
      case OrderStatus.packed:     return 'order_status_packed';
      case OrderStatus.shipped:    return 'order_status_shipped';
      case OrderStatus.delivered:  return 'order_status_delivered';
      case OrderStatus.cancelled:  return 'order_status_cancelled';
    }
  }

  /// Returns the next logical status, or null if terminal.
  OrderStatus? get next {
    switch (this) {
      case OrderStatus.newOrder:  return OrderStatus.packed;
      case OrderStatus.packed:    return OrderStatus.shipped;
      case OrderStatus.shipped:   return OrderStatus.delivered;
      case OrderStatus.delivered: return null;
      case OrderStatus.cancelled: return null;
    }
  }
}

class Order {
  final String id;
  final String productTitle;
  final String? productTitleHi;
  final String productCategory;
  final String productImagePath;
  final String buyerName;
  final String buyerLocation;
  final double amount;
  final int quantity;
  final OrderStatus status;
  final DateTime placedAt;
  final DateTime? shippedAt;
  final String? trackingId;

  final String? artisanId;
  final String? productId;
  final String? buyerPhone;

  const Order({
    required this.id,
    this.artisanId,
    this.productId,
    required this.productTitle,
    this.productTitleHi,
    required this.productCategory,
    required this.productImagePath,
    required this.buyerName,
    required this.buyerLocation,
    this.buyerPhone,
    required this.amount,
    required this.quantity,
    required this.status,
    required this.placedAt,
    this.shippedAt,
    this.trackingId,
  });

  String get buyerCity => buyerLocation.isNotEmpty
      ? buyerLocation.split(',').last.trim()
      : 'India';

  static OrderStatus statusFromString(String statusStr) {
    switch (statusStr.toLowerCase()) {
      case 'neworder':
      case 'new_order':
      case 'new':
        return OrderStatus.newOrder;
      case 'packed':
        return OrderStatus.packed;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.newOrder;
    }
  }

  static String statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return 'newOrder';
      case OrderStatus.packed:
        return 'packed';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String? ?? '',
      artisanId: json['artisan_id'] as String?,
      productId: json['product_id'] as String?,
      productTitle: json['product_title'] as String? ?? '',
      productTitleHi: json['product_title_hi'] as String?,
      productCategory: json['product_category'] as String? ?? 'General',
      productImagePath: json['product_image_url'] as String? ?? '',
      buyerName: json['buyer_name'] as String? ?? 'Buyer',
      buyerLocation: json['buyer_location'] as String? ?? '',
      buyerPhone: json['buyer_phone'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
      status: statusFromString(json['status'] as String? ?? 'newOrder'),
      placedAt: json['placed_at'] != null
          ? DateTime.tryParse(json['placed_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      shippedAt: json['shipped_at'] != null
          ? DateTime.tryParse(json['shipped_at'].toString())
          : null,
      trackingId: json['tracking_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (artisanId != null) 'artisan_id': artisanId,
      if (productId != null) 'product_id': productId,
      'product_title': productTitle,
      if (productTitleHi != null) 'product_title_hi': productTitleHi,
      'product_category': productCategory,
      'product_image_url': productImagePath,
      'buyer_name': buyerName,
      'buyer_location': buyerLocation,
      if (buyerPhone != null) 'buyer_phone': buyerPhone,
      'amount': amount,
      'quantity': quantity,
      'status': statusToString(status),
      'placed_at': placedAt.toIso8601String(),
      if (shippedAt != null) 'shipped_at': shippedAt!.toIso8601String(),
      if (trackingId != null) 'tracking_id': trackingId,
    };
  }

  Order copyWith({
    String? id,
    String? artisanId,
    String? productId,
    String? productTitle,
    String? productTitleHi,
    String? productCategory,
    String? productImagePath,
    String? buyerName,
    String? buyerLocation,
    String? buyerPhone,
    double? amount,
    int? quantity,
    OrderStatus? status,
    DateTime? placedAt,
    DateTime? shippedAt,
    String? trackingId,
  }) {
    return Order(
      id: id ?? this.id,
      artisanId: artisanId ?? this.artisanId,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productTitleHi: productTitleHi ?? this.productTitleHi,
      productCategory: productCategory ?? this.productCategory,
      productImagePath: productImagePath ?? this.productImagePath,
      buyerName: buyerName ?? this.buyerName,
      buyerLocation: buyerLocation ?? this.buyerLocation,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      amount: amount ?? this.amount,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      placedAt: placedAt ?? this.placedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      trackingId: trackingId ?? this.trackingId,
    );
  }
}
