/// Represents the status of a B2B wholesale buyer procurement inquiry.
enum BuyerInquiryStatus { pending, accepted, rejected }

extension BuyerInquiryStatusX on BuyerInquiryStatus {
  String get label {
    switch (this) {
      case BuyerInquiryStatus.pending:
        return 'Pending Review';
      case BuyerInquiryStatus.accepted:
        return 'Accepted';
      case BuyerInquiryStatus.rejected:
        return 'Declined';
    }
  }

  String toBackendString() {
    switch (this) {
      case BuyerInquiryStatus.pending:
        return 'pending';
      case BuyerInquiryStatus.accepted:
        return 'accepted';
      case BuyerInquiryStatus.rejected:
        return 'rejected';
    }
  }

  static BuyerInquiryStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'accepted':
        return BuyerInquiryStatus.accepted;
      case 'rejected':
      case 'declined':
        return BuyerInquiryStatus.rejected;
      case 'pending':
      default:
        return BuyerInquiryStatus.pending;
    }
  }
}

/// Model for B2B wholesale procurement inquiries submitted by institutional buyers / NGOs.
class BuyerInquiry {
  final String id;
  final String? artisanId;
  final String? productId;
  final String buyerName;
  final String buyerOrganization;
  final String buyerPhone;
  final String buyerEmail;
  final String buyerLocation;
  final String craftType;
  final int quantity;
  final double? targetPricePerUnit;
  final String message;
  final BuyerInquiryStatus status;
  final String artisanResponseNote;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BuyerInquiry({
    required this.id,
    this.artisanId,
    this.productId,
    required this.buyerName,
    required this.buyerOrganization,
    required this.buyerPhone,
    required this.buyerEmail,
    required this.buyerLocation,
    required this.craftType,
    required this.quantity,
    this.targetPricePerUnit,
    required this.message,
    required this.status,
    required this.artisanResponseNote,
    required this.createdAt,
    this.updatedAt,
  });

  factory BuyerInquiry.fromJson(Map<String, dynamic> json) {
    return BuyerInquiry(
      id: json['id'] as String? ?? '',
      artisanId: json['artisan_id'] as String?,
      productId: json['product_id'] as String?,
      buyerName: json['buyer_name'] as String? ?? '',
      buyerOrganization: json['buyer_organization'] as String? ?? '',
      buyerPhone: json['buyer_phone'] as String? ?? '',
      buyerEmail: json['buyer_email'] as String? ?? '',
      buyerLocation: json['buyer_location'] as String? ?? '',
      craftType: json['craft_type'] as String? ?? 'Handicrafts',
      quantity: json['quantity'] as int? ?? 1,
      targetPricePerUnit: (json['target_price_per_unit'] as num?)?.toDouble(),
      message: json['message'] as String? ?? '',
      status: BuyerInquiryStatusX.fromString(json['status'] as String? ?? 'pending'),
      artisanResponseNote: json['artisan_response_note'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (artisanId != null) 'artisan_id': artisanId,
      if (productId != null) 'product_id': productId,
      'buyer_name': buyerName,
      'buyer_organization': buyerOrganization,
      'buyer_phone': buyerPhone,
      'buyer_email': buyerEmail,
      'buyer_location': buyerLocation,
      'craft_type': craftType,
      'quantity': quantity,
      if (targetPricePerUnit != null) 'target_price_per_unit': targetPricePerUnit,
      'message': message,
      'status': status.toBackendString(),
      'artisan_response_note': artisanResponseNote,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  BuyerInquiry copyWith({
    String? id,
    String? artisanId,
    String? productId,
    String? buyerName,
    String? buyerOrganization,
    String? buyerPhone,
    String? buyerEmail,
    String? buyerLocation,
    String? craftType,
    int? quantity,
    double? targetPricePerUnit,
    String? message,
    BuyerInquiryStatus? status,
    String? artisanResponseNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BuyerInquiry(
      id: id ?? this.id,
      artisanId: artisanId ?? this.artisanId,
      productId: productId ?? this.productId,
      buyerName: buyerName ?? this.buyerName,
      buyerOrganization: buyerOrganization ?? this.buyerOrganization,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      buyerEmail: buyerEmail ?? this.buyerEmail,
      buyerLocation: buyerLocation ?? this.buyerLocation,
      craftType: craftType ?? this.craftType,
      quantity: quantity ?? this.quantity,
      targetPricePerUnit: targetPricePerUnit ?? this.targetPricePerUnit,
      message: message ?? this.message,
      status: status ?? this.status,
      artisanResponseNote: artisanResponseNote ?? this.artisanResponseNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
