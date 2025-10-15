// --- FILE: lib/models/order/order.dart ---
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../product/product.dart';

part 'order.g.dart';

// --- 1. 關鍵修正：使用統一的訂單狀態 Enum ---
enum OrderStatus {
  pending,     // 待確認 (賣家尚未接受)
  preparing,   // 準備中 (賣家已接受，對應 UI 的 "待出貨")
  delivering,  // 運送中
  completed,   // 已完成
  cancelled,   // 已取消 (由買家或賣家在 'preparing' 或 'delivering' 狀態下取消)
  failed,      // 不成立 (由賣家在 'pending' 狀態下拒絕)

  // 為了向前相容，暫時保留，但新流程中應使用 failed
  rejected,

  // 買家流程中的其他狀態
  established,
  paid,
  refunded,
}

// --- 2. 關鍵新增：新增付款狀態 Enum ---
enum PaymentStatus {
  unpaid,      // 未付款 (適用於貨到付款)
  paid,        // 已付款 (適用於線上支付)
}

// --- (JSON 序列化輔助函式保持不變，但現在使用 .name 更安全) ---
String _orderStatusToJson(OrderStatus status) => status.name;
OrderStatus _orderStatusFromJson(String? statusString) {
  return OrderStatus.values.firstWhere(
        (e) => e.name == statusString,
    orElse: () => OrderStatus.pending,
  );
}

String _paymentStatusToJson(PaymentStatus status) => status.name;
PaymentStatus _paymentStatusFromJson(String? statusString) {
  return PaymentStatus.values.firstWhere(
        (e) => e.name == statusString,
    orElse: () => PaymentStatus.unpaid,
  );
}

DateTime _dateTimeFromJson(String isoString) => DateTime.parse(isoString);
String _dateTimeToJson(DateTime dateTime) => dateTime.toIso8601String();


// --- OrderStatusUpdate 模型 (保持不變) ---
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

// --- OrderItem 模型 (保持不變) ---
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class OrderItem {
  final int productId;
  final int quantity;
  final double priceAtPurchase;
  final Product product;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.priceAtPurchase,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

// --- Order 模型 (已更新) ---
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Order {
  @JsonKey(name: 'id')
  final int orderId;
  final int userId;

  @JsonKey(fromJson: _orderStatusFromJson, toJson: _orderStatusToJson)
  final OrderStatus status;

  // --- 3. 關鍵新增：加入 paymentStatus 欄位 ---
  @JsonKey(fromJson: _paymentStatusFromJson, toJson: _paymentStatusToJson)
  final PaymentStatus paymentStatus;

  final double totalAmount;
  final Map<String, dynamic> shippingAddress;
  final Map<String, dynamic> shippingMethod;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;

  final List<OrderItem> items;
  final List<OrderStatusUpdate>? statusHistory;

  Order({
    required this.orderId,
    required this.userId,
    required this.status,
    required this.paymentStatus,
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

// --- UI Helper Functions (已更新) ---
String orderStatusToDisplayString(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending: return '待確認'; // 對應 UI 的 "未接受"
    case OrderStatus.preparing: return '待出貨';
    case OrderStatus.delivering: return '運送中';
    case OrderStatus.completed: return '已完成';
    case OrderStatus.failed: return '不成立';
    case OrderStatus.cancelled: return '已取消';
    default: return '未知狀態';
  }
}

IconData getOrderStatusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending: return Icons.hourglass_top_outlined;
    case OrderStatus.preparing: return Icons.inventory_2_outlined;
    case OrderStatus.delivering: return Icons.local_shipping_outlined;
    case OrderStatus.completed: return Icons.check_circle_outline;
    case OrderStatus.failed: return Icons.error_outline;
    case OrderStatus.cancelled: return Icons.cancel_outlined;
    default: return Icons.help_outline;
  }
}
