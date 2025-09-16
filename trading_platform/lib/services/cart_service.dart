// lib/services/cart_service.dart
import 'package:flutter/foundation.dart';
import '../models/user/cart_item.dart';
import 'api_client.dart';

class CartService {
  final ApiClient _apiClient;

  CartService(this._apiClient);

  /// 從後端獲取當前登入使用者的購物車列表。
  Future<List<CartItem>> fetchCartItems() async {
    try {
      debugPrint('CartService: Fetching cart items...');
      final responseBody = await _apiClient.get('/cart');

      // 檢查回應是否為 null 或空
      if (responseBody == null) {
        debugPrint('CartService: Received null response');
        return [];
      }

      // 確保回應是 List 型別
      if (responseBody is! List) {
        debugPrint('CartService: Unexpected response type: ${responseBody.runtimeType}');
        throw Exception('Expected List but got ${responseBody.runtimeType}');
      }

      final List<dynamic> itemsJson = responseBody;
      debugPrint('CartService: Received ${itemsJson.length} cart items');

      // 逐一解析每個項目，並捕獲個別錯誤
      final List<CartItem> cartItems = [];
      for (int i = 0; i < itemsJson.length; i++) {
        try {
          final itemJson = itemsJson[i];
          if (itemJson is Map<String, dynamic>) {
            final cartItem = CartItem.fromJson(itemJson);
            cartItems.add(cartItem);
          } else {
            debugPrint('CartService: Item $i is not a Map: ${itemJson.runtimeType}');
          }
        } catch (e) {
          debugPrint('CartService: Error parsing cart item $i: $e');
          debugPrint('CartService: Problematic item data: ${itemsJson[i]}');
          // 繼續處理其他項目，而不是完全失敗
        }
      }

      debugPrint('CartService: Successfully parsed ${cartItems.length} cart items');
      return cartItems;

    } catch (e) {
      debugPrint('CartService: Error fetching cart items: $e');
      rethrow;
    }
  }

  /// 將商品添加到後端購物車。
  Future<CartItem> addItemToCart(int productId, int quantity) async {
    try {
      debugPrint('CartService: Adding item to cart - productId: $productId, quantity: $quantity');

      final responseBody = await _apiClient.post(
        '/cart',
        body: {
          'product_id': productId,
          'quantity': quantity
        },
      );

      if (responseBody == null) {
        throw Exception('Received null response when adding item to cart');
      }

      final cartItem = CartItem.fromJson(responseBody as Map<String, dynamic>);
      debugPrint('CartService: Successfully added item to cart');
      return cartItem;

    } catch (e) {
      debugPrint('CartService: Error adding item to cart: $e');
      rethrow;
    }
  }

  /// 更新後端購物車中商品的數量。
  Future<CartItem> updateCartItemQuantity(int productId, int newQuantity) async {
    try {
      debugPrint('CartService: Updating cart item quantity - productId: $productId, newQuantity: $newQuantity');

      final responseBody = await _apiClient.put(
        '/cart/$productId',
        body: {'quantity': newQuantity},
      );

      if (responseBody == null) {
        throw Exception('Received null response when updating cart item quantity');
      }

      final cartItem = CartItem.fromJson(responseBody as Map<String, dynamic>);
      debugPrint('CartService: Successfully updated cart item quantity');
      return cartItem;

    } catch (e) {
      debugPrint('CartService: Error updating cart item quantity: $e');
      rethrow;
    }
  }

  /// 從後端購物車中移除商品。
  Future<void> removeItemFromCart(int productId) async {
    try {
      debugPrint('CartService: Removing item from cart - productId: $productId');

      await _apiClient.delete('/cart/$productId');

      debugPrint('CartService: Successfully removed item from cart');

    } catch (e) {
      debugPrint('CartService: Error removing item from cart: $e');
      rethrow;
    }
  }

  /// 清空後端當前用戶的購物車。
  Future<void> clearRemoteCart() async {
    try {
      debugPrint('CartService: Clearing remote cart...');

      await _apiClient.delete('/cart');

      debugPrint('CartService: Successfully cleared remote cart');

    } catch (e) {
      debugPrint('CartService: Error clearing remote cart: $e');
      rethrow;
    }
  }
}