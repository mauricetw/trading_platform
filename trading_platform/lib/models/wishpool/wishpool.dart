import 'package:json_annotation/json_annotation.dart';
import '../user/user.dart';
import '../product/product.dart';

part 'wishpool.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  createFactory: false,
)
class WishPool {
  final int id;
  final int userId;                // 願望發布者 ID
  final String title;              // 願望標題
  final String? description;       // 願望內容描述
  final int? categoryId;           // 類別
  final List<String>? tags;        // 標籤
  final String? photoUrl;          // 願望圖片

  final int? priceMin;
  final int? priceMax;
  final String? location;
  final String? courseCode;

  final String status;             // open / matched / closed
  final int? matchedItemId;        // 若已被商品匹配，紀錄商品ID
  final int likeCount;             // 「我也想要」數量

  final DateTime createdAt;
  final DateTime updatedAt;

  // ✅ 關聯對象（方便前端展示）
  final User? user;                // 發布者資訊
  final Product? matchedItem;      // 被匹配的商品資訊（可為 null）

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

  /// ========== Custom fromJson ==========
  factory WishPool.fromJson(Map<String, dynamic> json) {
    try {
      return WishPool(
        id: json['id'] as int? ?? 0,
        userId: json['user_id'] as int? ?? 0,
        title: json['title'] as String? ?? '未命名願望',
        description: json['description'] as String?,
        categoryId: json['category_id'] as int?,
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
        photoUrl: json['photo_url'] as String?,
        priceMin: json['price_min'] as int?,
        priceMax: json['price_max'] as int?,
        location: json['location'] as String?,
        courseCode: json['course_code'] as String?,
        status: json['status'] as String? ?? 'open',
        matchedItemId: json['matched_item_id'] as int?,
        likeCount: json['like_count'] as int? ?? 0,
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        matchedItem: json['matched_item'] != null
            ? Product.fromJson(json['matched_item'])
            : null,
      );
    } catch (e) {
      // fallback：若格式不完整仍建立空物件，避免 crash
      return WishPool(
        id: 0,
        userId: 0,
        title: '解析失敗',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'description': description,
    'category_id': categoryId,
    'tags': tags,
    'photo_url': photoUrl,
    'price_min': priceMin,
    'price_max': priceMax,
    'location': location,
    'course_code': courseCode,
    'status': status,
    'matched_item_id': matchedItemId,
    'like_count': likeCount,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    if (user != null) 'user': user!.toJson(),
    if (matchedItem != null) 'matched_item': matchedItem!.toJson(),
  };
}
