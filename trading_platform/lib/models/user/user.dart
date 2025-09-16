// --- FILE: lib/models/user/user.dart ---
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(
    fieldRename: FieldRename.snake,
    explicitToJson: true,
    createFactory: false // 我們將手動實作 fromJson 工廠方法
)
class User {
  // --- 基礎欄位 (已完整保留) ---
  final int id;
  // --- 關鍵修正：透過 JsonKey，將後端的 'nickname' 對應到前端的 'username' ---
  @JsonKey(name: 'nickname')
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

  // --- 賣家相關屬性 (已完整保留) ---
  final bool isSeller;
  final String? sellerName;
  final String? sellerDescription;
  final double? sellerRating;
  final double? buyerRating;
  final int productCount;

  // --- 收藏狀態 (已完整保留) ---
  @JsonKey(defaultValue: [])
  final List<String> favoriteProductIds;

  // --- 公開資訊欄位 (已完整保留) ---
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
    this.publicDisplayName,
    this.publicBio,
    this.publicCoverPhotoUrl,
    this.isSchoolPublic = false,
  });

  // --- Helper getter (已保留) ---
  String get effectivePublicDisplayName => publicDisplayName?.isNotEmpty == true ? publicDisplayName! : username;

  // --- 關鍵修正：強化 fromJson 的空值處理能力 ---
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      username: json['nickname'] as String?
          ?? json['username'] as String?
          ?? '未知使用者',
      email: json['email'] as String? ?? '',
      registeredAt: json['registered_at'] != null ? DateTime.parse(json['registered_at'] as String) : DateTime.now(),
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      lastLoginAt: json['last_login_at'] != null ? DateTime.parse(json['last_login_at'] as String) : null,
      bio: json['bio'] as String?,
      schoolName: json['school_name'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ?? ['user'],
      isSeller: json['is_seller'] as bool? ?? false,
      sellerName: json['seller_name'] as String?,
      sellerDescription: json['seller_description'] as String?,
      sellerRating: (json['seller_rating'] as num?)?.toDouble(),
      buyerRating: (json['buyer_rating'] as num?)?.toDouble(),
      productCount: json['product_count'] as int? ?? 0,
      favoriteProductIds: (json['favorite_product_ids'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      publicDisplayName: json['public_display_name'] as String?,
      publicBio: json['public_bio'] as String?,
      publicCoverPhotoUrl: json['public_cover_photo_url'] as String?,
      isSchoolPublic: json['is_school_public'] as bool? ?? false,
    );
  }

  /// toJson 方法會由 build_runner 自動產生
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // --- copyWith (已完整保留) ---
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

