import '../config/api_config.dart';
import '../models/user/wishlist_item.dart';
import 'package:first_flutter_project/mock/mock.dart';
import 'api_client.dart';

class WishlistService {
  final ApiClient _apiClient;
  WishlistService(this._apiClient);

  /// 獲取我的收藏清單
  Future<List<WishlistItem>> getMyWishlist() async {
    if (APIConfig.useMock) {
      final mockProducts = buildMockProductsForUser("mock_wishlist_user", count: 5);
      return mockProducts.map((p) {
        return WishlistItem(
          id: p.id, // 用商品 id 當假收藏 id
          userId: 999,
          productId: p.id,
          createdAt: DateTime.now().subtract(Duration(days: p.id % 5)),
          product: p,
        );
      }).toList();
    }

    final responseBody = await _apiClient.get('/wishlist');
    final List<dynamic> itemsJson = responseBody;
    return itemsJson.map((json) => WishlistItem.fromJson(json)).toList();
  }

  /// 加入收藏
  Future<WishlistItem> addItem(int productId) async {
    if (APIConfig.useMock) {
      final mockProduct = buildMockProductsForUser("mock_add", count: 1).first;
      return WishlistItem(
        id: mockProduct.id,
        userId: 999,
        productId: mockProduct.id,
        createdAt: DateTime.now(),
        product: mockProduct,
      );
    }

    final responseBody = await _apiClient.post(
      '/wishlist',
      body: {'product_id': productId},
    );
    return WishlistItem.fromJson(responseBody);
  }

  /// 移除收藏
  Future<void> removeItemByProductId(int productId) async {
    if (APIConfig.useMock) {
      // mock 模式直接 return
      return;
    }
    await _apiClient.delete('/wishlist/$productId');
  }
}
