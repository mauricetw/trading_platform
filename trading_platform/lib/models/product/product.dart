import '../user/user.dart'; // Assuming User model is in 'user/user.dart' relative to this
import '../order/shipping_info.dart';


class Product {
  final String id; // 唯一識別碼
  final String name;
  final String description;
  // Renamed from originalprice to originalPrice for consistency with HomePage
  final double? originalPrice; // Made nullable as it might not always exist
  final double price;         // Added 'price' as this is what HomePage's _formatPrice expects
  // Renamed from catehoryId to categoryId for consistency and common practice
  final int categoryId;
  final int stockQuantity;
  final List<String> imageUrls;
  final String category; // This can be derived from categoryId or stored directly
  final String status; // 例如："available", "unavailable", "sold"
  final DateTime createdAt;
  final DateTime updatedAt;

  final int salesCount;
  final double? averageRating;
  final int? reviewCount;
  final List<String>? tags;
  final ShippingInformation? shippingInfo;
  final User? seller;

  // Fields required/used by HomePage logic (ensure these are present)
  final bool isFavorite; // Used by _toggleFavorite and _buildProductCard
  final bool isSold;     // Used by _buildProductCard to show "SOLD" tag

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price, // Added required price
    this.originalPrice, // Changed from originalprice
    required this.categoryId, // Changed from catehoryId
    required this.stockQuantity,
    required this.imageUrls,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.salesCount = 0,
    this.averageRating,
    this.reviewCount,
    this.tags,
    this.shippingInfo,
    this.seller,
    // Default values for HomePage specific fields
    this.isFavorite = false,
    this.isSold = false, // Determine this based on stockQuantity or status if needed
  });

  // Optional: A copyWith method is useful for updating immutable objects
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
      isFavorite: isFavorite ?? this.isFavorite,
      isSold: isSold ?? this.isSold,
    );
  }

  // Optional: fromJson and toJson methods if you plan to serialize/deserialize
  // This is a basic example, adjust according to your User and ShippingInformation models
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      categoryId: json['categoryId'] as int,
      stockQuantity: json['stockQuantity'] as int,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      category: json['category'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      salesCount: json['salesCount'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      shippingInfo: json['shippingInfo'] != null
          ? ShippingInformation.fromJson(json['shippingInfo'] as Map<String, dynamic>) // Assuming ShippingInformation has fromJson
          : null,
      seller: json['seller'] != null
          ? User.fromJson(json['seller'] as Map<String, dynamic>) // Assuming User has fromJson
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isSold: json['isSold'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'categoryId': categoryId,
      'stockQuantity': stockQuantity,
      'imageUrls': imageUrls,
      'category': category,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'salesCount': salesCount,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'tags': tags,
      // 'shippingInfo': shippingInfo?.toJson(), // Assuming ShippingInformation has toJson
      // 'seller': seller?.toJson(),             // Assuming User has toJson
      'isFavorite': isFavorite,
      'isSold': isSold,
    };
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