import 'package:json_annotation/json_annotation.dart';
// 如果你決定將來嵌入 Product 的部分信息，或者需要引用 Product 類型
// import '../product/product.dart';

part 'wishlist_item.g.dart';

@JsonSerializable() // 假設沒有嵌套其他需要 explicitToJson 的自定義類
class WishlistItem {
  final String id;        // 收藏項目的唯一 ID (例如，由後端數據庫生成)
  final String userId;    // 收藏該商品的用戶 ID
  final String productId; // 被收藏的商品 ID
  final DateTime createdAt; // 添加到願望清單的時間

  // 可選: 如果你決定嵌入部分商品信息作為快照
  // final String? productNameSnapshot;
  // final String? productImageUrlSnapshot;
  // final double? productPriceSnapshot;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.createdAt,
    // this.productNameSnapshot,
    // this.productImageUrlSnapshot,
    // this.productPriceSnapshot,
  });

  // --- 手動實現 copyWith, ==, hashCode ---

  WishlistItem copyWith({
    String? id,
    String? userId,
    String? productId,
    DateTime? createdAt,
    // String? productNameSnapshot,
    // String? productImageUrlSnapshot,
    // double? productPriceSnapshot,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      createdAt: createdAt ?? this.createdAt,
      // productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
      // productImageUrlSnapshot: productImageUrlSnapshot ?? this.productImageUrlSnapshot,
      // productPriceSnapshot: productPriceSnapshot ?? this.productPriceSnapshot,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WishlistItem &&
        other.id == id &&
        other.userId == userId &&
        other.productId == productId &&
        other.createdAt == createdAt;
    // && other.productNameSnapshot == productNameSnapshot
    // && other.productImageUrlSnapshot == productImageUrlSnapshot
    // && other.productPriceSnapshot == productPriceSnapshot;
  }

  @override
  int get hashCode {
    // final int productNameSnapshotHash = productNameSnapshot?.hashCode ?? 0;
    // final int productImageUrlSnapshotHash = productImageUrlSnapshot?.hashCode ?? 0;
    // final int productPriceSnapshotHash = productPriceSnapshot?.hashCode ?? 0;

    return id.hashCode ^
    userId.hashCode ^
    productId.hashCode ^
    createdAt.hashCode;
    // ^ productNameSnapshotHash
    // ^ productImageUrlSnapshotHash
    // ^ productPriceSnapshotHash;
  }

  @override
  String toString() {
    return 'WishlistItem(id: $id, userId: $userId, productId: $productId, createdAt: $createdAt)';
  }

  // --- 由 json_serializable 生成 ---
  factory WishlistItem.fromJson(Map<String, dynamic> json) => _$WishlistItemFromJson(json);
  Map<String, dynamic> toJson() => _$WishlistItemToJson(this);
}