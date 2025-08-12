// --- FILE: lib/models/user/user.dart ---

import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class User {
  // --- 基礎欄位 (與後端對齊) ---
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

  // --- 賣家相關屬性 ---
  final bool isSeller;
  final String? sellerName;
  final String? sellerDescription;
  final double? sellerRating;
  final double? buyerRating;
  final int productCount;

  // --- 收藏狀態 ---
  @JsonKey(defaultValue: [])
  final List<String> favoriteProductIds;

  // --- 新增：公開資訊欄位 ---
  final String? publicDisplayName;
  final String? publicBio;
  final String? publicCoverPhotoUrl;
  @JsonKey(defaultValue: false)
  final bool isSchoolPublic;

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
    // 初始化新增的公開資訊欄位
    this.publicDisplayName,
    this.publicBio,
    this.publicCoverPhotoUrl,
    this.isSchoolPublic = false,
  });

  // --- Helper getter ---
  String get effectivePublicDisplayName => publicDisplayName?.isNotEmpty == true ? publicDisplayName! : username;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // --- copyWith (合併後版本) ---
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
    String? publicDisplayName,
    String? publicBio,
    String? publicCoverPhotoUrl,
    bool? isSchoolPublic,
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
      publicDisplayName: publicDisplayName ?? this.publicDisplayName,
      publicBio: publicBio ?? this.publicBio,
      publicCoverPhotoUrl: publicCoverPhotoUrl ?? this.publicCoverPhotoUrl,
      isSchoolPublic: isSchoolPublic ?? this.isSchoolPublic,
    );
  }
}
