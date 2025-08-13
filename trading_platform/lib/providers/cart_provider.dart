// --- FILE: lib/providers/cart_provider.dart ---
import 'package:flutter/foundation.dart';
import '../models/user/cart_item.dart';
import '../models/product/product.dart';
import '../services/cart_service.dart';
import 'auth_provider.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService;
  AuthProvider? _authProvider;

  Map<int, CartItem> _items = {};
  bool _isLoading = false;
  String? _error;

  // --- Getters ---
  List<CartItem> get items => _items.values.toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _items.length;

  double get totalSelectedAmount {
    return _items.values
        .where((item) => item.isSelected)
        .fold(0.0, (sum, item) => sum + item.product.price * item.quantity);
  }

  int get selectedItemCount {
    return _items.values.where((item) => item.isSelected).length;
  }

  bool get isAllSelected {
    if (_items.isEmpty) return false;
    return _items.values.every((item) => item.isSelected);
  }

  // 建構函式
  CartProvider(this._cartService, this._authProvider) {
    _updateDependencies();
  }

  // 由 ProxyProvider 呼叫
  void update(AuthProvider newAuthProvider) {
    _authProvider = newAuthProvider;
    _updateDependencies();
  }

  void _updateDependencies() {
    if (_authProvider?.isLoggedIn ?? false) {
      fetchUserCart();
    } else {
      _items = {};
      notifyListeners();
    }
  }

  // --- 核心業務邏輯 ---

  Future<void> fetchUserCart({bool forceRefresh = false}) async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedItems = await _cartService.fetchCartItems();
      _items = { for (var item in fetchedItems) item.productId : item };
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(Product product, int quantityToAdd) async {
    if (!(_authProvider?.isLoggedIn ?? false)) {
      _error = "請先登入";
      notifyListeners();
      return;
    }
    if (quantityToAdd <= 0) return;

    final int key = product.id;
    try {
      final updatedItem = await _cartService.addItemToCart(key, quantityToAdd);
      _items[key] = updatedItem;
      notifyListeners();
    } catch (e) {
      _error = "加入購物車失敗: $e";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeItem(int productId) async {
    if (!_items.containsKey(productId)) return;
    final removedItem = _items.remove(productId);
    notifyListeners();
    try {
      await _cartService.removeItemFromCart(productId);
    } catch (e) {
      _items[productId] = removedItem!;
      _error = "移除商品失敗: $e";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateQuantity(int productId, int newQuantity) async {
    if (!_items.containsKey(productId)) return;

    final originalItem = _items[productId]!;
    if (newQuantity == originalItem.quantity) return;

    if (newQuantity <= 0) {
      await removeItem(productId);
      return;
    }

    _items[productId] = originalItem.copyWith(quantity: newQuantity);
    notifyListeners();

    try {
      final updatedItem = await _cartService.updateCartItemQuantity(productId, newQuantity);
      _items[productId] = updatedItem;
    } catch (e) {
      _items[productId] = originalItem; // API 失敗時回滾
      _error = "更新數量失敗: $e";
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> incrementQuantity(int productId) async {
    if (!_items.containsKey(productId)) return;
    final newQuantity = _items[productId]!.quantity + 1;
    await updateQuantity(productId, newQuantity);
  }

  Future<void> decrementQuantity(int productId) async {
    if (!_items.containsKey(productId)) return;
    final newQuantity = _items[productId]!.quantity - 1;
    await updateQuantity(productId, newQuantity);
  }

  Future<void> clearCart() async {
    if (_items.isEmpty) return;
    final backupItems = Map.of(_items);
    _items.clear();
    notifyListeners();
    try {
      await _cartService.clearRemoteCart();
    } catch (e) {
      _items = backupItems;
      _error = "清空購物車失敗: $e";
      notifyListeners();
      rethrow;
    }
  }

  // --- 【【【錯誤修正：新增這個方法】】】 ---
  /// 清除所有已選中的商品 (通常在下單成功後呼叫)
  Future<void> clearSelectedItems() async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;

    // 1. 找出所有被選中的商品 ID
    final selectedIds = _items.values
        .where((item) => item.isSelected)
        .map((item) => item.productId)
        .toList();

    if (selectedIds.isEmpty) return;

    // 2. 樂觀更新：先在 UI 上移除
    final backupItems = Map.of(_items);
    _items.removeWhere((key, value) => value.isSelected);
    notifyListeners();

    try {
      // 3. 呼叫後端 API 逐一刪除
      // 注意：更高效的做法是提供一個可以批量刪除的後端 API
      await Future.wait(
          selectedIds.map((id) => _cartService.removeItemFromCart(id))
      );
    } catch (e) {
      // 4. 如果 API 失敗，回滾 UI
      _items = backupItems;
      _error = "清除已選商品失敗: $e";
      notifyListeners();
      rethrow;
    }
  }

  // --- 純前端 UI 狀態操作 ---
  void toggleItemSelected(int productId, bool isSelected) {
    if (!_items.containsKey(productId)) return;
    _items[productId]!.isSelected = isSelected;
    notifyListeners();
  }

  void toggleSelectAll(bool select) {
    if (_items.isEmpty) return;
    for (var item in _items.values) {
      item.isSelected = select;
    }
    notifyListeners();
  }

// --- 後端同步方法 (TODOs) ---
// Future<void> saveCartItemToBackend(CartItem item) async { ... }
// Future<void> removeCartItemFromBackend(String productId) async { ... }
// Future<void> updateCartItemQuantityInBackend(String productId, int newQuantity) async { ... }
// Future<void> clearCartInBackend(String userId) async { ... }
}

