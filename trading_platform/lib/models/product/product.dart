// --- FILE: lib/models/product/product.dart ---

import 'package:json_annotation/json_annotation.dart';
import '../order/shipping_info.dart';

part 'product.g.dart';

// --- Helper Functions (放在 Product class 外部) ---
// 這個函式會將後端回傳的 Category 物件轉換為前端需要的 String (分類名稱)
String _categoryNameFromObject(Map<String, dynamic> category) {
  return category['name'] as String;
}

// 這個函式會將後端回傳的 Category 物件轉換為前端需要的 int (分類 ID)
int _categoryIdFromObject(Map<String, dynamic> category) {
  return category['id'] as int;
}

// 這個函式會將後端回傳的 images 物件列表，轉換為前端需要的 String 列表
List<String> _imageUrlsFromImagesList(List<dynamic> images) {
  if (images is! List) return [];
  return images
      .map((image) => image['image_url'] as String)
      .toList();
}


// --- SellerInfo 模型 (維持不變) ---
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

  factory SellerInfo.fromJson(Map<String, dynamic> json) => _$SellerInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SellerInfoToJson(this);
}


// --- Product 模型 (已修正) ---
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;

  // --- 關鍵修改：使用 @JsonKey 進行自定義解析 ---
  @JsonKey(name: 'category', fromJson: _categoryIdFromObject)
  final int categoryId;

  @JsonKey(name: 'category', fromJson: _categoryNameFromObject)
  final String category;

  final int stockQuantity;
  final String status;

  // --- 關鍵修改：使用 @JsonKey 進行自定義解析 ---
  @JsonKey(name: 'images', fromJson: _imageUrlsFromImagesList)
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isFavorite;

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

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

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
