// lib/models/user/user.dart
import 'package:json_annotation/json_annotation.dart';
// 如果您不打算使用 collection 包的 ListEquality，可以移除下面這行
// import 'package:collection/collection.dart'; // 用於 ListEquality

part 'user.g.dart'; // 需要這一行來鏈接生成的代碼

@JsonSerializable(explicitToJson: true) // explicitToJson 如果有嵌套類需要調用 toJson
class User {
  final String id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl; // 大頭貼 URL (nullable)
  final DateTime registeredAt;
  final DateTime? lastLoginAt; // 最後登入時間 (nullable)
  final String? bio; // 簡介 (nullable)
  final String? schoolName; // 校名 (nullable)
  final bool? isVerified; // 是否已驗證 (nullable)
  final List<String>? roles; // 權限/角色 (nullable)

  // 新增賣家相關屬性
  @JsonKey(defaultValue: false)
  final bool? isSeller;
  final String? sellerName;
  final String? sellerDescription;
  final double? sellerRating;
  final int? productCount;

  // 新增：用戶收藏的商品 ID 列表
  @JsonKey(defaultValue: []) // 如果 json 中沒有這個字段，默認為空列表
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
    this.isVerified,
    this.roles,
    this.isSeller = false,
    this.sellerName,
    this.sellerDescription,
    this.sellerRating,
    this.productCount,
    this.favoriteProductIds = const [], // 構造函數中的默認值
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
    List<String>? favoriteProductIds, // 添加 favoriteProductIds
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
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds, // 複製 favoriteProductIds
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    // final listEquals = const DeepCollectionEquality().equals; // 需要 collection 包

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
        _listEquals(other.favoriteProductIds, favoriteProductIds); // 比較 favoriteProductIds
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null || a.length != b.length) return false;
    if (identical(a, b)) return true; // 同一個實例
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
    final int phoneNumberHash = phoneNumber?.hashCode ?? 0;
    final int avatarUrlHash = avatarUrl?.hashCode ?? 0;
    final int lastLoginAtHash = lastLoginAt?.hashCode ?? 0;
    final int bioHash = bio?.hashCode ?? 0;
    final int schoolNameHash = schoolName?.hashCode ?? 0;
    final int isVerifiedHash = isVerified?.hashCode ?? 0;

    int rolesCombinedHash = 17;
    if (roles != null && roles!.isNotEmpty) {
      for (final role in roles!) {
        rolesCombinedHash = rolesCombinedHash * 31 + role.hashCode;
      }
    } else {
      rolesCombinedHash = 0;
    }

    final int isSellerHash = isSeller?.hashCode ?? 0;
    final int sellerNameHash = sellerName?.hashCode ?? 0;
    final int sellerDescriptionHash = sellerDescription?.hashCode ?? 0;
    final int sellerRatingHash = sellerRating?.hashCode ?? 0;
    final int productCountHash = productCount?.hashCode ?? 0;

    // 為 favoriteProductIds 生成哈希碼
    // 使用 collection 包的 ListEquality().hash(favoriteProductIds) 更健壯
    // 手動實現一個簡單版本：
    int favoriteProductIdsHash = 19; // 另一個質數
    if (favoriteProductIds.isNotEmpty) {
      for (final id in favoriteProductIds) {
        favoriteProductIdsHash = favoriteProductIdsHash * 31 + id.hashCode;
      }
    } else {
      favoriteProductIdsHash = 0;
    }


    return id.hashCode ^
    username.hashCode ^
    email.hashCode ^
    phoneNumberHash ^
    avatarUrlHash ^
    registeredAt.hashCode ^
    lastLoginAtHash ^
    bioHash ^
    schoolNameHash ^
    isVerifiedHash ^
    rolesCombinedHash ^
    isSellerHash ^
    sellerNameHash ^
    sellerDescriptionHash ^
    sellerRatingHash ^
    productCountHash ^
    favoriteProductIdsHash; // 添加 favoriteProductIds 的哈希碼
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, isSeller: $isSeller, sellerName: $sellerName, favoriteProductIdsCount: ${favoriteProductIds.length})';
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
