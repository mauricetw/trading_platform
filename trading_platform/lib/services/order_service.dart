// lib/services/order_service.dart
import 'dart:math';
import '../models/user/address.dart';
import '../models/user/cart_item.dart';
import '../models/user/shipping_option.dart';
import '../models/order/order.dart';
import '../models/order/order_creation_data.dart';
import '../models/order/discount_info.dart';
import 'interfaces/order_service_interface.dart';

class OrderService implements IOrderService {
  Future<void> _simulateNetworkDelay({int minDelay = 200, int maxDelay = 1000}) async {
    await Future.delayed(Duration(milliseconds: Random().nextInt(maxDelay - minDelay) + minDelay));
  }

  @override
  Future<List<ShippingOption>> getAvailableShippingMethods(
      Address destination, List<CartItem> items) async {
    await _simulateNetworkDelay();
    print('[OrderService] Mock: Getting shipping methods for ${destination.displayAddress}');
    if (items.isEmpty) return [];

    List<ShippingOption> options = [];
    DateTime now = DateTime.now();
    DateTime mockCreatedAt = now.subtract(const Duration(days: 30));

    if (destination.country == '台灣') {
      options.add(ShippingOption( // 如果這裡的 ShippingOption 標紅，問題可能在導入或 ShippingOption 類本身
          id: 'standard_tw',
          name: '標準宅配 (台灣)',
          description: '預計 3-5 個工作日送達',
          cost: 80.0,
          isEnabled: true,
          createdAt: mockCreatedAt,
          updatedAt: now.subtract(const Duration(days: 1))
      ));
      options.add(ShippingOption(
          id: 'express_tw',
          name: '快速到貨 (台灣)',
          description: '預計 1-2 個工作日送達',
          cost: 150.0,
          isEnabled: true,
          createdAt: mockCreatedAt.add(const Duration(days: 2)),
          updatedAt: now
      ));
      if (destination.city == '台北市' || destination.city == '新北市') {
        options.add(ShippingOption(
            id: 'sameday_tpe',
            name: '當日配 (雙北地區)',
            description: '下午 2 點前下單，當日送達',
            cost: 250.0,
            isEnabled: true,
            createdAt: mockCreatedAt.add(const Duration(days: 5)),
            updatedAt: now
        ));
      }
      options.add(ShippingOption(
          id: 'old_promo_tw',
          name: '舊促銷運送 (已停用)',
          description: '此運送方式已不再提供',
          cost: 50.0,
          isEnabled: false,
          createdAt: mockCreatedAt.subtract(const Duration(days: 60)),
          updatedAt: mockCreatedAt.subtract(const Duration(days: 10))
      ));
    } else {
      options.add(ShippingOption(
          id: 'international_std',
          name: '國際標準運送',
          description: '預計 7-14 個工作日送達',
          cost: 300.0,
          isEnabled: true,
          createdAt: mockCreatedAt,
          updatedAt: now
      ));
    }
    return options;
  }

  @override
  Future<DiscountInfo> applyCoupon(String couponCode, List<CartItem> items, double currentSubtotal, double currentShippingCost) async {
    await _simulateNetworkDelay();
    print('[OrderService] Mock: Applying coupon: $couponCode');

    // 檢查點 1: items.isEmpty 的處理
    if (items.isEmpty) {
      return DiscountInfo( // <--- 檢查此行是否標紅
        discountAmount: 0,
        message: "購物車是空的",
        appliedCouponCode: couponCode,
        isFreeShipping: false,
      );
    }

    String upperCaseCode = couponCode.toUpperCase();

    // 檢查點 2: SAVE10
    if (upperCaseCode == 'SAVE10') {
      double discount = currentSubtotal * 0.1;
      return DiscountInfo( // <--- 檢查此行是否標紅
          discountAmount: discount,
          message: '優惠券 SAVE10 已套用 - 享有 9 折優惠！',
          appliedCouponCode: couponCode,
          isFreeShipping: false);
    }
    // 檢查點 3: FREESHIP
    else if (upperCaseCode == 'FREESHIP') {
      return DiscountInfo( // <--- 檢查此行是否標紅
          discountAmount: currentShippingCost,
          message: '優惠券 FREESHIP 已套用 - 免運費！',
          appliedCouponCode: couponCode,
          isFreeShipping: true);
    }
    // 檢查點 4: FIXED20OFF
    else if (upperCaseCode == 'FIXED20OFF' && currentSubtotal >= 100) {
      return DiscountInfo( // <--- 檢查此行是否標紅
          discountAmount: 20.0,
          message: '優惠券 FIXED20OFF 已套用 - 折扣 \$20！',
          appliedCouponCode: couponCode,
          isFreeShipping: false);
    }
    // 檢查點 5: INVALIDCODE
    else if (upperCaseCode == 'INVALIDCODE') {
      return DiscountInfo( // <--- 檢查此行是否標紅
          discountAmount: 0,
          message: "無效的優惠券代碼。",
          appliedCouponCode: couponCode,
          isFreeShipping: false);
    }

    // 檢查點 6: 默認返回
    return DiscountInfo( // <--- 檢查此行是否標紅
        discountAmount: 0,
        message: "此優惠券代碼 ($couponCode) 無法使用或不適用於您的訂單。",
        appliedCouponCode: couponCode,
        isFreeShipping: false);
  }

  @override
  Future<OrderModel?> createOrder(OrderCreationData data) async {
    await _simulateNetworkDelay(minDelay: 800, maxDelay: 2000);
    print('[OrderService] Mock: Creating order for user: ${data.userId}');
    print('[OrderService] Mock: Total: ${data.totalAmount}, Payment: ${data.paymentMethodId}');

    if (data.items.isEmpty) {
      print('[OrderService] Mock: Order creation failed - cart is empty.');
      throw Exception("無法創建訂單：購物車是空的。");
    }
    if (data.totalAmount < 0) {
      print('[OrderService] Mock: Order creation failed - total amount is negative.');
      throw Exception("無法創建訂單：總金額異常。");
    }

    final createdOrder = OrderModel(
      id: 'db_id_${DateTime.now().microsecondsSinceEpoch}',
      orderId: 'MOCK-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${Random().nextInt(99999).toString().padLeft(5, '0')}',
      productName: data.items.map((item) => item.productName).join(', ').substring(0, min(50, data.items.map((item) => item.productName).join(', ').length)) + (data.items.length > 2 ? "..." : ""),
      totalPrice: data.totalAmount,
      orderDate: DateTime.now(),
      currentStatus: OrderStatus.established,
      statusHistory: [
        OrderStatusUpdate(
          status: OrderStatus.established,
          timestamp: DateTime.now(),
          description: "訂單已成功創建並等待付款。 ${data.customerNotes != null && data.customerNotes!.isNotEmpty ? '顧客備註: ${data.customerNotes}' : ''}".trim(),
        ),
      ],
    );
    print('[OrderService] Mock: Created order: ${createdOrder.orderId}');
    return createdOrder;
  }
}
