// --- FILE: lib/services/cart_service.dart ---
import '../models/user/cart_item.dart';
import 'api_client.dart';

class CartService {
  final ApiClient _apiClient;
  // CartService 依賴於 ApiClient 來完成所有網路請求
  CartService(this._apiClient);

  /// 從後端獲取當前登入使用者的購物車列表。
  ///
  /// 此方法會呼叫後端的 `GET /cart` 端點。
  /// 成功時回傳一個 `List<CartItem>`，每個項目都包含完整的商品資訊。
  Future<List<CartItem>> fetchCartItems() async {
    // 呼叫 ApiClient 的 get 方法，路徑與後端 router 一致
    final responseBody = await _apiClient.get('/cart');

    // ApiClient 會自動處理錯誤和 JSON 解析，我們只需要處理型別轉換
    final List<dynamic> itemsJson = responseBody;
    return itemsJson.map((json) => CartItem.fromJson(json)).toList();
  }

  /// 將商品添加到後端購物車。
  ///
  /// 此方法會呼叫後端的 `POST /cart` 端點。
  /// [productId] 是要加入的商品 ID，[quantity] 是要加入的數量。
  /// 成功時回傳後端更新或建立的 `CartItem` 物件。
  Future<CartItem> addItemToCart(int productId, int quantity) async {
    // 請求的 body 格式與後端 CartItemCreate schema 一致
    final responseBody = await _apiClient.post(
      '/cart',
      body: {
        'product_id': productId,
        'quantity': quantity
      },
    );
    return CartItem.fromJson(responseBody);
  }

  /// 更新後端購物車中商品的數量。
  ///
  /// 此方法會呼叫後端的 `PUT /cart/{product_id}` 端點。
  /// [productId] 是要更新的商品 ID，[newQuantity] 是新的數量。
  /// 成功時回傳更新後的 `CartItem` 物件。
  Future<CartItem> updateCartItemQuantity(int productId, int newQuantity) async {
    // 請求的 body 格式與後端 CartItemUpdate schema 一致
    final responseBody = await _apiClient.put(
      '/cart/$productId',
      body: {'quantity': newQuantity},
    );
    return CartItem.fromJson(responseBody);
  }

  /// 從後端購物車中移除商品。
  ///
  /// 此方法會呼叫後端的 `DELETE /cart/{product_id}` 端點。
  /// [productId] 是要移除的商品 ID。
  Future<void> removeItemFromCart(int productId) async {
    // 將 productId 放在 URL 路徑中，與後端 router 一致
    await _apiClient.delete('/cart/$productId');
  }

  /// 清空後端當前用戶的購物車。
  ///
  /// 此方法會呼叫後端的 `DELETE /cart` 端點。
  Future<void> clearRemoteCart() async {
    await _apiClient.delete('/cart');
  }

// --- 選項：批量同步購物車 ---
// 如果您的後端支持一次性發送整個購物車狀態（例如，在用戶登錄後或網絡恢復時）
// Future<List<CartItem>> syncCartWithBackend(String userId, List<CartItem> localCartItems) async {
//   final url = Uri.parse('$_apiBaseUrl/users/$userId/cart/sync'); // 示例端點
//   try {
//     final headers = await _getHeaders();
//     // 將 localCartItems 轉換為後端期望的格式
//     final body = json.encode(localCartItems.map((item) => item.toJson()).toList());
//
//     final response = await http.post(url, headers: headers, body: body);
//
//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = json.decode(response.body);
//       return responseData.map((data) => CartItem.fromJson(data)).toList();
//     } else {
//       print('Failed to sync cart: ${response.statusCode} ${response.body}');
//       throw Exception('Failed to sync cart: ${response.body}');
//     }
//   } catch (error) {
//     print('Error syncing cart: $error');
//     throw Exception('Error syncing cart: $error');
//   }
// }
}
