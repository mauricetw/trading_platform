// --- FILE: lib/models/user/wishlist_item.dart ---
import 'package:json_annotation/json_annotation.dart';
import '../product/product.dart';

part 'wishlist_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class WishlistItem {
  final int id;
  final int userId;
  final int productId;
  final DateTime addedAt;

  final Product product;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.addedAt,
    required this.product,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) => _$WishlistItemFromJson(json);
  Map<String, dynamic> toJson() => _$WishlistItemToJson(this);

  // --- 保留組員設計的輔助方法 ---
  WishlistItem copyWith({
    int? id,
    int? userId,
    int? productId,
    DateTime? addedAt,
    Product? product,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      addedAt: addedAt ?? this.addedAt,
      product: product ?? this.product,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WishlistItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WishlistItem(id: $id, userId: $userId, productId: $productId, product: ${product.name})';
  }
}

