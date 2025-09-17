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

      if (responseBody == null) {
        debugPrint('CartService: Received null response');
        return [];
      }

      if (responseBody is! List) {
        debugPrint('🚨 CartService: 後端回應格式錯誤！');
        debugPrint('期望: List，實際收到: ${responseBody.runtimeType}');
        debugPrint('回應內容: $responseBody');
        throw Exception('後端 API 回應格式錯誤：期望陣列但收到 ${responseBody.runtimeType}');
      }

      final List<dynamic> itemsJson = responseBody;
      debugPrint('CartService: 收到 ${itemsJson.length} 個購物車項目');

      final List<CartItem> cartItems = [];
      int successCount = 0;
      int issueCount = 0;
      int failureCount = 0;

      for (int i = 0; i < itemsJson.length; i++) {
        try {
          final itemJson = itemsJson[i];
          debugPrint('CartService: 處理項目 $i...');

          if (itemJson is! Map<String, dynamic>) {
            debugPrint('❌ CartService: 項目 $i 不是有效的 JSON 物件');
            failureCount++;
            continue;
          }

          final cartItem = CartItem.fromJson(itemJson);
          cartItems.add(cartItem);

          // 檢查資料品質
          if (cartItem.hasDataIssues) {
            issueCount++;
            debugPrint('⚠️ CartService: 項目 $i (${cartItem.product.name}) 有資料品質問題：');
            for (final issue in cartItem.dataIssues) {
              debugPrint('   - $issue');
            }
          } else {
            successCount++;
          }

        } catch (e, stackTrace) {
          debugPrint('CartService: 項目 $i 解析完全失敗');
          debugPrint('錯誤: $e');
          debugPrint('資料: ${itemsJson[i]}');
          debugPrint('堆疊: $stackTrace');
          failureCount++;
        }
      }

      // 資料品質總結報告
      debugPrint('=== CartService 資料品質報告 ===');
      debugPrint('總項目數: ${itemsJson.length}');
      debugPrint('✅ 完美解析: $successCount');
      debugPrint('⚠️ 有問題但可用: $issueCount');
      debugPrint('❌ 完全失敗: $failureCount');
      debugPrint('成功率: ${((successCount + issueCount) / itemsJson.length * 100).toStringAsFixed(1)}%');

      // 如果資料品質很差，發出警告
      if (failureCount > 0) {
        debugPrint('警告：有 $failureCount 個項目完全無法解析，請檢查後端！');
      }

      if (issueCount > itemsJson.length * 0.3) { // 超過30%有問題
        debugPrint(' 警告：超過30%的資料有品質問題，建議檢查後端 API！');
      }

      return cartItems;

    } catch (e, stackTrace) {
      debugPrint('CartService: 獲取購物車完全失敗');
      debugPrint('錯誤: $e');
      debugPrint('堆疊: $stackTrace');
      rethrow;
    }
  }

  /// 將商品添加到後端購物車。
  Future<CartItem> addItemToCart(int productId, int quantity) async {
    try {
      debugPrint('CartService: 添加商品到購物車 - productId: $productId, quantity: $quantity');

      final responseBody = await _apiClient.post(
        '/cart',
        body: {
          'product_id': productId,
          'quantity': quantity
        },
      );

      if (responseBody == null) {
        throw Exception('後端回應為空，添加商品失敗');
      }

      if (responseBody is! Map<String, dynamic>) {
        debugPrint(' CartService: 添加商品回應格式錯誤！');
        debugPrint('期望: Map，實際: ${responseBody.runtimeType}');
        debugPrint('回應: $responseBody');
        throw Exception('後端回應格式錯誤');
      }

      final cartItem = CartItem.fromJson(responseBody);

      // 檢查新添加的項目品質
      if (cartItem.hasDataIssues) {
        debugPrint('⚠️ CartService: 新添加的項目有資料問題：');
        for (final issue in cartItem.dataIssues) {
          debugPrint('   - $issue');
        }
      } else {
        debugPrint('✅ CartService: 成功添加商品：${cartItem.product.name}');
      }

      return cartItem;

    } catch (e, stackTrace) {
      debugPrint('CartService: 添加商品失敗');
      debugPrint('錯誤: $e');
      debugPrint('堆疊: $stackTrace');
      rethrow;
    }
  }

  /// 更新後端購物車中商品的數量。
  Future<CartItem> updateCartItemQuantity(int productId, int newQuantity) async {
    try {
      debugPrint('CartService: 更新商品數量 - productId: $productId, newQuantity: $newQuantity');

      final responseBody = await _apiClient.put(
        '/cart/$productId',
        body: {'quantity': newQuantity},
      );

      if (responseBody == null) {
        throw Exception('後端回應為空，更新數量失敗');
      }

      if (responseBody is! Map<String, dynamic>) {
        debugPrint('CartService: 更新數量回應格式錯誤！');
        throw Exception('後端回應格式錯誤');
      }

      final cartItem = CartItem.fromJson(responseBody);

      if (cartItem.hasDataIssues) {
        debugPrint('⚠️ CartService: 更新後的項目有資料問題');
      } else {
        debugPrint('✅ CartService: 成功更新數量');
      }

      return cartItem;

    } catch (e, stackTrace) {
      debugPrint('CartService: 更新數量失敗');
      debugPrint('錯誤: $e');
      rethrow;
    }
  }

  /// 從後端購物車中移除商品。
  Future<void> removeItemFromCart(int productId) async {
    try {
      debugPrint('CartService: 移除商品 - productId: $productId');

      await _apiClient.delete('/cart/$productId');

      debugPrint('✅ CartService: 成功移除商品');

    } catch (e, stackTrace) {
      debugPrint('CartService: 移除商品失敗');
      debugPrint('錯誤: $e');
      rethrow;
    }
  }

  /// 清空後端當前用戶的購物車。
  Future<void> clearRemoteCart() async {
    try {
      debugPrint('CartService: 清空購物車...');

      await _apiClient.delete('/cart');

      debugPrint('✅ CartService: 成功清空購物車');

    } catch (e, stackTrace) {
      debugPrint('CartService: 清空購物車失敗');
      debugPrint('錯誤: $e');
      rethrow;
    }
  }
}