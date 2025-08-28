import '../config/api_config.dart';
import '../models/user/cart_item.dart';
import '../models/product/product.dart';
import 'api_client.dart';

import 'package:first_flutter_project/mock/mock.dart';

class CartService {
  final ApiClient _apiClient;
  CartService(this._apiClient);

  // ===== Mock 狀態（常駐於記憶體）=====
  static final List<CartItem> _memoryCart = [];
  static int _nextId = 1;           // 模擬 cart_item 資料表主鍵
  static const int _mockUserId = 777; // 模擬目前登入者（只在 mock 用）

  CartItem _buildMockCartItem({
    required Product product,
    required int quantity,
    bool isSelected = false,
  }) {
    return CartItem(
      id: _nextId++,
      userId: _mockUserId,
      productId: product.id,
      quantity: quantity,
      addedAt: DateTime.now(),
      product: product,
      isSelected: isSelected, // UI 欄位，不會進 JSON
    );
  }

  /// 取得購物車
  Future<List<CartItem>> fetchCartItems() async {
    if (APIConfig.useMock) {
      // 第一次進來時自動放兩筆，預設勾選，方便直接去結帳
      if (_memoryCart.isEmpty) {
        final all = mockAllProducts();
        if (all.isNotEmpty) {
          _memoryCart.add(
            _buildMockCartItem(product: all[0], quantity: 1, isSelected: true),
          );
        }
        if (all.length > 1) {
          _memoryCart.add(
            _buildMockCartItem(product: all[1], quantity: 2, isSelected: true),
          );
        }
      }
      return List<CartItem>.from(_memoryCart);
    }

    // ===== 真實 API =====
    final responseBody = await _apiClient.get('/cart');
    final List<dynamic> itemsJson = responseBody;
    return itemsJson.map((json) => CartItem.fromJson(json)).toList();
  }

  /// 加入購物車
  Future<CartItem> addItemToCart(int productId, int quantity) async {
    if (APIConfig.useMock) {
      final idx = _memoryCart.indexWhere((e) => e.productId == productId);
      if (idx >= 0) {
        final cur = _memoryCart[idx];
        final updated = cur.copyWith(
          quantity: cur.quantity + quantity,
          isSelected: true,
        );
        _memoryCart[idx] = updated;
        return updated;
      } else {
        final product = findMockProductById(productId);
        final added = _buildMockCartItem(
          product: product,
          quantity: quantity,
          isSelected: true,
        );
        _memoryCart.add(added);
        return added;
      }
    }

    // ===== 真實 API =====
    final responseBody = await _apiClient.post(
      '/cart',
      body: {'product_id': productId, 'quantity': quantity},
    );
    return CartItem.fromJson(responseBody);
  }

  /// 更新數量
  Future<CartItem> updateCartItemQuantity(int productId, int newQuantity) async {
    if (APIConfig.useMock) {
      final idx = _memoryCart.indexWhere((e) => e.productId == productId);
      if (idx < 0) {
        throw Exception('Mock cart: item not found');
      }
      // 這裡不做 <= 0 的刪除，因為 Provider 內已處理 <=0 時會改呼叫 removeItem
      final updated = _memoryCart[idx].copyWith(quantity: newQuantity);
      _memoryCart[idx] = updated;
      return updated;
    }

    // ===== 真實 API =====
    final responseBody = await _apiClient.put(
      '/cart/$productId',
      body: {'quantity': newQuantity},
    );
    return CartItem.fromJson(responseBody);
  }

  /// 移除單一商品
  Future<void> removeItemFromCart(int productId) async {
    if (APIConfig.useMock) {
      _memoryCart.removeWhere((e) => e.productId == productId);
      return;
    }
    await _apiClient.delete('/cart/$productId');
  }

  /// 清空購物車
  Future<void> clearRemoteCart() async {
    if (APIConfig.useMock) {
      _memoryCart.clear();
      return;
    }
    await _apiClient.delete('/cart');
  }
}
