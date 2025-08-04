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

  // --- 新增開始 ---
  // 客戶端使用的狀態，標記當前用戶是否收藏了此商品
  // 不參與 JSON 序列化/反序列化，其值由客戶端邏輯管理
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isFavoriteByCurrentUser;
  // --- 新增結束 ---

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
    this.isFavoriteByCurrentUser = false, // --- 新增: 構造函數中的默認值 ---
  });

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
    bool? isSold,
    bool? isFavoriteByCurrentUser, // --- 修改: 之前是 isFavorite，統一為 isFavoriteByCurrentUser ---
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
      isFavoriteByCurrentUser: isFavoriteByCurrentUser ?? this.isFavoriteByCurrentUser, // --- 新增 ---
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.originalPrice == originalPrice &&
        other.price == price &&
        other.categoryId == categoryId &&
        other.stockQuantity == stockQuantity &&
        _listEquals(other.imageUrls, imageUrls) &&
        other.category == category &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.salesCount == salesCount &&
        other.averageRating == averageRating &&
        other.reviewCount == reviewCount &&
        _listEquals(other.tags, tags) &&
        other.shippingInfo == shippingInfo &&
        other.seller == seller &&
        other.isSold == isSold &&
        // --- 新增: 如果您希望 isFavoriteByCurrentUser 也參與對象的相等性比較 ---
        // 通常情況下，ID 相同即可認為是同一個業務實體，
        // isFavoriteByCurrentUser 更多是 UI 狀態。但如果您的業務邏輯需要，可以取消下一行的註釋。
        // other.isFavoriteByCurrentUser == isFavoriteByCurrentUser;
        true; // 保持您原有的比較邏輯，暫不將 isFavoriteByCurrentUser 加入核心比較
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (a.isEmpty && b.isEmpty) return true;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    // 省略了詳細的 hashCode 計算，以保持與您原有邏輯的一致性。
    // 如果 isFavoriteByCurrentUser 加入了 == 的比較，這裡也應該相應地加入。
    // 為了簡潔，我們先不修改您已有的 hashCode。
    // 但請注意，如果 == 比較中加入了 isFavoriteByCurrentUser，hashCode 也必須加入，
    // 以維持 hashCode 和 == 之間的一致性約定。
    // (即 a == b implies a.hashCode == b.hashCode)

    final int originalPriceHash = originalPrice?.hashCode ?? 0;
    final int averageRatingHash = averageRating?.hashCode ?? 0;
    final int reviewCountHash = reviewCount?.hashCode ?? 0;
    int imageUrlsCombinedHash = 17;
    for (final imageUrl in imageUrls) {
      imageUrlsCombinedHash = imageUrlsCombinedHash * 31 + imageUrl.hashCode;
    }
    int tagsCombinedHash = 17;
    if (tags != null) {
      for (final tag in tags!) {
        tagsCombinedHash = tagsCombinedHash * 31 + tag.hashCode;
      }
    } else {
      tagsCombinedHash = 0;
    }
    final int shippingInfoHash = shippingInfo?.hashCode ?? 0;
    final int sellerHash = seller?.hashCode ?? 0;
    // --- 新增: 如果 isFavoriteByCurrentUser 加入了 hashCode 計算 ---
    // final int isFavoriteHash = isFavoriteByCurrentUser.hashCode;

    return id.hashCode ^
    name.hashCode ^
    description.hashCode ^
    originalPriceHash ^
    price.hashCode ^
    categoryId.hashCode ^
    stockQuantity.hashCode ^
    imageUrlsCombinedHash ^
    category.hashCode ^
    status.hashCode ^
    createdAt.hashCode ^
    updatedAt.hashCode ^
    salesCount.hashCode ^
    averageRatingHash ^
    reviewCountHash ^
    tagsCombinedHash ^
    shippingInfoHash ^
    sellerHash ^
    isSold.hashCode;
    // ^ isFavoriteHash; // --- 新增: 如果加入 hashCode 計算 ---
  }

  @override
  String toString() {
    // --- 修改: 加入 isFavoriteByCurrentUser 到 toString 以便調試 ---
    return 'Product(id: $id, name: $name, price: $price, category: $category, stockQuantity: $stockQuantity, isFavorite: $isFavoriteByCurrentUser)';
  }

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

