// --- FILE: lib/models/user/cart_item.dart ---
import 'package:json_annotation/json_annotation.dart';
import '../product/product.dart';

part 'cart_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CartItem {
  // --- 與後端 CartItemResponse 完全匹配的欄位 ---
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final DateTime addedAt;
  // API 回應會嵌入完整的商品資訊
  final Product product;

  // --- 純粹的前端 UI 狀態 ---
  // 用於標記此商品是否被選中去結帳
  // @JsonKey 告訴 json_serializable 在序列化/反序列化時忽略此欄位
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isSelected;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.addedAt,
    required this.product,
    this.isSelected = false, // 默認不選中
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);

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
