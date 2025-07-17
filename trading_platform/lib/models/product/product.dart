import '../user/user.dart'; // Assuming User model is in 'user/user.dart' relative to this
import '../order/shipping_info.dart';


class Product {
  // --- 欄位對齊與修正 ---
  final int id; // 修正：id 與後端一致，為 int
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int categoryId;
  final String category;
  final int stockQuantity;
  final String status;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int salesCount;
  final double? averageRating;
  final int reviewCount;
  final List<String>? tags;
  final ShippingInformation? shippingInfo;
  final User? seller;

  // --- 邏輯修正：isFavorite 已移除 ---
  // 這個狀態應該由一個獨立的 WishlistProvider 或 FavoriteProvider 來管理。

  // --- 邏輯優化：isSold 是一個 getter，而不是儲存的屬性 ---
  // 它的值根據其他屬性計算得出，永遠保持正確。
  bool get isSold => stockQuantity == 0 || status == 'sold';

  // 這是前端 UI 狀態，不屬於核心模型，但為了方便 UI 操作可以保留
  // 建議在 Provider 或頁面的 State 中管理這個狀態
  final bool isFavorite;

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
    this.shippingInfo,
    this.seller,
    this.isFavorite = false, // UI 狀態的預設值
  });

  // fromJson 工廠方法，用於從後端 API 的 JSON 資料建立 Product 物件
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // --- 修正：確保所有欄位名稱與後端 snake_case 一致 ---
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      categoryId: json['category_id'] as int,
      category: json['category'] as String,
      stockQuantity: json['stock_quantity'] as int,
      // 如果 image_urls 可能為 null，提供一個空列表作為預設值
      imageUrls: (json['image_urls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      salesCount: json['sales_count'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      shippingInfo: json['shipping_info'] != null
          ? ShippingInformation.fromJson(json['shipping_info'] as Map<String, dynamic>)
          : null,
      seller: json['seller'] != null
          ? User.fromJson(json['seller'] as Map<String, dynamic>)
          : null,
      // isFavorite 不從後端獲取，由前端的 Provider 管理
    );
  }

  // copyWith 方法，方便在不改變原物件的情況下更新狀態
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
    ShippingInformation? shippingInfo,
    User? seller,
    bool? isFavorite, // 允許更新 UI 的收藏狀態
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
      shippingInfo: shippingInfo ?? this.shippingInfo,
      seller: seller ?? this.seller,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}


// Ensure ShippingInformation has a fromJson factory if you use it in Product.fromJson
// Example:
// class ShippingInformation {
//   final double cost;
//   final String provider;
//   ShippingInformation({required this.cost, required this.provider});

//   factory ShippingInformation.fromJson(Map<String, dynamic> json) {
//     return ShippingInformation(
//       cost: (json['cost'] as num).toDouble(),
//       provider: json['provider'] as String,
//     );
//   }
//   Map<String, dynamic> toJson() {
//     return {
//       'cost': cost,
//       'provider': provider,
//     };
//   }
// }