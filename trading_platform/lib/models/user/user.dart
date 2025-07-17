class User {
  // --- 修正：後端 ID 是整數 (int) ---
  final int id;
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
  final bool? isSeller; // 是否是賣家 (nullable)
  final String? sellerName; // 賣家名稱 (nullable)
  final String? sellerDescription; // 賣家簡介 (nullable)
  final double? sellerRating; // 賣家評分 (nullable)
  final double? buyerRating; // 新增：買家評價
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
    required this.isVerified,
    required this.roles,

    // 初始化賣家相關屬性
    required this.isSeller,
    this.sellerName,
    this.sellerDescription,
    this.sellerRating,
    this.buyerRating,
    required this.productCount,
  });

  // --- 修正：工廠方法，使其更健壯 ---
  factory User.fromJson(Map<String, dynamic> json) {
    // 輔助函式，安全地解析 double
    double? parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return User(
      // 確保 id 是 int
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      registeredAt: DateTime.parse(json['registered_at'] as String),
      lastLoginAt: json['last_login_at'] != null ? DateTime.parse(json['last_login_at'] as String) : null,
      bio: json['bio'] as String?,
      schoolName: json['school_name'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isSeller: json['is_seller'] as bool? ?? false,
      sellerName: json['seller_name'] as String?,
      sellerDescription: json['seller_description'] as String?,
      sellerRating: parseDouble(json['seller_rating']),
      buyerRating: parseDouble(json['buyer_rating']),
      productCount: json['product_count'] as int? ?? 0,
    );
  }

  // --- 新增：copyWith 方法，方便更新狀態 ---
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
    );
  }
}
