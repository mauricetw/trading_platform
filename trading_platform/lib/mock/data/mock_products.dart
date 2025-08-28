import '../../models/product/product.dart';
import '../../models/user/user.dart';
import 'mock_utils.dart';

/// 依「賣家 int id」產生一批商品（後台 / 一般用）
List<Product> generateProductsForSeller(int sellerId, {int count = 8}) {
  final now = DateTime.now();
  final sellerInfo = mockSellerInfo(sellerId);

  return List.generate(count, (i) {
    final id = makeProductId(sellerId, i);
    final sold = i % 4 == 0;

    return Product(
      id: id,
      name: '模擬商品 ${i + 1}',
      description: '這是 UI 測試用的模擬商品 ${i + 1}，由 ${sellerInfo.username} 提供。',
      price: 500 + i * 120.0,
      originalPrice: 650 + i * 140.0,
      categoryId: (i % 6) + 1,
      category: '分類 ${(i % 6) + 1}',
      stockQuantity: sold ? 0 : (i * 3 + 5),
      status: sold ? 'sold' : 'available',
      imageUrls: [
        'https://picsum.photos/seed/${id}_1/400/300',
        if (i.isEven) 'https://picsum.photos/seed/${id}_2/400/300',
      ],
      createdAt: now.subtract(Duration(days: i + 3)),
      updatedAt: now.subtract(Duration(days: i)),
      salesCount: i * 7,
      averageRating: (i % 5 == 0) ? null : 4.2,
      reviewCount: (i % 5 == 0) ? 0 : i * 2,
      tags: const ['mock', 'ui'],
      sellerId: sellerId,
      seller: sellerInfo,
      shippingInfo: null,
      isFavorite: false,
    );
  });
}

/// 依「字串 userId」產生商品（前台公開頁 / Explore 用）
/// ⚠️ 舊檔名相同的函式保留，避免你要大改呼叫點
List<Product> buildMockProductsForUser(String userId, {int count = 8}) {
  final seller = buildMockSellerInfoForUser(userId);
  final now = DateTime.now();

  return List<Product>.generate(count, (index) {
    final base = stableIntIdFromUserId('$userId-$index');
    final isSold = index % 4 == 0;

    return Product(
      id: base,
      name: '用戶精選商品 ${index + 1}',
      description:
      '這是一款高品質的用戶精選商品 ${index + 1}，由 ${seller.username} 精心提供。純測試資料。',
      price: ((userId.hashCode % 1500) + 500 + index * 150).toDouble(),
      originalPrice: ((userId.hashCode % 1500) + 700 + index * 170).toDouble(),
      categoryId: (index % 5) + 1,
      category: '模擬分類 ${(index % 5) + 1}',
      stockQuantity: isSold ? 0 : (index * 5 + 10),
      status: isSold ? 'sold' : 'available',
      imageUrls: [
        'https://picsum.photos/seed/${base}_1/400/300',
        if (index.isEven) 'https://picsum.photos/seed/${base}_2/400/300',
        if (index % 3 == 0) 'https://picsum.photos/seed/${base}_3/400/300',
      ],
      createdAt: now.subtract(Duration(days: index + 5, hours: index * 2)),
      updatedAt: now.subtract(Duration(days: index, hours: index)),
      salesCount: isSold ? (index * 10 + 15) : (index * 10 + 5),
      averageRating:
      (index % 5 == 0) ? null : (((index % 40) + 10) / 10.0).clamp(3.0, 5.0),
      reviewCount: (index % 5 == 0) ? 0 : (index * 5 + 3),
      tags: (index % 3 == 0) ? ['熱銷', '店長推薦'] : ['新品上架', '特價'],
      sellerId: seller.id,
      seller: seller,
      shippingInfo: null,
    );
  });
}

/// 後台「我的商品」頁面產生資料（保持你原有的 API）
List<Product> generateMockSellerProducts(User currentUser, {int count = 5}) {
  final now = DateTime.now();

  return List<Product>.generate(count, (index) {
    final id = (currentUser.id * 100) + index;
    final isSoldOut = index == 3;

    return Product(
      id: id,
      name: '我的商品 ${index + 1}',
      description: '這是商品 ${index + 1} 的詳細描述，純測試資料。',
      price: (index + 1) * 199.99 + 50,
      originalPrice: (index + 1) * 299.99 + 100,
      categoryId: index + 1,
      category: index % 2 == 0 ? '電子產品' : '家居用品',
      stockQuantity: isSoldOut ? 0 : 10 + index * 5,
      status: isSoldOut ? 'sold_out' : (index % 2 == 0 ? 'available' : 'unavailable'),
      imageUrls: [
        'https://picsum.photos/seed/seller_${currentUser.id}_$index/200/200',
      ],
      createdAt: now.subtract(Duration(days: index)),
      updatedAt: now.subtract(Duration(hours: index)),
      sellerId: currentUser.id,
      salesCount: index * 5,
      averageRating: index % 2 == 0 ? 4.5 - index * 0.1 : null,
      reviewCount: index * 3,
      tags: [
        index % 3 == 0 ? '全新' : (index % 3 == 1 ? '近全新' : '良好'),
        index % 2 == 0 ? '一般商品' : '限時特價',
      ],
      seller: null,
      shippingInfo: null,
    );
  });
}

/// 合併後仍提供這些輔助
List<Product> mockAllProducts() => [
  ...generateProductsForSeller(101, count: 6),
  ...generateProductsForSeller(202, count: 6),
];

Product findMockProductById(int productId) {
  final all = mockAllProducts();
  return all.firstWhere(
        (e) => e.id == productId,
    orElse: () => throw Exception('Product $productId not found (mock)'),
  );
}
