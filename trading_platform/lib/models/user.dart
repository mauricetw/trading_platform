class User {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl; // 大頭貼 URL (nullable)
  final DateTime registeredAt;
  final DateTime? lastLoginAt; // 最後登入時間 (nullable)
  final String? bio; // 簡介 (nullable)
  final String? schoolName; // 校名 (nullable)
  final bool? isVerified; // 是否已驗證 (nullable)
  final List<String>? roles; // 權限/角色 (nullable)
  // 新增賣家相關屬性
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
    this.avatarUrl,
    required this.registeredAt,
    this.lastLoginAt,
    this.bio,
    this.schoolName,
    this.isVerified,
    this.roles,
    // 初始化賣家相關屬性
    this.isSeller = false, // 預設不是賣家
    this.sellerName,
    this.sellerDescription,
    this.sellerRating,
    this.productCount,
  });

  // 為了方便測試，添加一個 fromJson 方法
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt'] as String) : null,
      bio: json['bio'] as String?,
      schoolName: json['schoolName'] as String?,
      isVerified: json['isVerified'] as bool?,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
      // 解析賣家相關屬性
      isSeller: json['isSeller'] as bool? ?? false, // 如果 isSeller 為 null，預設為 false
      sellerName: json['sellerName'] as String?,
      sellerDescription: json['sellerDescription'] as String?,
      sellerRating: json['sellerRating'] as double?,
      productCount: json['productCount'] as int?,
    );
  }
}
