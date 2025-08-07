// lib/models/order/order_creation_data.dart
import '../user/address.dart';
import '../user/cart_item.dart';

class OrderCreationData {
  final String userId;
  final List<CartItem> items;
  final Address shippingAddress;
  final String shippingMethodId; // ID of the selected ShippingOption
  final String paymentMethodId;  // e.g., "credit_card_tok_xxxx", "paypal_id_xxxx"
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final String? couponCode;
  final double totalAmount;
  final String? customerNotes; // Optional customer notes

  OrderCreationData({
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.shippingMethodId,
    required this.paymentMethodId,
    required this.subtotal,
    required this.shippingFee,
    required this.discountAmount,
    this.couponCode,
    required this.totalAmount,
    this.customerNotes,
  });
}
