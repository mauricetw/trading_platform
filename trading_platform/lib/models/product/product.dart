import '../user/user.dart'; // Assuming User model is in 'user/user.dart' relative to this
import '../order/shipping_info.dart';


class Product {
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
  final DateTime? createdAt; // 修正：允許為 null
  final DateTime? updatedAt; // 修正：允許為 null
  final int salesCount;
  final double? averageRating;
  final int reviewCount;
  final List<String>? tags;
  final ShippingInformation? shippingInfo;
  final User? seller;

  bool get isSold => stockQuantity == 0 || status == 'sold';

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
    this.createdAt,
    this.updatedAt,
    required this.salesCount,
    this.averageRating,
    required this.reviewCount,
    this.tags,
    this.shippingInfo,
    this.seller,
    this.isFavorite = false,
  });

  // --- 錯誤修正：全面增強 fromJson 方法的健壯性 ---
  factory Product.fromJson(Map<String, dynamic> json) {
    // 輔助函式，安全地解析日期時間
    DateTime? parseDateTime(String? dateString) {
      return dateString != null ? DateTime.tryParse(dateString) : null;
    }

    return Product(
      id: json['id'] as int? ?? 0, // 如果 id 是 null，預設為 0
      name: json['name'] as String? ?? '無標題', // 如果 name 是 null，提供預設值
      description: json['description'] as String? ?? '', // 如果 description 是 null，提供空字串
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      categoryId: json['category_id'] as int? ?? 0,
      category: json['category'] as String? ?? '未分類', // 如果 category 是 null，提供預設值
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      imageUrls: (json['image_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [], // 如果 image_urls 是 null，提供空列表
      status: json['status'] as String? ?? 'unavailable', // 如果 status 是 null，提供預設值
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      salesCount: json['sales_count'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      shippingInfo: json['shipping_info'] != null
          ? ShippingInformation.fromJson(json['shipping_info'] as Map<String, dynamic>)
          : null,
      seller: json['seller'] != null
          ? User.fromJson(json['seller'] as Map<String, dynamic>)
          : null,
    );
  }

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