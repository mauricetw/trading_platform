import 'package:json_annotation/json_annotation.dart';
import '../user/user.dart';
import '../product/product.dart';
import 'package:flutter/foundation.dart';

part 'wishpool.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  createFactory: false,
)
class WishPool {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final int? categoryId;
  final List<String>? tags;
  final String? photoUrl;

  final int? priceMin;
  final int? priceMax;
  final String? location;
  final String? courseCode;

  final String status;
  final int? matchedItemId;
  final int likeCount;

  final DateTime createdAt;
  final DateTime updatedAt;

  final User? user;
  final Product? matchedItem;

  WishPool({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.categoryId,
    this.tags,
    this.photoUrl,
    this.priceMin,
    this.priceMax,
    this.location,
    this.courseCode,
    this.status = 'open',
    this.matchedItemId,
    this.likeCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.matchedItem,
  });

  factory WishPool.fromJson(Map<String, dynamic> json) {
    try {
      // 安全解析 Int
      int? safeInt(dynamic val) {
        if (val == null) return null;
        if (val is num) return val.toInt();
        if (val is String) return int.tryParse(val);
        return null;
      }

      return WishPool(
        id: safeInt(json['id']) ?? 0,
        userId: safeInt(json['user_id']) ?? 0,
        title: json['title'] as String? ?? '未命名願望',
        description: json['description'] as String?,
        categoryId: safeInt(json['category_id']),
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
        photoUrl: json['photo_url'] as String?,
        priceMin: safeInt(json['price_min']),
        priceMax: safeInt(json['price_max']),
        location: json['location'] as String?,
        courseCode: json['course_code'] as String?,
        status: json['status'] as String? ?? 'open',
        matchedItemId: safeInt(json['matched_item_id']),
        likeCount: safeInt(json['like_count']) ?? 0,
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        matchedItem: json['matched_item'] != null
            ? Product.fromJson(json['matched_item'])
            : null,
      );
    } catch (e) {
      debugPrint('WishPool 解析失敗: $e');
      return WishPool(
        id: 0,
        userId: 0,
        title: '解析失敗',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // --- [BUG 修正] 補上 toJson 方法 ---
  Map<String, dynamic> toJson() => _$WishPoolToJson(this);
}