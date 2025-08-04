// lib/models/user/wishlist_item.dart (或者您的路徑)
import 'package:json_annotation/json_annotation.dart';
import '../product/product.dart'; // <--- 確保導入 Product 模型

part 'wishlist_item.g.dart';

@JsonSerializable(explicitToJson: true) // explicitToJson 很重要，如果 Product 也用 json_serializable
class WishlistItem {
  final String id;
  final String userId;
  final String productId;
  final DateTime createdAt;
  final Product product;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.createdAt,
    required this.product,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) => _$WishlistItemFromJson(json);
  Map<String, dynamic> toJson() => _$WishlistItemToJson(this);

  // --- 更新 copyWith, ==, hashCode 以包含 product ---
  WishlistItem copyWith({
    String? id,
    String? userId,
    String? productId,
    DateTime? createdAt,
    Product? product, // <--- 新增
  }) {
    return WishlistItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      createdAt: createdAt ?? this.createdAt,
      product: product ?? this.product, // <--- 新增
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WishlistItem &&
        other.id == id &&
        other.userId == userId &&
        other.productId == productId &&
        other.createdAt == createdAt &&
        other.product == product;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    userId.hashCode ^
    productId.hashCode ^
    createdAt.hashCode ^
    product.hashCode;
  }

  @override
  String toString() {
    return 'WishlistItem(id: $id, userId: $userId, productId: $productId, createdAt: $createdAt, product: ${product.name})'; // 示例 toString
  }
}
