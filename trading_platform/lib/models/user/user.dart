import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  final String id;
  final String username; // 內部用戶名，也可以作為公開顯示名稱的默認值
  final String email;    // 私密信息，不公開
  final String? phoneNumber; // 私密信息，不公開
  final String? avatarUrl;   // 可用於公開頭像的默認值
  final DateTime registeredAt;
  final DateTime? lastLoginAt;
  final String? bio;         // 現有的 bio 可以作為“私有”的筆記或草稿
  final String? schoolName;  // 現有學校名稱
  final bool? isVerified;
  final List<String>? roles;

  // 賣家相關屬性 (這些可能部分公開，部分用於內部)
  @JsonKey(defaultValue: false)
  final bool? isSeller;
  final String? sellerName; // 如果 isSeller 為 true，這個可以作為店鋪名/賣家名
  final String? sellerDescription; // 店鋪描述
  final double? sellerRating;
  final int? productCount;

  @JsonKey(defaultValue: [])
  final List<String> favoriteProductIds;

  // --- 新增：專用於公開資訊的字段 ---
  @JsonKey(name: 'public_display_name') // 建議使用 snake_case 與 json 保持一致
  final String? publicDisplayName;      // 公開顯示的名稱 (如果用戶想不同於 username)

  @JsonKey(name: 'public_bio')
  final String? publicBio;              // 公開的個人簡介

  @JsonKey(name: 'public_cover_photo_url')
  final String? publicCoverPhotoUrl;    // 公開的封面圖片 URL

  @JsonKey(name: 'is_school_public', defaultValue: false) // 默認不公開學校
  final bool isSchoolPublic;

  // 可以根據需要添加更多，例如：
  // final String? publicLocation;
  // final Map<String, String>? publicSocialLinks;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.registeredAt,
    this.phoneNumber,
    this.avatarUrl,
    this.lastLoginAt,
    this.bio, // 這是用戶自己的 bio，可能不直接公開
    this.schoolName,
    this.isVerified,
    this.roles,
    this.isSeller = false,
    this.sellerName,
    this.sellerDescription,
    this.sellerRating,
    this.productCount,
    this.favoriteProductIds = const [],
    // 初始化新增的公開信息字段
    this.publicDisplayName,
    this.publicBio,
    this.publicCoverPhotoUrl,
    this.isSchoolPublic = false, // 默認值
  });

  User copyWith({
    String? id,
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
    int? productCount,
    List<String>? favoriteProductIds,
    // 為新增字段添加 copyWith 支持
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
      productCount: productCount ?? this.productCount,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      // 複製新增字段
      publicDisplayName: publicDisplayName ?? this.publicDisplayName,
      publicBio: publicBio ?? this.publicBio,
      publicCoverPhotoUrl: publicCoverPhotoUrl ?? this.publicCoverPhotoUrl,
      isSchoolPublic: isSchoolPublic ?? this.isSchoolPublic,
    );
  }

  // Helper getter，方便在 UI 中使用，如果 publicDisplayName 未設置，則回退到 username
  String get effectivePublicDisplayName => publicDisplayName?.isNotEmpty == true ? publicDisplayName! : username;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.avatarUrl == avatarUrl &&
        other.registeredAt == registeredAt &&
        other.lastLoginAt == lastLoginAt &&
        other.bio == bio &&
        other.schoolName == schoolName &&
        other.isVerified == isVerified &&
        _listEquals(other.roles, roles) &&
        other.isSeller == isSeller &&
        other.sellerName == sellerName &&
        other.sellerDescription == sellerDescription &&
        other.sellerRating == sellerRating &&
        other.productCount == productCount &&
        _listEquals(other.favoriteProductIds, favoriteProductIds) &&
        // 比較新增字段
        other.publicDisplayName == publicDisplayName &&
        other.publicBio == publicBio &&
        other.publicCoverPhotoUrl == publicCoverPhotoUrl &&
        other.isSchoolPublic == isSchoolPublic;
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    // ... (您的 _listEquals 方法不變)
    if (a == null && b == null) return true;
    if (a == null || b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    if (a.isEmpty && b.isEmpty) return true;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }


  @override
  int get hashCode {
    // ... (您現有的 hashCode 計算)
    // 為新增字段添加哈希碼
    final int publicDisplayNameHash = publicDisplayName?.hashCode ?? 0;
    final int publicBioHash = publicBio?.hashCode ?? 0;
    final int publicCoverPhotoUrlHash = publicCoverPhotoUrl?.hashCode ?? 0;
    final int isSchoolPublicHash = isSchoolPublic.hashCode; // bool 可以直接 hashCode

    return id.hashCode ^
    username.hashCode ^
    email.hashCode ^
    (phoneNumber?.hashCode ?? 0) ^
    (avatarUrl?.hashCode ?? 0) ^
    registeredAt.hashCode ^
    (lastLoginAt?.hashCode ?? 0) ^
    (bio?.hashCode ?? 0) ^
    (schoolName?.hashCode ?? 0) ^
    (isVerified?.hashCode ?? 0) ^
    // (roles 的哈希碼計算) - 您已經有了
    (_calculateRolesHash()) ^ // 假設您有一個方法或直接計算 roles 哈希
    (isSeller?.hashCode ?? 0) ^
    (sellerName?.hashCode ?? 0) ^
    (sellerDescription?.hashCode ?? 0) ^
    (sellerRating?.hashCode ?? 0) ^
    (productCount?.hashCode ?? 0) ^
    // (favoriteProductIds 的哈希碼計算) - 您已經有了
    (_calculateListHash(favoriteProductIds)) ^ // 假設您有一個方法或直接計算列表哈希
    publicDisplayNameHash ^
    publicBioHash ^
    publicCoverPhotoUrlHash ^
    isSchoolPublicHash;
  }

  // 輔助方法來計算 roles 的哈希碼 (如果您的版本中沒有)
  int _calculateRolesHash() {
    if (roles == null || roles!.isEmpty) return 0;
    int hash = 17;
    for (final role in roles!) {
      hash = hash * 31 + role.hashCode;
    }
    return hash;
  }
  // 輔助方法來計算列表的哈希碼 (如果您的版本中沒有)
  int _calculateListHash<T>(List<T>? list) {
    if (list == null || list.isEmpty) return 0;
    int hash = 19;
    for (final item in list) {
      hash = hash * 31 + item.hashCode;
    }
    return hash;
  }


  @override
  String toString() {
    // 可以考慮在 toString 中也加入新的公開信息字段，方便調試
    return 'User(id: $id, username: $username, publicDisplayName: $publicDisplayName, email: $email, isSeller: $isSeller, sellerName: $sellerName, isSchoolPublic: $isSchoolPublic)';
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
