// --- FILE: lib/models/product/product.dart ---

import 'package:json_annotation/json_annotation.dart';
import '../order/shipping_info.dart';

// 這行會將此檔案與下面第三步將自動產生的檔案連結起來。
part 'product.g.dart';

// --- SellerInfo 模型 ---
// 我們保留這個獨立、輕量的 SellerInfo 模型，用於商品列表中的賣家資訊。
// 它也使用 json_serializable 以保持一致性。
@JsonSerializable(fieldRename: FieldRename.snake)
class SellerInfo {
  final int id;
  final String username;
  final String? avatarUrl;

  SellerInfo({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  // fromJson 和 toJson 將由程式碼產生器自動建立。
  factory SellerInfo.fromJson(Map<String, dynamic> json) => _$SellerInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SellerInfoToJson(this);
}


// --- Product 模型 ---
// @JsonSerializable 告訴產生器要為這個類別建立程式碼。
// fieldRename: FieldRename.snake 會自動將 Dart 的駝峰式命名 (例如 originalPrice)
// 轉換為 JSON 的蛇形命名 (例如 original_price)，與我們的後端完全匹配。
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Product {
  // --- 欄位與你的版本 (以及後端) 完全對齊 ---
  final int id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int categoryId;
  final String category;
  final int stockQuantity;
  final String status;
  final List<String> imageUrls;
  final int salesCount;
  final double? averageRating;
  final int reviewCount;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sellerId;
  final SellerInfo? seller;
  final ShippingInformation? shippingInfo;

  // --- 前端邏輯欄位 ---
  // 這些欄位不是來自 JSON，所以我們告訴產生器在序列化時忽略它們。
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isFavorite;

  // isSold 是一個 getter，產生器會自動忽略它。
  bool get isSold => stockQuantity == 0 || status == 'sold';

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.categoryId,
    required this.category,
    required this.stockQuantity,
    required this.imageUrls,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.salesCount,
    this.averageRating,
    required this.reviewCount,
    this.tags,
    required this.sellerId,
    this.seller,
    this.shippingInfo,
    this.isFavorite = false,
  });

  // --- 由程式碼產生器實現的方法 ---
  // fromJson 和 toJson 方法現在會在 product.g.dart 中自動產生
  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  // 你的 copyWith 方法對於狀態管理仍然非常有用，所以我們保留它。
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    int? categoryId,
    String? category,
    int? stockQuantity,
    String? status,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? salesCount,
    double? averageRating,
    int? reviewCount,
    List<String>? tags,
    int? sellerId,
    SellerInfo? seller,
    ShippingInformation? shippingInfo,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      status: status ?? this.status,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      salesCount: salesCount ?? this.salesCount,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      tags: tags ?? this.tags,
      sellerId: sellerId ?? this.sellerId,
      seller: seller ?? this.seller,
      shippingInfo: shippingInfo ?? this.shippingInfo,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
