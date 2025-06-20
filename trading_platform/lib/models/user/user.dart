// lib/models/user/user.dart
import 'package:json_annotation/json_annotation.dart';

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
  @JsonKey(defaultValue: false) // json_serializable 的默認值
  final bool? isSeller; // 是否是賣家 (nullable)
  final String? sellerName; // 賣家名稱 (nullable)
  final String? sellerDescription; // 賣家簡介 (nullable)
  final double? sellerRating; // 賣家評分 (nullable)
  final int? productCount; // 賣家上架的商品數量 (nullable)
  // 可以添加其他賣家相關屬性，例如：賣家店鋪圖片、營業時間等

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.registeredAt,
    this.lastLoginAt,
    this.bio,
    this.schoolName,
    this.isVerified,
    this.roles,
    // 初始化賣家相關屬性
    this.isSeller = false, // 構造函數中的默認值
    this.sellerName,
    this.sellerDescription,
    this.sellerRating,
    this.productCount,
  });

  // --- 手動實現部分 (如果需要) ---

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
        // listEquals(other.roles, roles) && // 使用 collection 包比較列表
        _listEquals(other.roles, roles) && // 或者簡單的私有比較函數
        other.isSeller == isSeller &&
        other.sellerName == sellerName &&
        other.sellerDescription == sellerDescription &&
        other.sellerRating == sellerRating &&
        other.productCount == productCount;
  }

  // 輔助函數比較列表 (如果不想引入 collection 包)
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (a.isEmpty && b.isEmpty) return true; // 都為空列表也算相等
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  @override
  int get hashCode {
    final int phoneNumberHash = phoneNumber?.hashCode ?? 0;
    final int avatarUrlHash = avatarUrl?.hashCode ?? 0;
    final int lastLoginAtHash = lastLoginAt?.hashCode ?? 0;
    final int bioHash = bio?.hashCode ?? 0;
    final int schoolNameHash = schoolName?.hashCode ?? 0;
    final int isVerifiedHash = isVerified?.hashCode ?? 0;

    int rolesCombinedHash = 17; // Start with a prime number
    if (roles != null) {
      for (final role in roles!) { // roles! is safe here due to the null check
        rolesCombinedHash = rolesCombinedHash * 31 + role.hashCode;
      }
    } else {
      rolesCombinedHash = 0; // Or some other consistent value for null list
    }

    final int isSellerHash = isSeller?.hashCode ?? 0;
    final int sellerNameHash = sellerName?.hashCode ?? 0;
    final int sellerDescriptionHash = sellerDescription?.hashCode ?? 0;
    final int sellerRatingHash = sellerRating?.hashCode ?? 0;
    final int productCountHash = productCount?.hashCode ?? 0;

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
    rolesCombinedHash ^ // 使用組合後的哈希
    isSellerHash ^
    sellerNameHash ^
    sellerDescriptionHash ^
    sellerRatingHash ^
    productCountHash;
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, isSeller: $isSeller, sellerName: $sellerName)';
    // 自定義 toString 以便調試
  }

  // --- 由 json_serializable 生成 ---
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}