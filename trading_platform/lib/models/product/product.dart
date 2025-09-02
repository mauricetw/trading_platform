// --- FILE: lib/models/product/product.dart ---
import 'package:json_annotation/json_annotation.dart';
import '../order/shipping_info.dart';

part 'product.g.dart';

/// ===============
/// SellerInfo
/// ===============
@JsonSerializable(fieldRename: FieldRename.snake)
class SellerInfo {
  final int id;

  /// 後端若用 nickname，可用 JsonKey 對應到 username
  @JsonKey(name: 'nickname')
  final String username;

  final String? avatarUrl;

  SellerInfo({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) =>
      _$SellerInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SellerInfoToJson(this);
}

/// ===============
/// Product
/// ===============
///
/// - `description` 改為非空字串，UI 端不用再 `?? ''`
/// - `fromJson` 做兼容：
///   - category 可能是物件或分離欄位
///   - images 可能是字串陣列或物件陣列（image_url/url）
/// - `category` 僅供前端顯示（不輸出到後端）
@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  createFactory: false, // 我們自訂 fromJson
)
class Product {
  final int id;
  final String name;

  /// 非空字串（給預設空字串）
  final String description;

  final double price;
  final double? originalPrice;

  final int categoryId;

  /// 只給前端顯示用；不輸出到後端
  @JsonKey(includeToJson: false)
  final String category;

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

  final ShippingInformation? shippingInfo;

  /// 前端狀態，不參與序列化
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isFavorite;

  /// 便利屬性
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

  /// 自訂 fromJson：兼容多種後端輸出形態
  factory Product.fromJson(Map<String, dynamic> json) {
    // 1) category 相容處理
    int resolvedCategoryId = 0;
    String resolvedCategoryName = '未分類';
    final categoryData = json['category'];

    if (categoryData is Map<String, dynamic>) {
      resolvedCategoryId = categoryData['id'] as int? ?? 0;
      resolvedCategoryName = categoryData['name'] as String? ?? '未分類';
    } else {
      // 後端可能直接給欄位
      resolvedCategoryId = (json['category_id'] as int?) ?? 0;
      resolvedCategoryName = (json['category_name'] as String?) ??
          (json['category'] as String?) ??
          '未分類';
    }

    // 2) images 相容處理：可能是 ["url", ...] 或 [{"image_url": "..."}] 或 {"url": "..."}
    final rawImages = (json['images'] as List?) ?? const [];
    final resolvedImageUrls = rawImages
        .map((e) {
      if (e is String) return e;
      if (e is Map<String, dynamic>) {
        return (e['image_url'] as String?) ??
            (e['url'] as String?) ??
            '';
      }
      return '';
    })
        .where((s) => s.isNotEmpty)
        .toList();

    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      categoryId: resolvedCategoryId,
      category: resolvedCategoryName,
      imageUrls: resolvedImageUrls,
      stockQuantity: json['stock_quantity'] as int,
      status: json['status'] as String,
      salesCount: (json['sales_count'] as int?) ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      reviewCount: (json['review_count'] as int?) ?? 0,
      tags: (json['tags'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sellerId: json['seller_id'] as int,
      seller: (json['seller'] is Map<String, dynamic>)
          ? SellerInfo.fromJson(json['seller'] as Map<String, dynamic>)
          : null,
      shippingInfo: (json['shipping_info'] is Map<String, dynamic>)
          ? ShippingInformation.fromJson(
        json['shipping_info'] as Map<String, dynamic>,
      )
          : null,
      isFavorite: (json['is_favorite'] as bool?) ?? false,
    );
  }

  /// toJson 仍交給 json_serializable 產生
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
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
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
