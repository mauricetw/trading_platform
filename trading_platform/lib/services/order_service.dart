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


  // --- 買家相關 API ---

  // --- 獲取當前使用者的訂單列表 ---
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

  // --- 獲取單一訂單的詳細資訊 ---
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

  /// 建立一筆新訂單
  Future<Order> createOrder({
    required int addressId,
    required int shippingOptionId,
    required List<int> cartItemIds,
    String? couponCode,
  }) async {
    debugPrint('[OrderService] Real: Creating order with addressId: $addressId, shippingOptionId: $shippingOptionId');
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


  // --- 賣家相關 API ---

  /// 獲取賣家自己收到的所有訂單
  Future<List<Order>> getMySellerOrders({OrderStatus? status}) async {
    debugPrint('[OrderService] API: Getting SELLER orders with status: ${status?.name}');
    try {
      final queryParams = <String, String>{};
      if (status != null) {
        queryParams['status'] = status.name; // 將 enum 轉換為後端期望的字串
      }
      final responseBody = await _apiClient.get('/seller/orders', queryParams: queryParams);
      final List<dynamic> orderListJson = responseBody;
      final orders = orderListJson.map((json) => Order.fromJson(json)).toList();
      debugPrint('[OrderService] API: Successfully fetched ${orders.length} seller orders.');
      return orders;
    } catch(e) {
      debugPrint('[OrderService] API: Failed to get seller orders: $e');
      rethrow;
    }
  }

  /// 賣家更新訂單狀態
  Future<Order> updateOrderStatusAsSeller({
    required int orderId,
    required OrderStatus newStatus,
    String? description,
  }) async {
    debugPrint('[OrderService] API: Seller updating order #$orderId to status: ${newStatus.name}');
    try {
      final responseBody = await _apiClient.patch(
        '/seller/orders/$orderId/status',
        body: {
          'status': newStatus.name,
          if (description != null) 'description': description,
        },
      );
      return Order.fromJson(responseBody);
    } catch(e) {
      debugPrint('[OrderService] API: Failed to update order status for #$orderId: $e');
      rethrow;
    }
  }


  // --- 運送方式管理 API ---

  /// --- 獲取指定賣家的可用運送方式 (給結帳頁使用) ---
  Future<List<ShippingOption>> getAvailableShippingMethods(int sellerId) async {
    debugPrint('[OrderService] API: Getting shipping methods for sellerId: $sellerId');
    try {
      final responseBody = await _apiClient.get(
        '/shipping-options',
        queryParams: {'seller_id': sellerId.toString()},
      );
      final List<dynamic> optionsJson = responseBody;
      return optionsJson.map((json) => ShippingOption.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[OrderService] API: Failed to get available shipping options: $e');
      rethrow;
    }
  }

  /// --- 獲取賣家自己的所有運送方式 (給設定頁使用) ---
  Future<List<ShippingOption>> getMyShippingOptions() async {
    debugPrint('[OrderService] API: Getting MY shipping options...');
    try {
      // 呼叫新的 /me 端點，不再需要傳遞任何參數
      final responseBody = await _apiClient.get('/shipping-options/me');
      final List<dynamic> optionsJson = responseBody;
      return optionsJson.map((json) => ShippingOption.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[OrderService] API: Failed to get MY shipping options: $e');
      rethrow;
    }
  }

  /// --- 為當前賣家新增一個運送方式 ---
  Future<ShippingOption> addShippingOption(Map<String, dynamic> data) async {
    debugPrint('[OrderService] API: Adding new shipping option...');
    try {
      final responseBody = await _apiClient.post('/shipping-options', body: data);
      return ShippingOption.fromJson(responseBody);
    } catch (e) {
      debugPrint('[OrderService] API: Failed to add shipping option: $e');
      rethrow;
    }
  }

  /// --- 更新一個已存在的運送方式 ---
  Future<ShippingOption> updateShippingOption(int optionId, Map<String, dynamic> data) async {
    debugPrint('[OrderService] API: Updating shipping option #$optionId...');
    try {
      final responseBody = await _apiClient.put('/shipping-options/$optionId', body: data);
      return ShippingOption.fromJson(responseBody);
    } catch (e) {
      debugPrint('[OrderService] API: Failed to update shipping option #$optionId: $e');
      rethrow;
    }
  }

  /// --- 刪除一個運送方式 ---
  Future<void> deleteShippingOption(int optionId) async {
    debugPrint('[OrderService] API: Deleting shipping option #$optionId...');
    try {
      // 呼叫後端的 DELETE API，成功時後端會回傳 204 No Content
      await _apiClient.delete('/shipping-options/$optionId');
      debugPrint('[OrderService] API: Successfully deleted shipping option #$optionId.');
    } catch (e) {
      debugPrint('[OrderService] API: Failed to delete shipping option #$optionId: $e');
      rethrow;
    }
  }

  /// 驗證並套用優惠券代碼 (保留模擬邏輯)
  Future<DiscountInfo> applyCoupon(String couponCode, List<CartItem> items) async {
    debugPrint('[OrderService] Mock: Applying coupon: $couponCode');
    // TODO: 未來在此處呼叫真實的後端 API - POST /coupons/apply
    await Future.delayed(const Duration(seconds: 1));
    if (couponCode.toUpperCase() == "SALE50") {
      return DiscountInfo(discountAmount: 50, message: "已成功折抵 NT\$50", appliedCouponCode: couponCode);
    } else {
      return DiscountInfo(discountAmount: 0, message: "無效的優惠券代碼", appliedCouponCode: couponCode);
    }
  }


}
