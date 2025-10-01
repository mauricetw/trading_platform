// --- FILE: lib/models/product/product.dart ---
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
import '../order/shipping_info.dart';
import '../../config/api_config.dart';

part 'product.g.dart';

/// ===============
/// SellerInfo - (保留組員的健壯版本)
/// ===============
@JsonSerializable(fieldRename: FieldRename.snake)
class SellerInfo {
  final int id;
  @JsonKey(name: 'nickname')
  final String? _username;
  final String? avatarUrl;

  String get username => _username ?? '未知賣家';

  SellerInfo({
    required this.id,
    String? username,
    this.avatarUrl,
  }) : _username = username;

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    try {
      return SellerInfo(
        id: (json['id'] as int?) ?? 0,
        username: (json['nickname'] as String?) ?? (json['username'] as String?),
        avatarUrl: _prefixUrl(json['avatar_url'] as String?),
      );
    } catch (e) {
      debugPrint('SellerInfo.fromJson 錯誤: $e');
      return SellerInfo(id: (json['id'] as int?) ?? 0, username: '未知賣家');
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': _username,
    'avatar_url': avatarUrl,
  };
}


/// ===============
/// Product
/// ===============
@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  createFactory: false, // 我們自訂 fromJson
)
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int categoryId;

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

  // --- 關鍵修正：isFavorite 欄位已完全移除 ---

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
  });

  /// 自訂 fromJson：完整保留組員設計的健壯性邏輯
  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      // 1) category 相容處理
      int resolvedCategoryId = 0;
      String resolvedCategoryName = '未分類';
      final categoryData = json['category'];
      if (categoryData is Map<String, dynamic>) {
        resolvedCategoryId = categoryData['id'] as int? ?? 0;
        resolvedCategoryName = categoryData['name'] as String? ?? '未分類';
      }

      // 2) images 相容處理並轉換為絕對路徑
      final rawImages = (json['images'] as List?) ?? const [];
      final resolvedImageUrls = rawImages
          .map((e) {
        if (e is Map<String, dynamic>) {
          return _prefixUrl(e['image_url'] as String?);
        }
        return null;
      })
          .where((s) => s != null)
          .cast<String>()
          .toList();

      // 3) DateTime 安全解析
      DateTime parseDateTime(dynamic dateValue, DateTime fallback) {
        if (dateValue is String) {
          return DateTime.tryParse(dateValue) ?? fallback;
        }
        return fallback;
      }

      final now = DateTime.now();

      // 4) 數值安全轉換
      double safeDouble(dynamic value, double defaultValue) {
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? defaultValue;
        return defaultValue;
      }
      double? safeNullableDouble(dynamic value) {
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value);
        return null;
      }
      int safeInt(dynamic value, int defaultValue) {
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? defaultValue;
        return defaultValue;
      }

      // 5) 建立 Product 實例
      return Product(
        id: safeInt(json['id'], 0),
        name: (json['name'] as String?) ?? '未知商品',
        description: (json['description'] as String?) ?? '',
        price: safeDouble(json['price'], 0.0),
        originalPrice: safeNullableDouble(json['original_price']),
        categoryId: resolvedCategoryId,
        category: resolvedCategoryName,
        imageUrls: resolvedImageUrls,
        stockQuantity: safeInt(json['stock_quantity'], 0),
        status: (json['status'] as String?) ?? 'unknown',
        salesCount: safeInt(json['sales_count'], 0),
        averageRating: safeNullableDouble(json['average_rating']),
        reviewCount: safeInt(json['review_count'], 0),
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
        createdAt: parseDateTime(json['created_at'], now),
        updatedAt: parseDateTime(json['updated_at'], now),
        sellerId: safeInt(json['seller_id'], 0),
        seller: (json['seller'] is Map<String, dynamic>)
            ? _safeSellerInfoFromJson(json['seller'] as Map<String, dynamic>)
            : null,
        shippingInfo: (json['shipping_info'] is Map<String, dynamic>)
            ? _safeShippingInfoFromJson(json['shipping_info'] as Map<String, dynamic>)
            : null,
      );
    } catch (e, stackTrace) {
      debugPrint('Product.fromJson 解析失敗: $e\n$stackTrace');
      // 返回一個最小可用的 Product 實例，避免完全失敗
      return Product(
        id: (json['id'] as int?) ?? 0,
        name: '解析失敗的商品',
        description: '資料解析時發生錯誤: $e',
        price: 0.0,
        categoryId: 0,
        category: '未分類',
        imageUrls: const [],
        stockQuantity: 0,
        status: 'error',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        salesCount: 0,
        reviewCount: 0,
        sellerId: 0,
      );
    }
  }

  /// 安全的 SellerInfo 解析 (保留組員的設計)
  static SellerInfo? _safeSellerInfoFromJson(Map<String, dynamic> json) {
    try {
      return SellerInfo.fromJson(json);
    } catch (e) {
      debugPrint('SellerInfo 解析失敗: $e');
      return SellerInfo(
        id: (json['id'] as int?) ?? 0,
        username: (json['nickname'] as String?) ?? '未知賣家',
        avatarUrl: (json['avatar_url'] as String?),
      );
    }
  }

  /// 安全的 ShippingInformation 解析 (保留組員的設計)
  static ShippingInformation? _safeShippingInfoFromJson(Map<String, dynamic> json) {
    try {
      return ShippingInformation.fromJson(json);
    } catch (e) {
      debugPrint('ShippingInformation 解析失敗: $e');
      return null;
    }
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
    );
  }
}

// 輔助函式 (放在檔案底部)
String? _prefixUrl(String? relativeUrl) {
  if (relativeUrl == null || relativeUrl.isEmpty) {
    return null;
  }
  if (relativeUrl.startsWith('http')) {
    return relativeUrl;
  }
  return '${APIConfig.baseUrl}$relativeUrl';
}
