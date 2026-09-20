import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/api_config.dart';
import '../models/product.dart';
import '../../features/orders/models/order.dart';
import '../../features/orders/models/buyer_inquiry.dart';

/// Abstract API service contract
abstract class ApiService {
  Future<List<Product>> getProducts({String? artisanId, String? category});
  Future<Product> createProduct(Product product, {String? artisanId});
  Future<Product> updateProduct(Product product);
  Future<bool> deleteProduct(String id);

  // Orders API
  Future<List<Order>> getOrders({String? artisanId, String? status});
  Future<Order> createOrder(Order order, {String? artisanId});
  Future<Order> updateOrderStatus(String orderId, OrderStatus status, {String? trackingId});

  // B2B Inquiries API
  Future<List<BuyerInquiry>> getBuyerInquiries({String? artisanId, String? status});
  Future<BuyerInquiry> updateBuyerInquiryStatus(String inquiryId, String status, {String? responseNote});
}

/// Live HTTP implementation connecting to FastAPI `/api/v1/products`, `/api/v1/orders`, and `/api/v1/market`
class HttpApiService implements ApiService {
  final Dio _dio;
  final String? _explicitBaseUrl;

  HttpApiService({String? baseUrl, Dio? dio})
      : _explicitBaseUrl = baseUrl,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            );

  void _syncBaseUrl() {
    final activeUrl = _explicitBaseUrl ?? ApiConfig.baseUrl;
    _dio.options.baseUrl = activeUrl;
  }

  @override
  Future<List<Product>> getProducts({String? artisanId, String? category}) async {
    _syncBaseUrl();
    try {
      final queryParams = <String, dynamic>{
        if (artisanId != null && artisanId.isNotEmpty) 'artisan_id': artisanId,
        if (category != null && category.isNotEmpty) 'category': category,
        'limit': 100,
      };

      debugPrint('[HttpApiService] GET ${_dio.options.baseUrl}/api/v1/products');
      final response = await _dio.get(
        '/api/v1/products',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        return list
            .map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('[HttpApiService] getProducts failed: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<Product> createProduct(Product product, {String? artisanId}) async {
    _syncBaseUrl();
    try {
      final payload = product.toBackendJson(artisanId: artisanId);
      debugPrint('[HttpApiService] POST ${_dio.options.baseUrl}/api/v1/products: ${product.title}');
      final response = await _dio.post('/api/v1/products', data: payload);

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return Product.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to create product, status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      debugPrint('[HttpApiService] createProduct failed: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    _syncBaseUrl();
    try {
      final payload = product.toBackendJson();
      debugPrint('[HttpApiService] PUT ${_dio.options.baseUrl}/api/v1/products/${product.id}');
      final response = await _dio.put('/api/v1/products/${product.id}', data: payload);

      if (response.statusCode == 200 && response.data != null) {
        return Product.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to update product, status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      debugPrint('[HttpApiService] updateProduct failed: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<bool> deleteProduct(String id) async {
    _syncBaseUrl();
    try {
      debugPrint('[HttpApiService] DELETE ${_dio.options.baseUrl}/api/v1/products/$id');
      final response = await _dio.delete('/api/v1/products/$id');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('[HttpApiService] deleteProduct failed: ${e.message}');
      rethrow;
    }
  }

  // --- Orders API Implementation ---
  @override
  Future<List<Order>> getOrders({String? artisanId, String? status}) async {
    _syncBaseUrl();
    try {
      final queryParams = <String, dynamic>{
        if (artisanId != null && artisanId.isNotEmpty) 'artisan_id': artisanId,
        if (status != null && status.isNotEmpty) 'status': status,
        'limit': 100,
      };

      debugPrint('[HttpApiService] GET ${_dio.options.baseUrl}/api/v1/orders');
      final response = await _dio.get(
        '/api/v1/orders',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        return list
            .map((item) => Order.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('[HttpApiService] getOrders failed: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<Order> createOrder(Order order, {String? artisanId}) async {
    _syncBaseUrl();
    try {
      final payload = order.toJson();
      if (artisanId != null && artisanId.isNotEmpty) {
        payload['artisan_id'] = artisanId;
      }
      debugPrint('[HttpApiService] POST ${_dio.options.baseUrl}/api/v1/orders');
      final response = await _dio.post('/api/v1/orders', data: payload);

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return Order.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to create order, status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      debugPrint('[HttpApiService] createOrder failed: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<Order> updateOrderStatus(String orderId, OrderStatus status, {String? trackingId}) async {
    _syncBaseUrl();
    try {
      final payload = <String, dynamic>{
        'status': Order.statusToString(status),
        'tracking_id': ?trackingId,
      };
      debugPrint('[HttpApiService] PUT ${_dio.options.baseUrl}/api/v1/orders/$orderId/status -> ${status.name}');
      final response = await _dio.put('/api/v1/orders/$orderId/status', data: payload);

      if (response.statusCode == 200 && response.data != null) {
        return Order.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to update order status, status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      debugPrint('[HttpApiService] updateOrderStatus failed: ${e.message}');
      rethrow;
    }
  }

  // --- B2B Inquiries API Implementation ---
  @override
  Future<List<BuyerInquiry>> getBuyerInquiries({String? artisanId, String? status}) async {
    _syncBaseUrl();
    try {
      final queryParams = <String, dynamic>{
        if (artisanId != null && artisanId.isNotEmpty) 'artisan_id': artisanId,
        if (status != null && status.isNotEmpty) 'status': status,
        'limit': 100,
      };

      debugPrint('[HttpApiService] GET ${_dio.options.baseUrl}/api/v1/market/inquiries');
      final response = await _dio.get(
        '/api/v1/market/inquiries',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        return list
            .map((item) => BuyerInquiry.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('[HttpApiService] getBuyerInquiries failed: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<BuyerInquiry> updateBuyerInquiryStatus(String inquiryId, String status, {String? responseNote}) async {
    _syncBaseUrl();
    try {
      final payload = <String, dynamic>{
        'status': status,
        'artisan_response_note': ?responseNote,
      };
      debugPrint('[HttpApiService] PUT ${_dio.options.baseUrl}/api/v1/market/inquiries/$inquiryId/status -> $status');
      final response = await _dio.put('/api/v1/market/inquiries/$inquiryId/status', data: payload);

      if (response.statusCode == 200 && response.data != null) {
        return BuyerInquiry.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Failed to update buyer inquiry status, status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      debugPrint('[HttpApiService] updateBuyerInquiryStatus failed: ${e.message}');
      rethrow;
    }
  }
}

/// Mock API service simulating backend endpoints with network latency
class MockApiService implements ApiService {
  final List<Product> _remoteProducts = [];
  final List<Order> _remoteOrders = [];
  final List<BuyerInquiry> _remoteInquiries = [];

  bool simulateNetworkFailure = false;

  @override
  Future<List<Product>> getProducts({String? artisanId, String? category}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (simulateNetworkFailure) {
      throw Exception('Simulated network error: Unable to fetch products from backend');
    }
    return List.from(_remoteProducts);
  }

  @override
  Future<Product> createProduct(Product product, {String? artisanId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (simulateNetworkFailure) {
      throw Exception('Simulated network error: Unable to create product');
    }
    final created = product.copyWith(
      id: product.id.isEmpty ? 'prod_${DateTime.now().millisecondsSinceEpoch}' : product.id,
      status: ProductStatus.live,
    );
    _remoteProducts.removeWhere((p) => p.id == created.id);
    _remoteProducts.insert(0, created);
    return created;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (simulateNetworkFailure) {
      throw Exception('Simulated network error: Unable to update product');
    }
    final index = _remoteProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _remoteProducts[index] = product;
    } else {
      _remoteProducts.insert(0, product);
    }
    return product;
  }

  @override
  Future<bool> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (simulateNetworkFailure) {
      throw Exception('Simulated network error: Unable to delete product');
    }
    _remoteProducts.removeWhere((p) => p.id == id);
    return true;
  }

  @override
  Future<List<Order>> getOrders({String? artisanId, String? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (simulateNetworkFailure) {
      throw Exception('Simulated network error: Unable to fetch orders');
    }
    var result = List<Order>.from(_remoteOrders);
    if (status != null && status.isNotEmpty) {
      result = result.where((o) => Order.statusToString(o.status) == status).toList();
    }
    return result;
  }

  @override
  Future<Order> createOrder(Order order, {String? artisanId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (simulateNetworkFailure) {
      throw Exception('Simulated network error: Unable to create order');
    }
    _remoteOrders.removeWhere((o) => o.id == order.id);
    _remoteOrders.insert(0, order);
    return order;
  }

  @override
  Future<Order> updateOrderStatus(String orderId, OrderStatus status, {String? trackingId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _remoteOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final updated = _remoteOrders[index].copyWith(
        status: status,
        trackingId: trackingId ?? _remoteOrders[index].trackingId,
      );
      _remoteOrders[index] = updated;
      return updated;
    }
    throw Exception('Order $orderId not found');
  }

  @override
  Future<List<BuyerInquiry>> getBuyerInquiries({String? artisanId, String? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (simulateNetworkFailure) {
      throw Exception('Simulated network error: Unable to fetch inquiries');
    }
    var result = List<BuyerInquiry>.from(_remoteInquiries);
    if (status != null && status.isNotEmpty) {
      result = result.where((i) => i.status.toBackendString() == status).toList();
    }
    return result;
  }

  @override
  Future<BuyerInquiry> updateBuyerInquiryStatus(String inquiryId, String status, {String? responseNote}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _remoteInquiries.indexWhere((i) => i.id == inquiryId);
    if (index != -1) {
      final updated = _remoteInquiries[index].copyWith(
        status: BuyerInquiryStatusX.fromString(status),
        artisanResponseNote: responseNote ?? _remoteInquiries[index].artisanResponseNote,
      );
      _remoteInquiries[index] = updated;
      return updated;
    }
    throw Exception('Inquiry $inquiryId not found');
  }
}
