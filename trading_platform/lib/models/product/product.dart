import '../user/user.dart'; // Assuming User model is in 'user/user.dart' relative to this
import '../order/shipping_info.dart';

// --- SellerInfo 模型 ---
// 這個模型精確對應後端 API 在商品列表中回傳的賣家資訊
// (來自 schemas/product_schema.py 中的 UserInProductResponse)
class SellerInfo {
  final int id;
  final String username;
  final String? avatarUrl;

  SellerInfo({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '未知賣家',
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}


// --- Product 模型 (嚴格根據 models/product.py 進行校準) ---
class Product {
  // --- 與 Python 模型完全對應的欄位 ---
  final int id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice; // nullable in python
  final int categoryId;
  final String category;
  final int stockQuantity;
  final String status;
  final List<String> imageUrls; // nullable in python, so we handle null in fromJson
  final int salesCount;
  final double? averageRating; // nullable in python
  final int reviewCount;
  final List<String>? tags; // nullable in python
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sellerId;
  final SellerInfo? seller; // The nested seller object from the API response
  final ShippingInformation? shippingInfo; // nullable in python

  // --- 前端邏輯欄位 ---
  // isSold 是一個 getter，它的值根據其他屬性計算得出，永遠保持正確。
  bool get isSold => stockQuantity == 0 || status == 'sold';

  // isFavorite 是純粹的前端 UI 狀態，由 Provider 管理
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
    required this.sellerId,
    this.seller,
    this.shippingInfo,
    this.isFavorite = false,
  });

  // --- fromJson 工廠方法 (最終健壯版) ---
  // 這個方法現在可以處理後端回傳的 JSON，即使某些欄位意外為 null
  factory Product.fromJson(Map<String, dynamic> json) {
    // 輔助函式，安全地解析日期時間
    DateTime parseDateTime(dynamic dateValue) {
      if (dateValue is String) {
        return DateTime.tryParse(dateValue) ?? DateTime.now();
      }
      // 提供一個預設值以避免崩潰
      return DateTime.now();
    }

    return Product(
      // --- 非 Nullable 欄位：提供安全的預設值以防止崩潰 ---
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '無商品名稱',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['category_id'] as int? ?? 0,
      category: json['category'] as String? ?? '未分類',
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      status: json['status'] as String? ?? 'unavailable',
      salesCount: json['sales_count'] as int? ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      sellerId: json['seller_id'] as int? ?? 0,

      // --- Nullable 欄位：直接解析 ---
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      imageUrls: (json['image_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),

      shippingInfo: json['shipping_info'] != null
          ? ShippingInformation.fromJson(json['shipping_info'] as Map<String, dynamic>)
          : null,
      seller: json['seller'] != null
          ? SellerInfo.fromJson(json['seller'] as Map<String, dynamic>)
          : null,
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