//使用者對商品或賣家的評價。
// 屬性可能包含：評價 ID、商品 ID、訂單 ID、買家 ID、賣家 ID、評分（星級）、評價內容、評價圖片、 評價時間、 回覆內容（ 賣家回覆） 、 回覆時間等。
// 如果你需要引用 User Model 或 Product Model，請導入它們
// import '../user/user.dart';
// import 'product.dart';

class Review {
  final String id; // 評價 ID
  final String productId; // 商品 ID
  final String? orderId; // 訂單 ID (可能一個訂單有多個商品評價)
  final String buyerId; // 買家 ID
  final String sellerId; // 賣家 ID
  final double rating; // 評分 (星級，例如 1.0 到 5.0)
  final String? content; // 評價內容 (可選)
  final List<String>? imageUrls; // 評價圖片的 URL 列表 (可選)
  final DateTime createdAt; // 評價時間

  // 賣家回覆相關屬性 (可選)
  final String? replyContent; // 回覆內容
  final DateTime? repliedAt; // 回覆時間

  // 可選：包含買家和賣家的基本資訊快照，方便顯示
  // final String buyerUsername;
  // final String sellerUsername;


  Review({
    required this.id,
    required this.productId,
    this.orderId, // 訂單 ID 可選
    required this.buyerId,
    required this.sellerId,
    required this.rating,
    this.content, // 評價內容可選
    this.imageUrls, // 評價圖片可選
    required this.createdAt,
    this.replyContent, // 回覆內容可選
    this.repliedAt, // 回覆時間可選
    // this.buyerUsername,
    // this.sellerUsername,
  });

  // 從 JSON 創建 Review 物件
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      productId: json['productId'] as String,
      orderId: json['orderId'] as String?,
      // JSON 中的 orderId 可能為 null
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      rating: (json['rating'] as num).toDouble(),
      // JSON 中的數字通常是 num 類型，需要轉為 double
      content: json['content'] as String?,
      // JSON 中的 content 可能為 null
      // 解析圖片 URL 列表
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((url) => url as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      // 解析時間字串
      replyContent: json['replyContent'] as String?,
      // JSON 中的 replyContent 可能為 null
      // 解析回覆時間字串，如果為 null 則保持 null
      repliedAt: json['repliedAt'] != null
          ? DateTime.parse(json['repliedAt'] as String)
          : null,
      // buyerUsername: json['buyerUsername'] as String?,
      // sellerUsername: json['sellerUsername'] as String?,
    );
  }

  // 將 Review 物件轉換為 JSON (用於發佈評價或回覆評價)
  Map<String, dynamic> toJson() {
    return {
      // 發佈評價時可能不需要 id，由後端生成
      // 'id': id,
      'productId': productId,
      'orderId': orderId,
      'buyerId': buyerId, // 後端可能根據登入用戶自動設置
      'sellerId': sellerId, // 後端可能根據商品信息自動設置
      'rating': rating,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(), // 將時間格式化為 ISO 8601 字串

      // 只有在回覆評價時才需要包含這些
      'replyContent': replyContent,
      'repliedAt': repliedAt?.toIso8601String(), // 如果 repliedAt 不為 null 才格式化
    };
  }
}