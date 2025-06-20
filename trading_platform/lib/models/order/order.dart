import 'package:flutter/material.dart'; // For IconData, not directly used by json_serializable
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // If DateTime needs to be Timestamp

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


// --- DateTime Helpers (similar to what we used in Message/ChatRoom) ---
// Flexible DateTime deserializer (handles Timestamp or ISO String)
DateTime _dateTimeFlexibleFromJson(dynamic jsonValue) {
  if (jsonValue is Timestamp) {
    return jsonValue.toDate();
  }
  if (jsonValue is String) {
    return DateTime.tryParse(jsonValue) ?? DateTime.now(); // Fallback to now if parse fails
  }
  return DateTime.now(); // Fallback for other unexpected types
}

Timestamp _dateTimeToTimestamp(DateTime dateTime) {
  return Timestamp.fromDate(dateTime);
}
// String _dateTimeToIsoString(DateTime dateTime) => dateTime.toIso8601String();
// --- End DateTime Helpers ---


@JsonSerializable(explicitToJson: true) // explicitToJson because of List<OrderStatusUpdate>
class OrderModel {
  @JsonKey(includeFromJson: false, includeToJson: false) // Assuming orderId comes from Firestore doc ID
  final String? id; // Made nullable for fromJson, will be set by fromFirestore

  final String orderId; // This seems like it could be the same as 'id' from Firestore.
  // If so, consider removing this and just using 'id'.
  // If it's different, ensure it's populated from JSON or constructor.
  // For now, assuming it's required from JSON if not the doc ID.

  final String productName;
  final double totalPrice;

  @JsonKey(
      fromJson: _dateTimeFlexibleFromJson,
      toJson: _dateTimeToTimestamp // Or _dateTimeToIsoString
  )
  final DateTime orderDate;

  @JsonKey(
      fromJson: _orderStatusFromJson,
      toJson: _orderStatusToJson
  )
  OrderStatus currentStatus; // Made non-final as it was in original code

  final List<OrderStatusUpdate> statusHistory;

  OrderModel({
    this.id, // For fromFirestore
    required this.orderId,
    required this.productName,
    required this.totalPrice,
    required this.orderDate,
    required this.currentStatus,
    this.statusHistory = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Missing data for OrderModel ${snapshot.id}');
    }
    final order = _$OrderModelFromJson(data);
    // If orderId field is meant to be the Firestore document ID:
    // return order.copyWith(id: snapshot.id, orderId: snapshot.id);
    // If orderId is a separate field within the document data, and 'id' is for the model's own ID:
    return order.copyWith(id: snapshot.id);
  }

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  // Consider adding copyWith if you need to update instances, especially if fields are final
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
      fromJson: _dateTimeFlexibleFromJson,
      toJson: _dateTimeToTimestamp // Or _dateTimeToIsoString
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

  // Optional: copyWith for OrderStatusUpdate
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
  // ... (rest of your cases) ...
    default:
      return '未知狀態';
  }
}

// 輔助函數，為每個狀態獲取一個圖標 (示例) (for UI)
IconData getOrderStatusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.established:
      return Icons.receipt_long_outlined;
  // ... (rest of your cases) ...
    default:
      return Icons.help_outline;
  }
}