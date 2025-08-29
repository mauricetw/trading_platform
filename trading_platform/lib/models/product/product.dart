// --- FILE: lib/models/product/product.dart (最終修正版) ---
import 'package:json_annotation/json_annotation.dart';
import '../order/shipping_info.dart'; // 1. 保留 shipping_info 的引用

part 'product.g.dart';

// --- SellerInfo 模型 (維持不變) ---
@JsonSerializable(fieldRename: FieldRename.snake)
class SellerInfo {
  final int id;
  @JsonKey(name: 'nickname')
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


// --- Product 模型 ---
@JsonSerializable(
    fieldRename: FieldRename.snake,
    explicitToJson: true,
    createFactory: false // 我們將手動處理 fromJson
)
class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? originalPrice;

  final int categoryId;

  @JsonKey(includeToJson: false) // 在 toJson 時忽略此欄位，避免衝突
  final String categoryName;

  final List<String> imageUrls;

  final int stockQuantity;
  final String status;
  final int salesCount;
  final double? averageRating;
  final int reviewCount;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sellerId;
  final SellerInfo? seller;

  // 2. 保留 shippingInfo 欄位
  final ShippingInformation? shippingInfo;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isFavorite;

  bool get isSold => stockQuantity == 0 || status == 'sold';

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.originalPrice,
    required this.categoryId,
    required this.categoryName,
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
    this.shippingInfo, // 3. 在建構函式中加入
    this.isFavorite = false,
  });

  // 手動處理 fromJson 以解決 category 和 images 的結構不匹配問題
  factory Product.fromJson(Map<String, dynamic> json) {
    final categoryData = json['category'] as Map<String, dynamic>? ?? {};
    final imagesData = json['images'] as List<dynamic>? ?? [];

    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['original_price'] as num?)?.toDouble(),

      categoryId: categoryData['id'] as int? ?? 0,
      categoryName: categoryData['name'] as String? ?? '未分類',
      imageUrls: imagesData
          .map((img) => (img as Map<String, dynamic>)['image_url'] as String)
          .toList(),

      stockQuantity: json['stock_quantity'] as int,
      status: json['status'] as String,
      salesCount: json['sales_count'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sellerId: json['seller_id'] as int,
      seller: json['seller'] == null
          ? null
          : SellerInfo.fromJson(json['seller'] as Map<String, dynamic>),

      // 4. 在 fromJson 中處理 shippingInfo
      shippingInfo: json['shipping_info'] == null
          ? null
          : ShippingInformation.fromJson(json['shipping_info'] as Map<String, dynamic>),

      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  // toJson 方法由產生器自動處理
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  // copyWith 方法
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    int? categoryId,
    String? categoryName,
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
    ShippingInformation? shippingInfo, // 5. 在 copyWith 中加入
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
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

