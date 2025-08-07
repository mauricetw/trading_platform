import 'package:flutter/foundation.dart';
import '../models/user/cart_item.dart';
import '../models/product/product.dart'; // 確保 Product 模型路徑正確

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  String? _currentUserId;

  // --- 【【新增】】狀態管理 ---
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- Getters ---
  List<CartItem> get items => _items.values.toList();

  int get totalQuantity {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.productPrice * cartItem.quantity;
    });
    return total;
  }

  List<CartItem> get selectedItems {
    return _items.values.where((item) => item.isSelected).toList();
  }

  int get selectedItemCount {
    return _items.values.where((item) => item.isSelected).length;
  }

  // 【【修改】】Getter 名稱以匹配 CartPage
  double get totalSelectedAmount { // 原名: selectedItemsTotalAmount
    var total = 0.0;
    _items.values.where((item) => item.isSelected).forEach((cartItem) {
      total += cartItem.productPrice * cartItem.quantity;
    });
    return total;
  }

  // 【【新增】】Getter，用於判斷是否所有商品都已選中
  bool get isAllSelected {
    if (_items.isEmpty) return false; // 如果購物車為空，不能算全選
    return _items.values.every((item) => item.isSelected);
  }


  // --- User Management ---
  void updateCurrentUser(String? userId) {
    bool userChanged = _currentUserId != userId;
    _currentUserId = userId;

    if (userChanged) {
      _items.clear();
      _error = null; // 清除之前的錯誤
      if (_currentUserId != null) {
        print('用戶已更新為: $_currentUserId. 應從後端加載其購物車。');
        fetchUserCart(); // 自動為新用戶獲取購物車
      } else {
        print('用戶已登出，購物車已清空。');
        notifyListeners(); // 確保 UI 更新
      }
      // 不在這裡立即 notifyListeners()，讓 fetchUserCart() 處理
    }
  }

  // --- 【【新增】】從後端獲取購物車數據的方法 (骨架) ---
  Future<void> fetchUserCart({bool forceRefresh = false}) async {
    if (_currentUserId == null) {
      _items.clear(); // 確保未登錄時購物車是空的
      _error = null;
      _isLoading = false; // 非登錄狀態下，不應處於加載中
      notifyListeners();
      return;
    }
    if (_isLoading && !forceRefresh) return; // 防止重複加載

    print("CartProvider: Fetching user cart for $_currentUserId, forceRefresh: $forceRefresh");
    _isLoading = true;
    _error = null;
    if (forceRefresh || _items.isEmpty) { // 如果強制刷新或本地購物車為空
      notifyListeners(); // 立即通知UI進入加載狀態
    }


    try {
      // 模擬網絡延時
      await Future.delayed(const Duration(seconds: 1));

      // 【【實際後端邏輯】】
      // 在這裡，您應該調用您的後端服務來獲取用戶的購物車數據
      // 例如: final fetchedCartData = await YourApiService.fetchCart(_currentUserId!);
      // 然後將 fetchedCartData 轉換為 Map<String, CartItem>

      // 模擬獲取到的數據 (假設後端返回了商品列表)
      // 這部分應該被真實的 API 調用替換
      final Map<String, CartItem> fetchedItems = {}; // 假設初始為空，或者從後端填充

      // 示例：如果後端返回數據
      // if (fetchedCartData.isSuccess) {
      //   _items.clear(); // 清空舊的本地數據
      //   for (var backendItem in fetchedCartData.data) { // 假設 backendItem 是後端返回的購物車項
      //     final cartItem = CartItem.fromBackend(backendItem); // 假設 CartItem 有一個 fromBackend 構造函數
      //     _items[cartItem.productId] = cartItem;
      //   }
      // } else {
      //   _error = "無法從服務器獲取購物車數據: ${fetchedCartData.errorMessage}";
      // }
      _items.clear(); // 為了演示，先清空，您應該用後端數據填充

      // 演示用：添加一些模擬數據，如果需要的話
      // if (_items.isEmpty) { // 僅在測試且購物車為空時添加模擬數據
      //   addItem(Product(id: 'prod1', name: '模擬商品1', price: 10.0, imageUrls: [], description: '', categoryId: 1, stockQuantity: 10, category: 'CatA', status: 'available', createdAt: DateTime.now(), updatedAt: DateTime.now()), 1);
      //   addItem(Product(id: 'prod2', name: '模擬商品2', price: 20.0, imageUrls: [], description: '', categoryId: 1, stockQuantity: 5, category: 'CatB', status: 'available', createdAt: DateTime.now(), updatedAt: DateTime.now()), 2, wasSelected: false);
      // }

      print("CartProvider: Cart fetched successfully. Items count: ${_items.length}");

    } catch (e) {
      print("CartProvider: Error fetching cart: $e");
      _error = "獲取購物車失敗: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // --- Cart Actions ---

  // 【【修改】】addItem 方法以包含 wasSelected 參數
  void addItem(Product product, int quantityToAdd, {bool wasSelected = true}) {
    if (_currentUserId == null) {
      print('用戶未登入，無法添加到購物車');
      _error = "請先登錄後再添加商品到購物車。"; // 設置錯誤信息
      notifyListeners();
      return;
    }
    if (quantityToAdd <= 0) return; // 確保添加的數量是正數

    final String key = product.id;
    _error = null; // 清除之前的錯誤信息

    if (_items.containsKey(key)) {
      _items.update(
        key,
            (existingItem) => existingItem.copyWith(
          quantity: existingItem.quantity + quantityToAdd,
          isSelected: wasSelected, // 如果商品已存在，也更新其選中狀態 (用於撤銷等場景)
        ),
      );
    } else {
      final newItem = CartItem(
        // id: null, // 如果後端生成 ID
        userId: _currentUserId!,
        productId: product.id,
        quantity: quantityToAdd,
        productName: product.name,
        productPrice: product.price,
        productImage: product.imageUrls.isNotEmpty ? product.imageUrls[0] : null,
        isSelected: wasSelected, // 新添加的商品根據傳入參數決定是否選中
        // 以下是 CartItem 中可能有的其他 Product 相關字段，用於 UI 顯示或撤銷時重建 Product
        // productDescription: product.description,
        // categoryId: product.categoryId,
        // categoryName: product.category,
        // originalStockQuantity: product.stockQuantity, // 假設 CartItem 存儲原始庫存
        // productCreatedAt: product.createdAt,
      );
      _items.putIfAbsent(key, () => newItem);
    }
    // TODO: saveCartItemToBackend(_items[key]!);
    print("CartProvider: Item '${product.name}' added/updated. New quantity: ${_items[key]?.quantity}, Selected: ${_items[key]?.isSelected}");
    notifyListeners();
  }

  void removeItem(String productId) {
    if (_currentUserId == null) return;
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      // TODO: removeCartItemFromBackend(productId);
      notifyListeners();
      print("CartProvider: Item '$productId' removed.");
    }
  }

  // 【【新增】】減少商品數量，如果數量為0則移除
  void decrementQuantity(String productId) {
    if (_currentUserId == null || !_items.containsKey(productId)) return;

    final currentItem = _items[productId]!;
    if (currentItem.quantity > 1) {
      _items.update(
        productId,
            (existingItem) => existingItem.copyWith(quantity: existingItem.quantity - 1),
      );
      // TODO: updateCartItemQuantityInBackend
      print("CartProvider: Item '$productId' quantity decremented to ${currentItem.quantity - 1}.");
    } else {
      // 如果數量為1，再減少就等於移除，但 CartPage 的 UI 會通過 _confirmRemoveItem 處理
      // 理論上，如果 UI 設計是點擊 "-" 到 1 再點就移除，這裡可以直接調用 removeItem
      // 但為了與 CartPage 的邏輯一致（它會彈出確認框），這裡暫時不直接移除
      // 或者，我們可以在這裡直接移除，然後 CartPage 的 _confirmRemoveItem 就可以簡化
      // 這裡選擇：如果 CartPage 的 "-" 按鈕在數量為1時觸發 _confirmRemoveItem，則此處邏輯正確
      // 如果 CartPage 的 "-" 按鈕在數量為1時仍調用 decrementQuantity，則應在此處移除：
      // removeItem(productId);
    }
    notifyListeners();
  }

  // 【【新增】】增加商品數量
  void incrementQuantity(String productId) {
    if (_currentUserId == null || !_items.containsKey(productId)) return;
    // TODO: 在這裡可以加入庫存檢查邏輯
    // if (_items[productId]!.quantity >= _items[productId]!.originalStockQuantity) {
    //   _error = "商品 '${_items[productId]!.productName}' 已達庫存上限";
    //   notifyListeners();
    //   return;
    // }
    _items.update(
      productId,
          (existingItem) => existingItem.copyWith(quantity: existingItem.quantity + 1),
    );
    // TODO: updateCartItemQuantityInBackend
    print("CartProvider: Item '$productId' quantity incremented to ${_items[productId]!.quantity}.");
    notifyListeners();
  }


  // 【【修改】】toggleItemSelection 以匹配 CartPage 的參數
  void toggleItemSelected(String productId, bool isSelected) {
    if (!_items.containsKey(productId)) return;

    _items.update(
      productId,
          (existingItem) => existingItem.copyWith(isSelected: isSelected),
    );
    notifyListeners();
    print("CartProvider: Item '$productId' selection toggled to $isSelected.");
  }


  // 【【修改】】toggleAllSelection 以匹配 CartPage 的參數
  void toggleSelectAll(bool select) { // 原名 toggleAllSelection({bool? forceSelectedState})
    if (_items.isEmpty) return;

    _items.forEach((key, cartItem) {
      if (cartItem.isSelected != select) {
        _items.update(
            key, (existing) => existing.copyWith(isSelected: select));
      }
    });
    notifyListeners();
    print("CartProvider: All items selection toggled to $select.");
  }


  void clearCart() {
    if (_currentUserId == null && _items.isEmpty) return;
    if (_items.isNotEmpty) {
      _items.clear();
      _error = null; // 清空時也清除錯誤
      // TODO: clearCartInBackend(_currentUserId!);
      notifyListeners();
      print("CartProvider: Cart cleared.");
    }
  }

  void clearSelectedItems() {
    if (_currentUserId == null) return;
    bool itemsWereRemoved = false;
    _items.removeWhere((key, cartItem) {
      if (cartItem.isSelected) {
        itemsWereRemoved = true;
        // TODO: removeCartItemFromBackend(cartItem.productId);
        return true;
      }
      return false;
    });
    if (itemsWereRemoved) {
      notifyListeners();
      print("CartProvider: Selected items cleared.");
    }
  }

// --- 後端同步方法 (TODOs) ---
// Future<void> saveCartItemToBackend(CartItem item) async { ... }
// Future<void> removeCartItemFromBackend(String productId) async { ... }
// Future<void> updateCartItemQuantityInBackend(String productId, int newQuantity) async { ... }
// Future<void> clearCartInBackend(String userId) async { ... }
}

