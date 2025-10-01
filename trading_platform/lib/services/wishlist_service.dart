// --- FILE: lib/services/wishlist_service.dart ---
import 'package:flutter/foundation.dart';
import '../models/user/wishlist_item.dart';
import 'api_client.dart';

class WishlistService {
  final ApiClient _apiClient;
  WishlistService(this._apiClient);

  /// 獲取使用者的完整收藏清單
  Future<List<WishlistItem>> getWishlistItems() async {
    debugPrint('[WishlistService] API: Getting wishlist items...');
    final responseBody = await _apiClient.get('/wishlist');
    final List<dynamic> itemsJson = responseBody;
    final items = itemsJson.map((json) => WishlistItem.fromJson(json)).toList();
    debugPrint('[WishlistService] API: Fetched ${items.length} wishlist items.');
    return items;
  }

  /// 將商品加入收藏清單
  Future<WishlistItem> addToWishlist(int productId) async {
    debugPrint('[WishlistService] API: Adding product #$productId to wishlist...');
    final responseBody = await _apiClient.post(
      '/wishlist/items', // API 路徑與組員版本一致
      body: {'product_id': productId},
    );
    final item = WishlistItem.fromJson(responseBody);
    debugPrint('[WishlistService] API: Successfully added product #${item.productId}.');
    return item;
  }

  /// --- 關鍵修正：統一方法名稱 ---
  /// 從收藏清單中移除商品
  Future<void> removeFromWishlist(int productId) async {
    debugPrint('[WishlistService] API: Removing product #$productId from wishlist...');
    // API 路徑與組員版本一致
    await _apiClient.delete('/wishlist//items/$productId');
    debugPrint('[WishlistService] API: Successfully removed product #$productId.');
  }
}