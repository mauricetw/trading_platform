import 'package:flutter/material.dart'; // For IconData, not directly used by json_serializable
import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

// --- OrderStatus Enum and Helpers for JSON serialization ---
enum OrderStatus {
  established,
  paid,
  preparing,
  delivering,
  completed,
  cancelled,
  refunded,
}

// Helper for json_serializable to convert OrderStatus to String
String _orderStatusToJson(OrderStatus status) => status.toString().split('.').last;

// Helper for json_serializable to convert String to OrderStatus
OrderStatus _orderStatusFromJson(String? statusString) {
  if (statusString == null) {
    // Decide a default or throw an error if status is mandatory
    return OrderStatus.established; // Or throw ArgumentError('Status cannot be null');
  }
  return OrderStatus.values.firstWhere(
          (e) => e.toString().split('.').last == statusString,
      orElse: () {
        // Handle unknown status string, e.g., default to established or throw error
        print('Warning: Unknown OrderStatus string "$statusString", defaulting to established.');
        return OrderStatus.established;
        // Or: throw ArgumentError('Unknown OrderStatus string: $statusString');
      }
  );
}

// --- End OrderStatus Helpers ---


// --- DateTime Helpers for standard JSON (ISO 8601 String) ---
DateTime _dateTimeFromJson(String isoString) {
  return DateTime.parse(isoString);
}

String _dateTimeToJson(DateTime dateTime) {
  return dateTime.toIso8601String();
}
// --- End DateTime Helpers ---


@JsonSerializable(explicitToJson: true) // explicitToJson because of List<OrderStatusUpdate>
class OrderModel {
  // If your HTTP API provides an 'id', use it. Otherwise, you might not need it
  // or it might be assigned by the client.
  final String? id; // This can come from your JSON payload if available

  final String orderId; // Assuming this is a key field from your API's JSON response

  final String productName;
  final double totalPrice;

  @JsonKey(
      fromJson: _dateTimeFromJson,
      toJson: _dateTimeToJson
  )
  final DateTime orderDate;

  @JsonKey(
      fromJson: _orderStatusFromJson,
      toJson: _orderStatusToJson
  )
  OrderStatus currentStatus;

  final List<OrderStatusUpdate> statusHistory;

  OrderModel({
    this.id,
    required this.orderId,
    required this.productName,
    required this.totalPrice,
    required this.orderDate,
    required this.currentStatus,
    this.statusHistory = const [],
  });

  // Factory constructor for creating a new OrderModel instance from a map.
  // This is used by json_serializable.
  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  // Method for converting an OrderModel instance to a map.
  // This is used by json_serializable.
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  // copyWith method remains useful for immutability and updates
  OrderModel copyWith({
    String? id,
    String? orderId,
    String? productName,
    double? totalPrice,
    DateTime? orderDate,
    OrderStatus? currentStatus,
    List<OrderStatusUpdate>? statusHistory,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productName: productName ?? this.productName,
      totalPrice: totalPrice ?? this.totalPrice,
      orderDate: orderDate ?? this.orderDate,
      currentStatus: currentStatus ?? this.currentStatus,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}

@JsonSerializable()
class OrderStatusUpdate {
  @JsonKey(
      fromJson: _orderStatusFromJson,
      toJson: _orderStatusToJson
  )
  final OrderStatus status;

  @JsonKey(
      fromJson: _dateTimeFromJson,
      toJson: _dateTimeToJson
  )
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

  OrderStatusUpdate copyWith({
    OrderStatus? status,
    DateTime? timestamp,
    String? description,
  }) {
    return OrderStatusUpdate(
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
    );
  }
}


// --- UI Helper Functions (Keep them if you use them for display purposes) ---
// These are not used for JSON serialization with the above setup.

// 輔助函數，將枚舉轉換為用戶可讀的字符串 (for UI)
String orderStatusToDisplayString(OrderStatus status) {
  switch (status) {
    case OrderStatus.established:
      return '訂單已建立';
    case OrderStatus.paid:
      return '已付款';
    case OrderStatus.preparing:
      return '準備中';
    case OrderStatus.delivering:
      return '運送中';
    case OrderStatus.completed:
      return '已完成';
    case OrderStatus.cancelled:
      return '已取消';
    case OrderStatus.refunded:
      return '已退款';
    default:
      return '未知狀態';
  }
}

// 輔助函數，為每個狀態獲取一個圖標 (示例) (for UI)
IconData getOrderStatusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.established:
      return Icons.receipt_long_outlined;
    case OrderStatus.paid:
      return Icons.payment_outlined;
    case OrderStatus.preparing:
      return Icons.inventory_2_outlined;
    case OrderStatus.delivering:
      return Icons.local_shipping_outlined;
    case OrderStatus.completed:
      return Icons.check_circle_outline;
    case OrderStatus.cancelled:
      return Icons.cancel_outlined;
    case OrderStatus.refunded:
      return Icons.settings_backup_restore_outlined;
    default:
      return Icons.help_outline;
  }
}
