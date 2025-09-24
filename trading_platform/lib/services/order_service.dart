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
    final responseBody = await _apiClient.get('/orders');
    final List<dynamic> orderListJson = responseBody;
    return orderListJson.map((json) => Order.fromJson(json)).toList();
  }

  /// 根據目的地和商品獲取可用的運送方式
  Future<List<ShippingOption>> getAvailableShippingMethods(
      Address destination, List<CartItem> items) async {
    // TODO: 未來在此處呼叫真實的後端 API - GET /shipping-options?address_id=...
    debugPrint('[OrderService] Mock: Getting shipping methods for ${destination.displayAddress}');
    if (items.isEmpty) return [];

    // 暫時回傳固定的模擬資料
    await Future.delayed(const Duration(milliseconds: 500));
    // --- 關鍵修正：確保模擬資料符合 ShippingOption 模型 ---
    return [
      ShippingOption(id: '1', name: '標準配送', cost: 60.0, description: '約 3-5 個工作天', createdAt: DateTime.now()),
      ShippingOption(id: '2', name: '快速到貨', cost: 120.0, description: '24 小時內送達', createdAt: DateTime.now()),
    ];
  }

  /// 驗證並套用優惠券代碼
  Future<DiscountInfo> applyCoupon(String couponCode, List<CartItem> items) async {
    // TODO: 未來在此處呼叫真實的後端 API - POST /coupons/apply
    debugPrint('[OrderService] Mock: Applying coupon: $couponCode');

    // 暫時保留並返回模擬資料
    await Future.delayed(const Duration(seconds: 1));
    if (couponCode.toUpperCase() == "SALE50") {
      return DiscountInfo(discountAmount: 50, message: "已成功折抵 NT\$50", appliedCouponCode: couponCode);
    } else {
      // --- 關鍵修正：為無效的優惠券補上 discountAmount: 0 ---
      return DiscountInfo(discountAmount: 0, message: "無效的優惠券代碼", appliedCouponCode: couponCode);
    }
  }

  /// 建立一筆新訂單
  Future<Order> createOrder({
    required int addressId,
    required int shippingOptionId,
    required List<int> cartItemIds,
    String? couponCode,
  }) async {
    debugPrint('[OrderService] Real: Creating order for user...');
    debugPrint('[OrderService] Real: addressId: $addressId, shippingOptionId: $shippingOptionId');

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
      debugPrint('[OrderService] Real: Successfully created order: ${createdOrder.orderId}');
      return createdOrder;

    } catch (e) {
      debugPrint('[OrderService] Real: Order creation failed: $e');
      rethrow;
    }
  }
}
