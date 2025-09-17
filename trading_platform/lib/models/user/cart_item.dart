// lib/models/user/cart_item.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
import '../product/product.dart';

part 'cart_item.g.dart';

class DataQualityIssue {
  final String field;
  final String issue;
  final dynamic receivedValue;
  final dynamic usedValue;

  DataQualityIssue({
    required this.field,
    required this.issue,
    required this.receivedValue,
    required this.usedValue,
  });

  @override
  String toString() => 'Field: $field, Issue: $issue, Received: $receivedValue, Used: $usedValue';
}

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

  // 記錄解析過程中發現的資料品質問題
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<DataQualityIssue> dataIssues = [];

  CartItem({
    this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.addedAt,
    required this.product,
    this.isSelected = false,
  });

  // 有資料品質問題嗎？
  bool get hasDataIssues => dataIssues.isNotEmpty;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final issues = <DataQualityIssue>[];

    try {
      debugPrint('=== CartItem 解析開始 ===');
      debugPrint('原始 JSON: $json');

      // 嚴格但不崩潰的轉換函數
      int strictInt(dynamic value, String fieldName, int fallback) {
        if (value == null) {
          issues.add(DataQualityIssue(
            field: fieldName,
            issue: 'CRITICAL: Field is null',
            receivedValue: value,
            usedValue: fallback,
          ));
          return fallback;
        }

        if (value is int) return value;

        if (value is num) {
          final intValue = value.toInt();
          if (value != intValue) {
            issues.add(DataQualityIssue(
              field: fieldName,
              issue: 'WARNING: Non-integer number converted',
              receivedValue: value,
              usedValue: intValue,
            ));
          }
          return intValue;
        }

        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            issues.add(DataQualityIssue(
              field: fieldName,
              issue: 'WARNING: String converted to int',
              receivedValue: value,
              usedValue: parsed,
            ));
            return parsed;
          } else {
            issues.add(DataQualityIssue(
              field: fieldName,
              issue: 'CRITICAL: Invalid string, cannot convert to int',
              receivedValue: value,
              usedValue: fallback,
            ));
            return fallback;
          }
        }

        issues.add(DataQualityIssue(
          field: fieldName,
          issue: 'CRITICAL: Unexpected type ${value.runtimeType}',
          receivedValue: value,
          usedValue: fallback,
        ));
        return fallback;
      }

      // 解析各欄位
      final id = json['id'] != null ? strictInt(json['id'], 'id', 0) : null;
      final userId = strictInt(json['user_id'], 'user_id', 0);
      final productId = strictInt(json['product_id'], 'product_id', 0);
      final quantity = strictInt(json['quantity'], 'quantity', 1);

      // 檢查關鍵欄位
      if (userId == 0) {
        issues.add(DataQualityIssue(
          field: 'user_id',
          issue: 'CRITICAL: user_id is 0, indicates authentication issue',
          receivedValue: json['user_id'],
          usedValue: 0,
        ));
      }

      if (productId == 0) {
        issues.add(DataQualityIssue(
          field: 'product_id',
          issue: 'CRITICAL: product_id is 0, invalid product reference',
          receivedValue: json['product_id'],
          usedValue: 0,
        ));
      }

      // 解析日期
      DateTime addedAt;
      try {
        if (json['added_at'] != null) {
          addedAt = DateTime.parse(json['added_at'] as String);
        } else {
          addedAt = DateTime.now();
          issues.add(DataQualityIssue(
            field: 'added_at',
            issue: 'WARNING: added_at is null, using current time',
            receivedValue: json['added_at'],
            usedValue: addedAt.toIso8601String(),
          ));
        }
      } catch (e) {
        addedAt = DateTime.now();
        issues.add(DataQualityIssue(
          field: 'added_at',
          issue: 'CRITICAL: Invalid date format',
          receivedValue: json['added_at'],
          usedValue: addedAt.toIso8601String(),
        ));
      }

      // 解析 Product
      Product product;
      final productData = json['product'];

      if (productData == null) {
        issues.add(DataQualityIssue(
          field: 'product',
          issue: 'CRITICAL: Product data is completely missing',
          receivedValue: productData,
          usedValue: 'fallback_product',
        ));

        product = Product(
          id: productId,
          name: '【資料缺失】未知商品',
          description: '商品資料完全缺失，請檢查後端 API',
          price: 0.0,
          categoryId: 0,
          category: '錯誤',
          imageUrls: const [],
          stockQuantity: 0,
          status: 'data_missing',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          salesCount: 0,
          reviewCount: 0,
          sellerId: 0,
          isFavorite: false,
        );
      } else if (productData is Map<String, dynamic>) {
        try {
          product = Product.fromJson(productData);
        } catch (e) {
          issues.add(DataQualityIssue(
            field: 'product',
            issue: 'CRITICAL: Product parsing failed',
            receivedValue: 'complex_object',
            usedValue: 'fallback_product',
          ));

          // 嘗試部分解析
          product = Product(
            id: productId,
            name: (productData['name'] as String?) ?? '【解析失敗】商品',
            description: '商品資料解析失敗: $e',
            price: (productData['price'] as num?)?.toDouble() ?? 0.0,
            categoryId: 0,
            category: '解析錯誤',
            imageUrls: const [],
            stockQuantity: 0,
            status: 'parse_error',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            salesCount: 0,
            reviewCount: 0,
            sellerId: 0,
            isFavorite: false,
          );
        }
      } else {
        issues.add(DataQualityIssue(
          field: 'product',
          issue: 'CRITICAL: Product data has wrong type',
          receivedValue: productData.runtimeType.toString(),
          usedValue: 'fallback_product',
        ));

        product = Product(
          id: productId,
          name: '【格式錯誤】商品',
          description: '商品資料格式不正確',
          price: 0.0,
          categoryId: 0,
          category: '格式錯誤',
          imageUrls: const [],
          stockQuantity: 0,
          status: 'format_error',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          salesCount: 0,
          reviewCount: 0,
          sellerId: 0,
          isFavorite: false,
        );
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

      // 將問題記錄加入 CartItem
      cartItem.dataIssues.addAll(issues);

      // 立即報告嚴重問題
      final criticalIssues = issues.where((issue) => issue.issue.contains('CRITICAL')).toList();
      if (criticalIssues.isNotEmpty) {
        debugPrint('🚨 CartItem 嚴重資料問題 🚨');
        for (final issue in criticalIssues) {
          debugPrint('❌ $issue');
        }
        debugPrint('原始 JSON: $json');
        debugPrint('請立即檢查後端 API！');
      }

      final warningIssues = issues.where((issue) => issue.issue.contains('WARNING')).toList();
      if (warningIssues.isNotEmpty) {
        debugPrint('⚠️  CartItem 資料品質警告');
        for (final issue in warningIssues) {
          debugPrint('⚠️  $issue');
        }
      }

      if (issues.isEmpty) {
        debugPrint('✅ CartItem 解析完美：${cartItem.product.name}');
      }

      return cartItem;

    } catch (e, stackTrace) {
      debugPrint('💥 CartItem 解析完全失敗 💥');
      debugPrint('錯誤: $e');
      debugPrint('原始 JSON: $json');
      debugPrint('堆疊: $stackTrace');

      // 即使完全失敗，也要回傳可用的物件
      final emergencyItem = CartItem(
        id: null,
        userId: 0,
        productId: 0,
        quantity: 1,
        addedAt: DateTime.now(),
        product: Product(
          id: 0,
          name: '【緊急錯誤】無法解析',
          description: '嚴重錯誤: $e',
          price: 0.0,
          categoryId: 0,
          category: '系統錯誤',
          imageUrls: const [],
          stockQuantity: 0,
          status: 'system_error',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          salesCount: 0,
          reviewCount: 0,
          sellerId: 0,
          isFavorite: false,
        ),
        isSelected: false,
      );

      emergencyItem.dataIssues.add(DataQualityIssue(
        field: 'entire_object',
        issue: 'CRITICAL: Complete parsing failure',
        receivedValue: json,
        usedValue: 'emergency_fallback',
      ));

      return emergencyItem;
    }
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