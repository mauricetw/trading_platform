import 'package:flutter/foundation.dart'; // 為了 debugPrint
import 'package:json_annotation/json_annotation.dart';
import '../product/product.dart';
import '../user/user.dart';
import 'wishpool.dart';

part 'wishpool_invite.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  createFactory: false, // [關鍵] 我們改為手動實作 fromJson
)
class WishPoolInvite {
  final int id;
  final int wishPoolId;
  final int sellerId;
  final int? productId;
  final String? message;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final User? seller;
  final Product? product;
  final WishPool? wishpool;

  WishPoolInvite({
    required this.id,
    required this.wishPoolId,
    required this.sellerId,
    this.productId,
    this.message,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
    this.seller,
    this.product,
    this.wishpool,
  });

  // --- [關鍵修正] 手動實作 fromJson 以確保最高強健性 ---
  factory WishPoolInvite.fromJson(Map<String, dynamic> json) {
    try {
      // 安全解析整數
      int safeInt(dynamic val, int defaultVal) {
        if (val == null) return defaultVal;
        if (val is num) return val.toInt();
        if (val is String) return int.tryParse(val) ?? defaultVal;
        return defaultVal;
      }

      // 安全解析可空整數
      int? safeNullableInt(dynamic val) {
        if (val == null) return null;
        if (val is num) return val.toInt();
        if (val is String) return int.tryParse(val);
        return null;
      }

      return WishPoolInvite(
        id: safeInt(json['id'], 0),
        wishPoolId: safeInt(json['wishpool_id'], 0),
        sellerId: safeInt(json['seller_id'], 0),
        productId: safeNullableInt(json['product_id']),
        message: json['message'] as String?,
        status: json['status'] as String? ?? 'pending',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        // 安全解析巢狀物件
        seller: json['seller'] != null
            ? User.fromJson(json['seller'] as Map<String, dynamic>)
            : null,
        product: json['product'] != null
            ? Product.fromJson(json['product'] as Map<String, dynamic>)
            : null,
        wishpool: json['wishpool'] != null
            ? WishPool.fromJson(json['wishpool'] as Map<String, dynamic>)
            : null,
      );
    } catch (e, stack) {
      debugPrint('WishPoolInvite 解析失敗: $e');
      debugPrint('Stack trace: $stack');
      // 回傳一個空的/錯誤的物件，避免整個列表崩潰
      return WishPoolInvite(
        id: 0,
        wishPoolId: 0,
        sellerId: 0,
        createdAt: DateTime.now(),
        status: 'error',
        message: '解析錯誤',
      );
    }
  }

  Map<String, dynamic> toJson() => _$WishPoolInviteToJson(this);

  WishPoolInvite copyWith({
    int? id,
    int? wishPoolId,
    int? sellerId,
    int? productId,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? seller,
    Product? product,
    WishPool? wishpool,
  }) {
    return WishPoolInvite(
      id: id ?? this.id,
      wishPoolId: wishPoolId ?? this.wishPoolId,
      sellerId: sellerId ?? this.sellerId,
      productId: productId ?? this.productId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      seller: seller ?? this.seller,
      product: product ?? this.product,
      wishpool: wishpool ?? this.wishpool,
    );
  }
}