import '../product/product.dart'; // 假設你需要引用 Product Model

class WishlistItem {
  final String id; // 收藏項目的唯一 ID
  final String userId; // 收藏該商品的用戶 ID
  final String productId; // 被收藏的商品 ID

  // 可選：直接包含商品的部分或全部信息，以避免額外查找
  // 這樣做的好處是在顯示收藏列表時可以直接使用，不用額外查 Product
  // 但如果商品信息變動頻繁，這裡的信息可能會過期，需要權衡
  // final Product product; // 包含 Product 對象引用

  // 可選：記錄收藏時間
  final DateTime createdAt;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    // this.product,
    required this.createdAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      // 如果 JSON 包含商品資訊，解析 Product
      // product: json['product'] != null ? Product.fromJson(json['product'] as Map<String, dynamic>) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      // 如果包含 Product，也需要轉換為 JSON
      // 'product': product?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}