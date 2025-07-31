// --- FILE: lib/models/user/user.dart ---

import 'package:json_annotation/json_annotation.dart';

// 這行會將此檔案與下面第二步將自動產生的檔案連結起來。
part 'user.g.dart';

// @JsonSerializable 告訴產生器要為這個類別建立程式碼。
// fieldRename: FieldRename.snake 會自動將 Dart 的駝峰式命名 (例如 phoneNumber)
// 轉換為 JSON 的蛇形命名 (例如 phone_number)，與我們的後端完全匹配。
@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  // --- 欄位與你的版本 (以及後端) 完全對齊 ---
  final int id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final DateTime registeredAt;
  final DateTime? lastLoginAt;
  final String? bio;
  final String? schoolName;
  final bool isVerified;
  final List<String> roles;

  // 賣家相關屬性
  final bool isSeller;
  final String? sellerName;
  final String? sellerDescription;
  final double? sellerRating;
  final double? buyerRating;
  final int productCount;

  // 來自組員版本的好點子，用於客戶端管理收藏狀態
  @JsonKey(defaultValue: [])
  final List<String> favoriteProductIds;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.registeredAt,
    this.phoneNumber,
    this.avatarUrl,
    this.lastLoginAt,
    this.bio,
    this.schoolName,
    required this.isVerified,
    required this.roles,
    required this.isSeller,
    this.sellerName,
    this.sellerDescription,
    this.sellerRating,
    this.buyerRating,
    required this.productCount,
    this.favoriteProductIds = const [],
  });

  // --- 由程式碼產生器實現的方法 ---
  // fromJson 和 toJson 方法現在會在 user.g.dart 中自動產生
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // 你的 copyWith 方法對於狀態管理仍然非常有用，所以我們保留它。
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    DateTime? registeredAt,
    DateTime? lastLoginAt,
    String? bio,
    String? schoolName,
    bool? isVerified,
    List<String>? roles,
    bool? isSeller,
    String? sellerName,
    String? sellerDescription,
    double? sellerRating,
    double? buyerRating,
    int? productCount,
    List<String>? favoriteProductIds,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      registeredAt: registeredAt ?? this.registeredAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      bio: bio ?? this.bio,
      schoolName: schoolName ?? this.schoolName,
      isVerified: isVerified ?? this.isVerified,
      roles: roles ?? this.roles,
      isSeller: isSeller ?? this.isSeller,
      sellerName: sellerName ?? this.sellerName,
      sellerDescription: sellerDescription ?? this.sellerDescription,
      sellerRating: sellerRating ?? this.sellerRating,
      buyerRating: buyerRating ?? this.buyerRating,
      productCount: productCount ?? this.productCount,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
    );
  }
}
