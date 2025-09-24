// --- FILE: lib/services/order_service.dart ---
import 'package:flutter/foundation.dart';
import '../models/user/address.dart';
import '../models/user/cart_item.dart';
import '../models/user/shipping_option.dart';
import '../models/order/order.dart';
import '../models/order/discount_info.dart';
import 'api_client.dart';

class OrderService {
  final ApiClient _apiClient;
  OrderService(this._apiClient);

  // --- 關鍵新增：獲取當前使用者的訂單列表 ---
  Future<List<Order>> getMyOrders() async {
    debugPrint('[OrderService] API: Getting user orders...');
    try {
      final responseBody = await _apiClient.get('/orders');
      final List<dynamic> orderListJson = responseBody;
      final orders = orderListJson.map((json) => Order.fromJson(json)).toList();
      debugPrint('[OrderService] API: Successfully fetched ${orders.length} orders.');
      return orders;
    } catch (e) {
      debugPrint('[OrderService] API: Failed to get orders: $e');
      rethrow;
    }
  }

  // --- 關鍵新增：獲取單一訂單的詳細資訊 ---
  Future<Order> getOrderById(int orderId) async {
    debugPrint('[OrderService] API: Getting details for order #$orderId...');
    try {
      final responseBody = await _apiClient.get('/orders/$orderId');
      final order = Order.fromJson(responseBody);
      debugPrint('[OrderService] API: Successfully fetched details for order #${order.orderId}.');
      return order;
    } catch (e) {
      debugPrint('[OrderService] API: Failed to get order details for #$orderId: $e');
      rethrow;
    }
  }

  // --- (createOrder 和其他模擬方法保持不變) ---
  Future<Order> createOrder({
    required int addressId,
    required int shippingOptionId,
    required List<int> cartItemIds,
    String? couponCode,
  }) async {
    debugPrint('[OrderService] API: Creating order...');
    try {
      final responseBody = await _apiClient.post(
        '/orders',
        body: {
          'address_id': addressId,
          'shipping_option_id': shippingOptionId,
          'cart_item_ids': cartItemIds,
          if (couponCode != null && couponCode.isNotEmpty) 'coupon_code': couponCode,
        },
      );
      final createdOrder = Order.fromJson(responseBody);
      debugPrint('[OrderService] API: Successfully created order: ${createdOrder.orderId}');
      return createdOrder;
    } catch (e) {
      debugPrint('[OrderService] API: Order creation failed: $e');
      rethrow;
    }
  }

  Future<List<ShippingOption>> getAvailableShippingMethods(
      Address destination, List<CartItem> items) async {
    // 暫時保留模擬資料
    debugPrint('[OrderService] Mock: Getting shipping methods for ${destination.displayAddress}');
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ShippingOption(id: '1', name: '標準配送', cost: 60.0, description: '約 3-5 個工作天', createdAt: DateTime.now()),
      ShippingOption(id: '2', name: '快速到貨', cost: 120.0, description: '24 小時內送達', createdAt: DateTime.now()),
    ];
  }

  Future<DiscountInfo> applyCoupon(String couponCode, List<CartItem> items) async {
    // 暫時保留模擬資料
    debugPrint('[OrderService] Mock: Applying coupon: $couponCode');
    await Future.delayed(const Duration(seconds: 1));
    if (couponCode.toUpperCase() == "SALE50") {
      return DiscountInfo(discountAmount: 50, message: "已成功折抵 NT\$50", appliedCouponCode: couponCode);
    } else {
      return DiscountInfo(discountAmount: 0, message: "無效的優惠券代碼", appliedCouponCode: couponCode);
    }
  }
}
