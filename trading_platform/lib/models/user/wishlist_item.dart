// --- FILE: lib/models/user/wishlist_item.dart ---
import 'package:json_annotation/json_annotation.dart';
import '../product/product.dart';

part 'wishlist_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class WishlistItem {
  // --- 類型修正：使用與後端一致的 int 類型 ---
  final int id;
  final int userId;
  final int productId;
  final DateTime createdAt;

  // 為了方便在收藏頁面直接顯示，API 通常會一併回傳商品資訊
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

  // --- 整合有用的輔助方法 ---
  WishlistItem copyWith({
    int? id,
    int? userId,
    int? productId,
    DateTime? createdAt,
    Product? product,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      createdAt: createdAt ?? this.createdAt,
      product: product ?? this.product,
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
        other.product == product; // 假設 Product 也實現了 ==
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
    return 'WishlistItem(id: $id, userId: $userId, productId: $productId, product: ${product.name})';
  }
}
