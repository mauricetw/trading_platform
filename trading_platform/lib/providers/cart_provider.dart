// --- FILE: lib/providers/cart_provider.dart ---
import 'package:flutter/foundation.dart';
import '../models/user/cart_item.dart';
import '../models/product/product.dart';
import '../services/cart_service.dart'; // 引入我們建立的 CartService
import 'auth_provider.dart'; // 依賴 AuthProvider 來獲取使用者狀態

class CartProvider with ChangeNotifier {
  final CartService _cartService;
  AuthProvider? _authProvider; // 用於獲取 token 和 user id

  Map<int, CartItem> _items = {}; // 修改：Key 使用 int (productId)
  bool _isLoading = false;
  String? _error;

  // --- Getters (與你的版本保持一致) ---
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

  // 建構函式，接收傳入的 services
  CartProvider(this._cartService, this._authProvider) {
    _updateDependencies();
  }

  // 當依賴的 AuthProvider 更新時，由 ProxyProvider 呼叫
  void update(AuthProvider newAuthProvider) {
    _authProvider = newAuthProvider;
    _updateDependencies();
  }

  void _updateDependencies() {
    if (_authProvider?.isLoggedIn ?? false) {
      fetchUserCart(); // 如果使用者已登入，自動獲取購物車
    } else {
      _items = {}; // 如果使用者登出，清空購物車
      notifyListeners();
    }
  }

  // --- 核心業務邏輯 (注入真實 API 呼叫) ---

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
    final existingItem = _items[key];
    final int newQuantity = (existingItem?.quantity ?? 0) + quantityToAdd;

    try {
      // 呼叫真實 API
      final updatedItem = await _cartService.addItemToCart(key, quantityToAdd);
      _items[key] = updatedItem;
      notifyListeners();
    } catch (e) {
      _error = "加入購物車失敗: $e";
      notifyListeners();
      rethrow; // 向上拋出，讓 UI 層可以顯示 SnackBar
    }
  }

  Future<void> removeItem(int productId) async {
    if (!_items.containsKey(productId)) return;

    final removedItem = _items.remove(productId); // 樂觀更新 UI
    notifyListeners();

    try {
      await _cartService.removeItemFromCart(productId);
    } catch (e) {
      _items[productId] = removedItem!; // 如果 API 失敗，將項目加回來
      _error = "移除商品失敗: $e";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateQuantity(int productId, int newQuantity) async {
    if (!_items.containsKey(productId)) return;

    final originalQuantity = _items[productId]!.quantity;
    if (newQuantity == originalQuantity) return;

    // 如果新數量為 0 或更少，則執行移除操作
    if (newQuantity <= 0) {
      await removeItem(productId);
      return;
    }

    // --- 錯誤 1 修正 ---
    // 因為 CartItem 是不可變的 (immutable)，我們不能直接修改 quantity。
    // 我們應該使用 copyWith 創建一個新的 CartItem 實例來進行樂觀更新。
    _items[productId] = _items[productId]!.copyWith(quantity: newQuantity); // 樂觀更新 UI
    notifyListeners();

    try {
      final updatedItem = await _cartService.updateCartItemQuantity(productId, newQuantity);
      _items[productId] = updatedItem;
    } catch (e) {
      // --- 錯誤 2 修正 ---
      // 如果 API 失敗，恢復原來的 CartItem 實例。
      _items[productId] = _items[productId]!.copyWith(quantity: originalQuantity);
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
      _items = backupItems; // 如果 API 失敗，恢復購物車
      _error = "清空購物車失敗: $e";
      notifyListeners();
      rethrow;
    }
  }

  // --- 純前端 UI 狀態操作 (無需 API 呼叫) ---
  // --- 錯誤 3 修正 ---
  // 將 productId 的類型從 String 改為 int，以匹配 Map 的 key 類型。
  void toggleItemSelected(int productId, bool isSelected) {
    if (!_items.containsKey(productId)) return;

    // 我們可以直接修改 isSelected，因為它在 CartItem 模型中不是 final。
    // 如果它是 final，我們也需要使用 copyWith。
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

