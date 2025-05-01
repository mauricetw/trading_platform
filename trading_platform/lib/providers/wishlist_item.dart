import 'package:flutter/foundation.dart';
import '../models/user/wishlist_item.dart';
import '../models/product/product.dart'; // 需要 Product Model 來判斷商品是否存在收藏列表

class WishlistProvider with ChangeNotifier {
  // 當前使用者的收藏列表
  List<WishlistItem> _wishlistItems = [];

  List<WishlistItem> get wishlistItems => _wishlistItems;

  // 表示是否正在加載數據
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // 錯誤信息
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  // TODO: 需要獲取當前使用者 ID，通常從 AuthProvider 獲取
  String? _currentUserId; // 可以通過構造函數或初始化方法從 AuthProvider 獲取

  // 初始化，可以在這裡加載收藏列表
  // WishlistProvider(String? userId) : _currentUserId = userId {
  //   if (_currentUserId != null) {
  //     fetchWishlistItems(); // 如果用戶已登入，加載收藏列表
  //   }
  // }
  // 更常見的方式是在 AuthProvider 狀態改變時觸發加載

  // 獲取收藏列表的方法（通常從後端 API）
  Future<void> fetchWishlistItems(String userId) async {
    if (_isLoading || _currentUserId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: 替換成實際的 API 調用，根據 userId 獲取收藏列表
      await Future.delayed(const Duration(seconds: 1)); // 模擬延遲

      // 模擬從後端獲取的收藏列表數據
      final List<Map<String, dynamic>> jsonData = [
        // 假設這裡包含了 WishlistItem 和相關 Product 的 JSON
        // 例如: {'id': 'wl1', 'userId': 'user1', 'productId': 'prod1', 'createdAt': '...', 'product': {...}}
      ];

      _wishlistItems =
          jsonData.map((json) => WishlistItem.fromJson(json)).toList();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = '無法獲取收藏列表: $error';
      _wishlistItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 添加商品到收藏列表
  Future<void> addToWishlist(Product product) async {
    if (_currentUserId == null) {
      // 提示用戶登入
      return;
    }

    // 檢查是否已在收藏列表，避免重複添加
    if (isProductInWishlist(product)) {
      return;
    }

    // TODO: 替換成實際的 API 調用，將商品添加到收藏列表
    try {
      await Future.delayed(const Duration(seconds: 1)); // 模擬 API 調用

      // 模擬後端返回新創建的 WishlistItem 數據
      final newWishlistItemJson = {
        'id': 'new_wl_id_${DateTime
            .now()
            .millisecondsSinceEpoch}', // 模擬生成 ID
        'userId': _currentUserId!,
        'productId': product.id,
        'createdAt': DateTime.now().toIso8601String(),
        // 'product': product.toJson(), // 如果需要包含 Product 信息
      };
      final newWishlistItem = WishlistItem.fromJson(newWishlistItemJson);

      _wishlistItems.add(newWishlistItem); // 將新項目添加到本地列表
      notifyListeners(); // 通知 UI 更新

    } catch (error) {
      // 處理錯誤
      print('添加收藏失敗: $error');
    }
  }

  // 從收藏列表中移除商品
  Future<void> removeFromWishlist(WishlistItem item) async {
    if (_currentUserId == null) {
      return;
    }
    // TODO: 替換成實際的 API 調用，從收藏列表中移除商品
    try {
      await Future.delayed(const Duration(seconds: 1)); // 模擬 API 調用

      _wishlistItems.removeWhere((element) => element.id == item.id); // 從本地列表移除
      notifyListeners(); // 通知 UI 更新

    } catch (error) {
      // 處理錯誤
      print('移除收藏失敗: $error');
    }
  }

  // 檢查商品是否在收藏列表中
  bool isProductInWishlist(Product product) {
    return _wishlistItems.any((item) => item.productId == product.id);
  }

  // 當 AuthProvider 的使用者狀態改變時呼叫此方法
  void updateCurrentUser(String? userId) {
    _currentUserId = userId;
    if (_currentUserId != null) {
      fetchWishlistItems(_currentUserId!); // 用戶登入後加載收藏列表
    } else {
      _wishlistItems = []; // 用戶登出後清空收藏列表
      notifyListeners();
    }
  }
}