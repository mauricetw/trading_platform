import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user/cart_item.dart';
// 假設您有一個全局的 API 配置或用戶 token 管理器
import '../config/api_config.dart';
import 'auth_service.dart';

class CartService {
  final String _apiBaseUrl = APIConfig.baseUrl; // 從您的 API 配置中獲取
  final AuthService _authService; // 假設您有一個 AuthService 來獲取 token

  CartService(this._authService);

  // 輔助方法：獲取認證頭
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getUserToken(); // 假設 AuthService 提供獲取 token 的方法
    if (token == null) {
      // 如果沒有 token，可以拋出異常或返回一個指示未認證的狀態
      throw Exception('User not authenticated');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  /// 從後端獲取指定用戶的購物車列表
  Future<List<CartItem>> fetchCartItems(String userId) async {
    // 【【注意】】後端 API 端點 `/users/{userId}/cart` 僅為示例，請替換為您的實際端點
    final url = Uri.parse('$_apiBaseUrl/users/$userId/cart');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData.map((data) => CartItem.fromJson(data)).toList();
      } else if (response.statusCode == 404) {
        // 購物車為空或用戶不存在，返回空列表
        return [];
      } else {
        // 處理其他錯誤情況
        print('Failed to load cart items: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load cart items: ${response.body}');
      }
    } catch (error) {
      print('Error fetching cart items: $error');
      throw Exception('Error fetching cart items: $error');
    }
  }

  /// 將商品添加到後端購物車
  /// 返回後端創建的 CartItem (可能包含後端生成的 id)
  Future<CartItem> addItemToCart(String userId, String productId, int quantity) async {
    // 【【注意】】後端 API 端點 `/users/{userId}/cart` 僅為示例
    final url = Uri.parse('$_apiBaseUrl/users/$userId/cart');
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'productId': productId,
        'quantity': quantity,
        // 後端可能需要其他信息，例如商品快照 (如果後端不自己處理)
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) { // 201 Created or 200 OK (如果更新數量)
        return CartItem.fromJson(json.decode(response.body));
      } else {
        print('Failed to add item to cart: ${response.statusCode} ${response.body}');
        throw Exception('Failed to add item to cart: ${response.body}');
      }
    } catch (error) {
      print('Error adding item to cart: $error');
      throw Exception('Error adding item to cart: $error');
    }
  }

  /// 更新後端購物車中商品的數量
  /// [cartItemId] 是後端數據庫中購物車項目的唯一 ID，或者使用 productId 如果後端這樣設計
  Future<CartItem> updateCartItemQuantity(String userId, String cartItemIdOrProductId, int newQuantity) async {
    // 【【注意】】端點示例: /users/{userId}/cart/{cartItemIdOrProductId}
    final url = Uri.parse('$_apiBaseUrl/users/$userId/cart/$cartItemIdOrProductId');
    try {
      final headers = await _getHeaders();
      final body = json.encode({'quantity': newQuantity});

      final response = await http.put(url, headers: headers, body: body); // 或 PATCH

      if (response.statusCode == 200) {
        return CartItem.fromJson(json.decode(response.body));
      } else {
        print('Failed to update cart item quantity: ${response.statusCode} ${response.body}');
        throw Exception('Failed to update cart item quantity: ${response.body}');
      }
    } catch (error) {
      print('Error updating cart item quantity: $error');
      throw Exception('Error updating cart item quantity: $error');
    }
  }

  /// 從後端購物車中移除商品
  /// [cartItemId] 是後端數據庫中購物車項目的唯一 ID，或者使用 productId
  Future<void> removeItemFromCart(String userId, String cartItemIdOrProductId) async {
    // 【【注意】】端點示例: /users/{userId}/cart/{cartItemIdOrProductId}
    final url = Uri.parse('$_apiBaseUrl/users/$userId/cart/$cartItemIdOrProductId');
    try {
      final headers = await _getHeaders();
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 204 || response.statusCode == 200) { // 204 No Content or 200 OK
        // 成功移除
        return;
      } else {
        print('Failed to remove item from cart: ${response.statusCode} ${response.body}');
        throw Exception('Failed to remove item from cart: ${response.body}');
      }
    } catch (error) {
      print('Error removing item from cart: $error');
      throw Exception('Error removing item from cart: $error');
    }
  }

  /// 清空後端指定用戶的購物車
  Future<void> clearRemoteCart(String userId) async {
    // 【【注意】】端點示例: /users/{userId}/cart/clear 或 DELETE /users/{userId}/cart
    final url = Uri.parse('$_apiBaseUrl/users/$userId/cart/clear'); // 或直接 DELETE 到 /cart
    try {
      final headers = await _getHeaders();
      // 通常清空是 POST 到一個特定端點或 DELETE 到集合端點
      final response = await http.post(url, headers: headers); // 或者 http.delete

      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      } else {
        print('Failed to clear remote cart: ${response.statusCode} ${response.body}');
        throw Exception('Failed to clear remote cart: ${response.body}');
      }
    } catch (error) {
      print('Error clearing remote cart: $error');
      throw Exception('Error clearing remote cart: $error');
    }
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
