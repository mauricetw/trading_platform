// lib/models/user/cart_item.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
import '../product/product.dart';

part 'cart_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true, createFactory: false)
class CartItem {
  final int? id;
  final int userId;
  final int productId;
  final int quantity;
  final DateTime addedAt;
  final Product product;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool isSelected;

  CartItem({
    this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.addedAt,
    required this.product,
    this.isSelected = false,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('CartItem: 開始解析 - ${json['product']?['name'] ?? 'Unknown'}');

      // 安全的數值轉換
      int safeInt(dynamic value, int defaultValue) {
        if (value == null) return defaultValue;
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? defaultValue;
        return defaultValue;
      }

      // 解析基本欄位
      final id = json['id'] != null ? safeInt(json['id'], 0) : null;
      final userId = safeInt(json['user_id'], 0);
      final quantity = safeInt(json['quantity'], 1);

      // 智能獲取 product_id
      int productId;
      if (json['product_id'] != null) {
        productId = safeInt(json['product_id'], 0);
      } else {
        // 從 product.id 獲取
        final productData = json['product'];
        if (productData is Map<String, dynamic> && productData['id'] != null) {
          productId = safeInt(productData['id'], 0);
        } else {
          productId = 0;
        }
      }

      // 解析日期
      DateTime addedAt;
      try {
        addedAt = json['added_at'] != null
            ? DateTime.parse(json['added_at'] as String)
            : DateTime.now();
      } catch (e) {
        addedAt = DateTime.now();
      }

      // 解析 Product
      Product product;
      final productData = json['product'];

      if (productData is Map<String, dynamic>) {
        try {
          product = Product.fromJson(productData);
        } catch (e) {
          debugPrint('Product 標準解析失敗，使用備用解析: $e');
          product = _createProductFromBackendData(productData, productId);
        }
      } else {
        product = _createFallbackProduct(productId);
      }

      final cartItem = CartItem(
        id: id,
        userId: userId,
        productId: productId,
        quantity: quantity,
        addedAt: addedAt,
        product: product,
        isSelected: false,
      );

      debugPrint('CartItem: 解析成功 - ${cartItem.product.name}');
      return cartItem;

    } catch (e, stackTrace) {
      debugPrint('CartItem: 解析失敗 - $e');
      debugPrint('原始 JSON: $json');

      return CartItem(
        id: null,
        userId: 0,
        productId: 0,
        quantity: 1,
        addedAt: DateTime.now(),
        product: _createFallbackProduct(0),
        isSelected: false,
      );
    }
  }

  // 從後端資料建立 Product
  static Product _createProductFromBackendData(Map<String, dynamic> data, int fallbackId) {
    try {
      // 處理圖片
      List<String> imageUrls = [];
      final images = data['images'] as List?;
      if (images != null) {
        for (var img in images) {
          if (img is Map<String, dynamic>) {
            final imageUrl = img['image_url'] as String?;
            if (imageUrl != null) {
              if (imageUrl.startsWith('http')) {
                imageUrls.add(imageUrl);
              } else {
                imageUrls.add('http://10.0.2.2:8000$imageUrl');
              }
            }
          }
        }
      }

      // 處理分類
      String categoryName = '未分類';
      int categoryId = 0;
      final category = data['category'];
      if (category is Map<String, dynamic>) {
        categoryName = category['name'] as String? ?? '未分類';
        categoryId = category['id'] as int? ?? 0;
      }

      // 處理賣家資訊
      SellerInfo? seller;
      final sellerData = data['seller'];
      if (sellerData is Map<String, dynamic>) {
        seller = SellerInfo(
          id: sellerData['id'] as int? ?? 0,
          username: sellerData['username'] as String? ?? '未知賣家',
          avatarUrl: sellerData['avatar_url'] as String?,
        );
      }

      return Product(
        id: (data['id'] as int?) ?? fallbackId,
        name: (data['name'] as String?) ?? '未知商品',
        description: (data['description'] as String?) ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        originalPrice: (data['original_price'] as num?)?.toDouble(),
        categoryId: categoryId,
        category: categoryName,
        imageUrls: imageUrls,
        stockQuantity: (data['stock_quantity'] as int?) ?? 0,
        status: (data['status'] as String?) ?? 'unknown',
        createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(data['updated_at'] as String? ?? '') ?? DateTime.now(),
        salesCount: (data['sales_count'] as int?) ?? 0,
        averageRating: (data['average_rating'] as num?)?.toDouble(),
        reviewCount: (data['review_count'] as int?) ?? 0,
        tags: (data['tags'] as List?)?.map((e) => e.toString()).toList(),
        sellerId: (data['seller_id'] as int?) ?? 0,
        seller: seller,
        //isFavorite: false,
      );
    } catch (e) {
      debugPrint('備用 Product 解析失敗: $e');
      return _createFallbackProduct(fallbackId);
    }
  }

  // 建立預設 Product
  static Product _createFallbackProduct(int id) {
    return Product(
      id: id,
      name: '商品解析失敗',
      description: '無法解析商品資訊',
      price: 0.0,
      categoryId: 0,
      category: '錯誤',
      imageUrls: const [],
      stockQuantity: 0,
      status: 'error',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      salesCount: 0,
      reviewCount: 0,
      sellerId: 0,
      //isFavorite: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'added_at': addedAt.toIso8601String(),
      'product': product.toJson(),
    };
  }

  CartItem copyWith({
    int? id,
    int? userId,
    int? productId,
    int? quantity,
    DateTime? addedAt,
    Product? product,
    bool? isSelected,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
      product: product ?? this.product,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}