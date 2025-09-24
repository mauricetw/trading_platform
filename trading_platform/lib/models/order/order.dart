// --- FILE: lib/models/order/order.dart ---
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../product/product.dart'; // 引入 Product 模型

part 'order.g.dart';

// --- OrderStatus Enum 和 Helpers (保留組員的優秀設計) ---
enum OrderStatus {
  established, // 訂單成立
  paid,        // 已付款
  preparing,   // 準備中
  delivering,  // 運送中
  completed,   // 已完成
  cancelled,   // 已取消
  refunded,    // 已退款
}

String _orderStatusToJson(OrderStatus status) => status.name;
OrderStatus _orderStatusFromJson(String? statusString) {
  return OrderStatus.values.firstWhere(
        (e) => e.name == statusString,
    orElse: () => OrderStatus.established,
  );
}

// --- DateTime Helpers (保留組員的設計) ---
DateTime _dateTimeFromJson(String isoString) => DateTime.parse(isoString);
String _dateTimeToJson(DateTime dateTime) => dateTime.toIso8601String();

// --- OrderStatusUpdate 模型 (保留組員的設計) ---
// 用於追蹤訂單的歷史狀態變化
@JsonSerializable(fieldRename: FieldRename.snake)
class OrderStatusUpdate {
  @JsonKey(fromJson: _orderStatusFromJson, toJson: _orderStatusToJson)
  final OrderStatus status;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime timestamp;
  final String? description;

  OrderStatusUpdate({
    required this.status,
    required this.timestamp,
    this.description,
  });

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$OrderStatusUpdateToJson(this);
}

// --- OrderItem 模型 (新建) ---
// 代表一個訂單中的單一商品項目
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class OrderItem {
  final int productId;
  final int quantity;
  final double priceAtPurchase;
  final Product product; // 巢狀嵌入完整的 Product 物件

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.priceAtPurchase,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

// --- Order 模型 (重構) ---
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Order {
  @JsonKey(name: 'id')
  final int orderId;
  final int userId;

  @JsonKey(fromJson: _orderStatusFromJson, toJson: _orderStatusToJson)
  final OrderStatus status;

  final double totalAmount;
  final Map<String, dynamic> shippingAddress;
  final Map<String, dynamic> shippingMethod;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;

  final List<OrderItem> items;

  // 保留 statusHistory，供未來訂單進度追蹤功能使用
  final List<OrderStatusUpdate>? statusHistory;

  Order({
    required this.orderId,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.shippingAddress,
    required this.shippingMethod,
    required this.createdAt,
    required this.items,
    this.statusHistory,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

// --- UI Helper Functions (保留組員的設計) ---
String orderStatusToDisplayString(OrderStatus status) {
  switch (status) {
    case OrderStatus.established: return '訂單已建立';
    case OrderStatus.paid: return '已付款';
    case OrderStatus.preparing: return '準備中';
    case OrderStatus.delivering: return '運送中';
    case OrderStatus.completed: return '已完成';
    case OrderStatus.cancelled: return '已取消';
    case OrderStatus.refunded: return '已退款';
    default: return '未知狀態';
  }
}

IconData getOrderStatusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.established: return Icons.receipt_long_outlined;
    case OrderStatus.paid: return Icons.payment_outlined;
    case OrderStatus.preparing: return Icons.inventory_2_outlined;
    case OrderStatus.delivering: return Icons.local_shipping_outlined;
    case OrderStatus.completed: return Icons.check_circle_outline;
    case OrderStatus.cancelled: return Icons.cancel_outlined;
    case OrderStatus.refunded: return Icons.settings_backup_restore_outlined;
    default: return Icons.help_outline;
  }
}

