// lib/models/user/cart_item.dart
import 'package:json_annotation/json_annotation.dart';
import '../product/product.dart';

part 'cart_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true, createFactory: false)
class CartItem {
  // --- 與後端 CartItemResponse 完全匹配的欄位 ---
  final int? id; // 改為可空，因為新建立的項目可能沒有 id
  final int userId;
  final int productId;
  final int quantity;
  final DateTime addedAt;
  // API 回應會嵌入完整的商品資訊
  final Product product;

  // --- 純粹的前端 UI 狀態 ---
  // 用於標記此商品是否被選中去結帳
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isSelected;

  CartItem({
    this.id, // 改為可選參數
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.addedAt,
    required this.product,
    this.isSelected = false, // 默認不選中
  });

  // 自定義的 fromJson 方法，增加錯誤處理
  factory CartItem.fromJson(Map<String, dynamic> json) {
    try {
      // 先檢查必要欄位是否存在
      if (json['product_id'] == null) {
        throw Exception('CartItem.fromJson: product_id is required');
      }
      if (json['quantity'] == null) {
        throw Exception('CartItem.fromJson: quantity is required');
      }
      if (json['user_id'] == null) {
        throw Exception('CartItem.fromJson: user_id is required');
      }
      if (json['product'] == null) {
        throw Exception('CartItem.fromJson: product is required');
      }

      // 安全的數值轉換函數
      int safeInt(dynamic value, int defaultValue) {
        if (value == null) return defaultValue;
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? defaultValue;
        return defaultValue;
      }

      return CartItem(
        id: json['id'] != null ? safeInt(json['id'], 0) : null,
        userId: safeInt(json['user_id'], 0),
        productId: safeInt(json['product_id'], 0),
        quantity: safeInt(json['quantity'], 1),
        addedAt: json['added_at'] != null
            ? DateTime.parse(json['added_at'] as String)
            : DateTime.now(),
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
        isSelected: false,
      );
    } catch (e) {
      print('CartItem.fromJson error: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'added_at': addedAt.toIso8601String(),
      'product': product.toJson(),
    };
  }

  CartItem copyWith({
    int? id,
    int? userId,
    int? productId,
    int? quantity,
    DateTime? addedAt,
    Product? product,
    bool? isSelected,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
      product: product ?? this.product,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}