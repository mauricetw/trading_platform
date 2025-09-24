// lib/providers/cart_provider.dart
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

  // --- 關鍵新增：清空本地購物車狀態的方法 ---
  /// 當訂單成功建立後，由 CheckoutProvider 呼叫，只清空前端的狀態
  void clearLocalCart() {
    // 只移除那些被選中並成功結帳的商品
    _items.removeWhere((key, value) => value.isSelected);
    notifyListeners();
  }

  // --- 核心業務邏輯 ---

  Future<void> fetchUserCart({bool forceRefresh = false}) async {
    if (!(_authProvider?.isLoggedIn ?? false)) {
      debugPrint('CartProvider: User not logged in, skipping fetch');
      return;
    }
    if (_isLoading && !forceRefresh) {
      debugPrint('CartProvider: Already loading, skipping fetch');
      return;
    }

    debugPrint('CartProvider: Starting to fetch user cart (forceRefresh: $forceRefresh)');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedItems = await _cartService.fetchCartItems();
      debugPrint('CartProvider: Received ${fetchedItems.length} items from service');

      _items = {};

      for (var item in fetchedItems) {
        debugPrint('CartProvider: Processing item - ProductID: ${item.productId}, Name: ${item.product.name}');
        _items[item.productId] = item;
      }

      debugPrint('CartProvider: Successfully stored ${_items.length} cart items');

    } catch (e, stackTrace) {
      _error = e.toString();
      debugPrint('CartProvider: Error fetching cart: $_error');
      debugPrint('CartProvider: Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('CartProvider: Fetch cart completed, loading: $_isLoading, error: $_error');
    }
  }

  Future<void> addItem(Product product, int quantityToAdd) async {
    if (!(_authProvider?.isLoggedIn ?? false)) {
      _error = "請先登入";
      notifyListeners();
      return;
    }
    if (quantityToAdd <= 0) return;

    final int productId = product.id;

    try {
      debugPrint('CartProvider: Adding item to cart - productId: $productId, quantity: $quantityToAdd');

      final updatedItem = await _cartService.addItemToCart(productId, quantityToAdd);
      _items[productId] = updatedItem;
      notifyListeners();

      debugPrint('CartProvider: Successfully added item to cart');
    } catch (e) {
      _error = "加入購物車失敗: $e";
      debugPrint('CartProvider: Error adding item: $_error');
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
      debugPrint('CartProvider: Successfully removed item from cart');
    } catch (e) {
      if (removedItem != null) {
        _items[productId] = removedItem;
      }
      _error = "移除商品失敗: $e";
      debugPrint('CartProvider: Error removing item: $_error');
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
      debugPrint('CartProvider: Successfully updated item quantity');
    } catch (e) {
      _items[productId] = originalItem;
      _error = "更新數量失敗: $e";
      debugPrint('CartProvider: Error updating quantity: $_error');
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
      debugPrint('CartProvider: Successfully cleared cart');
    } catch (e) {
      _items = backupItems;
      _error = "清空購物車失敗: $e";
      debugPrint('CartProvider: Error clearing cart: $_error');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> clearSelectedItems() async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;

    final selectedIds = _items.values
        .where((item) => item.isSelected)
        .map((item) => item.productId)
        .toList();

    if (selectedIds.isEmpty) return;

    final backupItems = Map.of(_items);
    _items.removeWhere((key, value) => value.isSelected);
    notifyListeners();

    try {
      await Future.wait(
          selectedIds.map((id) => _cartService.removeItemFromCart(id))
      );
      debugPrint('CartProvider: Successfully cleared selected items');
    } catch (e) {
      _items = backupItems;
      _error = "清除已選商品失敗: $e";
      debugPrint('CartProvider: Error clearing selected items: $_error');
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}