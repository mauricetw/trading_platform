// --- FILE: lib/models/user/wishlist_item.dart ---
import 'package:json_annotation/json_annotation.dart';
// 為了在收藏清單中顯示商品資訊，我們需要嵌入 Product 模型
import '../product/product.dart';

part 'wishlist_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class WishlistItem {
  // --- 類型修正：後端 ID 應為整數 ---
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
}
