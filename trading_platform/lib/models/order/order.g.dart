// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderStatusUpdate _$OrderStatusUpdateFromJson(Map<String, dynamic> json) =>
    OrderStatusUpdate(
      status: _orderStatusFromJson(json['status'] as String?),
      timestamp: _dateTimeFromJson(json['timestamp'] as String),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$OrderStatusUpdateToJson(OrderStatusUpdate instance) =>
    <String, dynamic>{
      'status': _orderStatusToJson(instance.status),
      'timestamp': _dateTimeToJson(instance.timestamp),
      'description': instance.description,
    };

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  productId: (json['product_id'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  priceAtPurchase: (json['price_at_purchase'] as num).toDouble(),
  product: Product.fromJson(json['product'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'product_id': instance.productId,
  'quantity': instance.quantity,
  'price_at_purchase': instance.priceAtPurchase,
  'product': instance.product.toJson(),
};

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  orderId: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  status: _orderStatusFromJson(json['status'] as String?),
  paymentStatus: _paymentStatusFromJson(json['payment_status'] as String?),
  totalAmount: (json['total_amount'] as num).toDouble(),
  shippingAddress: json['shipping_address'] as Map<String, dynamic>,
  shippingMethod: json['shipping_method'] as Map<String, dynamic>,
  createdAt: _dateTimeFromJson(json['created_at'] as String),
  items:
      (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
  statusHistory:
      (json['status_history'] as List<dynamic>?)
          ?.map((e) => OrderStatusUpdate.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.orderId,
  'user_id': instance.userId,
  'status': _orderStatusToJson(instance.status),
  'payment_status': _paymentStatusToJson(instance.paymentStatus),
  'total_amount': instance.totalAmount,
  'shipping_address': instance.shippingAddress,
  'shipping_method': instance.shippingMethod,
  'created_at': _dateTimeToJson(instance.createdAt),
  'items': instance.items.map((e) => e.toJson()).toList(),
  'status_history': instance.statusHistory?.map((e) => e.toJson()).toList(),
};
