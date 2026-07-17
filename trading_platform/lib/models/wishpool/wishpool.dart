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

  final int price;
  final int quantity;

  // --- [修改] addressId 已移除，改為 shippingAddress 快照 ---
  // 雖然這在後端有，但為了簡單起見，我們前端模型暫時不需要顯示這個詳細地址，
  // 除非你想在詳情頁顯示。這裡先不加入，以免解析錯誤。

  final String shippingName;
  final double shippingCost;

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
    required this.price,
    required this.quantity,
    required this.shippingName,
    required this.shippingCost,
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
      int? safeInt(dynamic val) {
        if (val == null) return null;
        if (val is num) return val.toInt();
        if (val is String) return int.tryParse(val);
        return null;
      }
      double safeDouble(dynamic val, double defaultVal) {
        if (val == null) return defaultVal;
        if (val is num) return val.toDouble();
        if (val is String) return double.tryParse(val) ?? defaultVal;
        return defaultVal;
      }

      return WishPool(
        id: safeInt(json['id']) ?? 0,
        userId: safeInt(json['user_id']) ?? 0,
        title: json['title'] as String? ?? '未命名願望',
        description: json['description'] as String?,
        categoryId: safeInt(json['category_id']),
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
        photoUrl: json['photo_url'] as String?,
        price: safeInt(json['price']) ?? 0,
        quantity: safeInt(json['quantity']) ?? 1,

        shippingName: json['shipping_name'] as String? ?? '標準配送',
        shippingCost: safeDouble(json['shipping_cost'], 60.0),

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
        price: 0,
        quantity: 1,
        shippingName: '',
        shippingCost: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() => _$WishPoolToJson(this);
}