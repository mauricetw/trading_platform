// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  orderId: json['orderId'] as String,
  productName: json['productName'] as String,
  totalPrice: (json['totalPrice'] as num).toDouble(),
  orderDate: _dateTimeFlexibleFromJson(json['orderDate']),
  currentStatus: _orderStatusFromJson(json['currentStatus'] as String?),
  statusHistory:
      (json['statusHistory'] as List<dynamic>?)
          ?.map((e) => OrderStatusUpdate.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'productName': instance.productName,
      'totalPrice': instance.totalPrice,
      'orderDate': _dateTimeToTimestamp(instance.orderDate),
      'currentStatus': _orderStatusToJson(instance.currentStatus),
      'statusHistory': instance.statusHistory.map((e) => e.toJson()).toList(),
    };

OrderStatusUpdate _$OrderStatusUpdateFromJson(Map<String, dynamic> json) =>
    OrderStatusUpdate(
      status: _orderStatusFromJson(json['status'] as String?),
      timestamp: _dateTimeFlexibleFromJson(json['timestamp']),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$OrderStatusUpdateToJson(OrderStatusUpdate instance) =>
    <String, dynamic>{
      'status': _orderStatusToJson(instance.status),
      'timestamp': _dateTimeToTimestamp(instance.timestamp),
      'description': instance.description,
    };
