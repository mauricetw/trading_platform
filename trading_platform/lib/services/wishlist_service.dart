// --- FILE: lib/services/wishlist_service.dart ---
import '../models/user/wishlist_item.dart';
import 'api_client.dart';

class WishlistService {
  final ApiClient _apiClient;
  // WishlistService 依賴於 ApiClient 來完成所有網路請求
  WishlistService(this._apiClient);

  /// 獲取當前登入使用者的完整收藏清單。
  ///
  /// 此方法會呼叫後端的 `GET /wishlist` 端點。
  /// 成功時回傳一個 `List<WishlistItem>`。
  /// 每個 WishlistItem 都會包含完整的商品資訊。
  Future<List<WishlistItem>> getMyWishlist() async {
    // 呼叫 ApiClient 的 get 方法，路徑與後端 router 一致
    final responseBody = await _apiClient.get('/wishlist');

    // ApiClient 會自動處理錯誤和 JSON 解析，我們只需要處理型別轉換
    final List<dynamic> itemsJson = responseBody;
    return itemsJson.map((json) => WishlistItem.fromJson(json)).toList();
  }

  /// 將一件商品加入到當前使用者的收藏清單。
  ///
  /// 此方法會呼叫後端的 `POST /wishlist` 端點。
  /// [productId] 是要收藏的商品 ID。
  /// 成功時回傳後端新建立的 `WishlistItem` 物件。
  Future<WishlistItem> addItem(int productId) async {
    // 請求的 body 格式與後端 WishlistItemCreate schema 一致
    final responseBody = await _apiClient.post(
      '/wishlist',
      body: {'product_id': productId},
    );
    return WishlistItem.fromJson(responseBody);
  }

  /// 從當前使用者的收藏清單中移除一件商品。
  ///
  /// 此方法會呼叫後端的 `DELETE /wishlist/{product_id}` 端點。
  /// [productId] 是要移除的商品 ID。
  /// 成功時沒有回傳內容。
  Future<void> removeItemByProductId(int productId) async {
    // 將 productId 放在 URL 路徑中，與後端 router 一致
    await _apiClient.delete('/wishlist/$productId');
  }
}
