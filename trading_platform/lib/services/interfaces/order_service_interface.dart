// --- FILE: lib/services/interfaces/order_service_interface.dart ---
import '../../models/user/address.dart';
import '../../models/user/cart_item.dart';
import '../../models/user/shipping_option.dart';
import '../../models/order/order.dart'; // 1. 修正：導入正確的 Order 模型
import '../../models/order/discount_info.dart';
// 2. 移除不再使用的 OrderCreationData 模型
// import '../../models/order/order_creation_data.dart';

abstract class IOrderService {
  Future<List<ShippingOption>> getAvailableShippingMethods(
      Address destination, List<CartItem> items);

  // 3. 修正：方法簽名與 OrderService.dart 保持一致
  Future<DiscountInfo> applyCoupon(
      String couponCode,
      List<CartItem> items
      );

  // 4. 修正：方法簽名與 OrderService.dart 保持一致，並修正返回類型
  Future<Order> createOrder({
    required int addressId,
    required int shippingOptionId,
    required List<int> cartItemIds,
    String? couponCode,
  });
}
