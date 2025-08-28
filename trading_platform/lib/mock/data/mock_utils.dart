import '../../models/product/product.dart';

/// 將字串 userId 映成穩定的 int（避免每次重啟亂跳）
int stableIntIdFromUserId(String userId) {
  return (userId.hashCode.abs() % 900000) + 100000;
}

/// 建立賣家資訊（給 int id）
SellerInfo mockSellerInfo(int sellerId) => SellerInfo(
  id: sellerId,
  username: 'seller_$sellerId',
  avatarUrl: 'https://picsum.photos/seed/seller_$sellerId/120/120',
);

/// 建立賣家資訊（給字串 userId）
SellerInfo buildMockSellerInfoForUser(String userId) {
  final sellerId = stableIntIdFromUserId(userId);
  return mockSellerInfo(sellerId);
}

/// 依賣家 id 與索引產生穩定商品 id
int makeProductId(int sellerId, int index) => sellerId * 1000 + index;
