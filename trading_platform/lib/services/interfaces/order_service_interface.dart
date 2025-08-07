import '../../models/user/address.dart';
import '../../models/user/cart_item.dart';
import '../../models/user/shipping_option.dart';
import '../../models/order/order.dart';
import '../../models/order/order_creation_data.dart';
import '../../models/order/discount_info.dart';

abstract class IOrderService {
  Future<List<ShippingOption>> getAvailableShippingMethods(
      Address destination, List<CartItem> items);

  Future<DiscountInfo> applyCoupon(
      String couponCode,
      List<CartItem> items,
      double currentSubtotal,     // <--- 添加
      double currentShippingCost  // <--- 添加
      );

  Future<OrderModel?> createOrder(OrderCreationData data);
}

