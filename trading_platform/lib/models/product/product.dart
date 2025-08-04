import 'package:json_annotation/json_annotation.dart';
import '../user/user.dart';
import '../order/shipping_info.dart';

part 'product.g.dart'; // 需要這一行來鏈接生成的代碼

@JsonSerializable(explicitToJson: true) // explicitToJson: true 以便嵌套對象調用 toJson
class Product {
  final String id; // 唯一識別碼
  final String name;
  final String description;
  final double? originalPrice; // Made nullable as it might not always exist
  final double price;         // Added 'price' as this is what HomePage's _formatPrice expects
  final int categoryId;
  final int stockQuantity;
  final List<String> imageUrls; // 非空列表
  final String category; // This can be derived from categoryId or stored directly
  final String status; // 例如："available", "unavailable", "sold"
  final DateTime createdAt;
  final DateTime updatedAt;

  @JsonKey(defaultValue: 0)
  final int salesCount;
  final double? averageRating;
  final int? reviewCount;
  final List<String>? tags; // 可空列表
  final ShippingInformation? shippingInfo; // 可空嵌套對象
  final User? seller; // 可空嵌套對象

  @JsonKey(defaultValue: false)
  final bool isSold;     // Used by _buildProductCard to show "SOLD" tag

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.categoryId,
    required this.stockQuantity,
    required this.imageUrls,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.salesCount = 0, // 構造函數中的默認值
    this.averageRating,
    this.reviewCount,
    this.tags,
    this.shippingInfo,
    this.seller,
    this.isSold = false,     // 構造函數中的默認值
  });

  // --- 手動實現部分 (可以保留你已有的 copyWith) ---
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    int? categoryId,
    int? stockQuantity,
    List<String>? imageUrls,
    String? category,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? salesCount,
    double? averageRating,
    int? reviewCount,
    List<String>? tags,
    ShippingInformation? shippingInfo,
    User? seller,
    bool? isFavorite,
    bool? isSold,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      categoryId: categoryId ?? this.categoryId,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      salesCount: salesCount ?? this.salesCount,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      tags: tags ?? this.tags,
      shippingInfo: shippingInfo ?? this.shippingInfo,
      seller: seller ?? this.seller,
      isSold: isSold ?? this.isSold,
    );
  }

  // --- 手動實現 operator == 和 hashCode ---
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    // final listEquals = const DeepCollectionEquality().equals; // 需要 collection 包

    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.originalPrice == originalPrice &&
        other.price == price &&
        other.categoryId == categoryId &&
        other.stockQuantity == stockQuantity &&
        // listEquals(other.imageUrls, imageUrls) && // imageUrls 是非空的
        _listEquals(other.imageUrls, imageUrls) && // imageUrls 是非空的
        other.category == category &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.salesCount == salesCount &&
        other.averageRating == averageRating &&
        other.reviewCount == reviewCount &&
        // listEquals(other.tags, tags) && // tags 是可空的
        _listEquals(other.tags, tags) && // tags 是可空的
        other.shippingInfo == shippingInfo && // 假設 ShippingInformation 也實現了 ==
        other.seller == seller &&             // 假設 User 也實現了 ==
        other.isSold == isSold;
  }

  // 輔助函數比較列表 (如果不想引入 collection 包)
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null; // 如果 a 是 null，只有當 b 也是 null 時才相等
    if (b == null || a.length != b.length) return false;
    if (a.isEmpty && b.isEmpty) return true; // 兩個空列表相等
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  @override
  int get hashCode {
    final int originalPriceHash = originalPrice?.hashCode ?? 0;
    final int averageRatingHash = averageRating?.hashCode ?? 0;
    final int reviewCountHash = reviewCount?.hashCode ?? 0;

    int imageUrlsCombinedHash = 17;
    // imageUrls is List<String> (non-nullable list, but could be empty)
    for (final imageUrl in imageUrls) {
      imageUrlsCombinedHash = imageUrlsCombinedHash * 31 + imageUrl.hashCode;
    }
    // If imageUrls can be empty, imageUrlsCombinedHash will remain 17.
    // If you want empty list to have hash 0, you can add:
    // if (imageUrls.isEmpty) imageUrlsCombinedHash = 0;


    int tagsCombinedHash = 17;
    if (tags != null) {
      for (final tag in tags!) { // tags! is safe here
        tagsCombinedHash = tagsCombinedHash * 31 + tag.hashCode;
      }
    } else {
      tagsCombinedHash = 0;
    }

    final int shippingInfoHash = shippingInfo?.hashCode ?? 0;
    final int sellerHash = seller?.hashCode ?? 0;

    return id.hashCode ^
    name.hashCode ^
    description.hashCode ^
    originalPriceHash ^
    price.hashCode ^
    categoryId.hashCode ^
    stockQuantity.hashCode ^
    imageUrlsCombinedHash ^ // 使用組合後的哈希
    category.hashCode ^
    status.hashCode ^
    createdAt.hashCode ^
    updatedAt.hashCode ^
    salesCount.hashCode ^
    averageRatingHash ^
    reviewCountHash ^
    tagsCombinedHash ^ // 使用組合後的哈希
    shippingInfoHash ^
    sellerHash ^
    isSold.hashCode;
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, category: $category, stockQuantity: $stockQuantity)';
    // 自定義 toString 以便調試
  }

  // --- 由 json_serializable 生成 ---
  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}