// --- FILE: lib/models/user/user.dart ---
import 'package:json_annotation/json_annotation.dart';
import '../../config/api_config.dart';

part 'user.g.dart';

@JsonSerializable(
    fieldRename: FieldRename.snake,
    explicitToJson: true,
    createFactory: false
)
class User {
  final int id;
  @JsonKey(name: 'nickname')
  final String username;
  final String email;
  final String? phoneNumber;

  @JsonKey(fromJson: _prefixUrl)
  final String? avatarUrl;

  final DateTime registeredAt;
  final DateTime? lastLoginAt;
  final String? bio;
  final String? schoolName;
  final String? address;
  final bool isVerified;
  final List<String> roles;

  final bool isSeller;
  final String? sellerName;
  final String? sellerDescription;
  final double? sellerRating;
  final double? buyerRating;
  final int productCount;

  @JsonKey(defaultValue: [])
  final List<String> favoriteProductIds;

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
    this.address,
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

  String get effectivePublicDisplayName => publicDisplayName?.isNotEmpty == true ? publicDisplayName! : username;

  factory User.fromJson(Map<String, dynamic> json) {
    // --- 安全解析輔助函式 ---
    double? safeDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    int safeInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return User(
      id: safeInt(json['id'], 0),
      username: json['nickname'] as String?
          ?? json['username'] as String?
          ?? '未知使用者',
      email: json['email'] as String? ?? '',
      registeredAt: json['registered_at'] != null ? DateTime.parse(json['registered_at'] as String) : DateTime.now(),
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: _prefixUrl(json['avatar_url'] as String?),
      lastLoginAt: json['last_login_at'] != null ? DateTime.parse(json['last_login_at'] as String) : null,
      bio: json['bio'] as String?,
      schoolName: json['school_name'] as String?,
      address: json['address'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ?? ['user'],
      isSeller: json['is_seller'] as bool? ?? false,
      sellerName: json['seller_name'] as String?,
      sellerDescription: json['seller_description'] as String?,

      // --- [修正重點] 使用 safeDouble ---
      sellerRating: safeDouble(json['seller_rating']),
      buyerRating: safeDouble(json['buyer_rating']),
      productCount: safeInt(json['product_count'], 0),

      favoriteProductIds: (json['favorite_product_ids'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      publicDisplayName: json['public_display_name'] as String?,
      publicBio: json['public_bio'] as String?,
      publicCoverPhotoUrl: json['public_cover_photo_url'] as String?,
      isSchoolPublic: json['is_school_public'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);

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
    String? address,
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
      address: address ?? this.address,
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

String? _prefixUrl(String? relativeUrl) {
  if (relativeUrl == null || relativeUrl.isEmpty) {
    return null;
  }
  if (relativeUrl.startsWith('http')) {
    return relativeUrl;
  }
  return '${APIConfig.baseUrl}$relativeUrl';
}