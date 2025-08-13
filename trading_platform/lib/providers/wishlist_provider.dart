// --- FILE: lib/providers/wishlist_provider.dart ---
import 'package:flutter/foundation.dart';
import '../models/user/user.dart';
import '../models/product/product.dart';
import '../models/user/wishlist_item.dart';
import '../services/wishlist_service.dart';
import 'auth_provider.dart';

// 狀態枚舉，用於讓 UI 精確地知道 Provider 當前的狀態
enum WishlistStatus { initial, loading, loaded, empty, error }

class WishlistProvider with ChangeNotifier {
  final WishlistService _wishlistService;
  AuthProvider? _authProvider; // 用於獲取 token 和 user id

  List<WishlistItem> _items = [];
  WishlistStatus _status = WishlistStatus.initial;
  String _errorMessage = '';

  // --- Getters ---
  List<WishlistItem> get items => [..._items];
  WishlistStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == WishlistStatus.loading;

  // 建構函式，接收傳入的 services
  WishlistProvider(this._wishlistService, this._authProvider) {
    _updateDependencies();
  }

  // 當依賴的 AuthProvider 更新時，由 ProxyProvider 呼叫
  void update(AuthProvider newAuthProvider) {
    // 檢查使用者狀態是否真的改變了
    if (_authProvider?.isLoggedIn != newAuthProvider.isLoggedIn) {
      _authProvider = newAuthProvider;
      _updateDependencies();
    }
  }

  void _updateDependencies() {
    if (_authProvider?.isLoggedIn ?? false) {
      fetchWishlistItems(); // 如果使用者已登入，自動獲取收藏清單
    } else {
      _items = []; // 如果使用者登出，清空收藏清單
      _status = WishlistStatus.initial;
      notifyListeners();
    }
  }

  // --- 核心業務邏輯 (注入真實 API 呼叫) ---

  Future<void> fetchWishlistItems({bool forceRefresh = false}) async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;
    if (_status == WishlistStatus.loading && !forceRefresh) return;

    _status = WishlistStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final fetchedItems = await _wishlistService.getMyWishlist();
      _items = fetchedItems;
      _status = _items.isEmpty ? WishlistStatus.empty : WishlistStatus.loaded;
    } catch (e) {
      _errorMessage = "獲取收藏清單失敗: $e";
      _status = WishlistStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> addToWishlist(Product product) async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;
    if (isProductInWishlist(product)) return;

    // 樂觀更新 (Optimistic Update): 先在 UI 上加入，再呼叫 API
    final tempItem = WishlistItem(
      id: -1, // 臨時 ID
      userId: _authProvider!.currentUser!.id,
      productId: product.id,
      createdAt: DateTime.now(),
      product: product,
    );
    _items.add(tempItem);
    notifyListeners();

    try {
      final newItem = await _wishlistService.addItem(product.id);
      // API 成功後，用後端回傳的真實資料替換掉臨時項目
      final index = _items.indexWhere((item) => item.id == -1);
      if (index != -1) {
        _items[index] = newItem;
      }
    } catch (e) {
      // 如果 API 失敗，將剛剛加入的臨時項目移除 (回滾)
      _items.removeWhere((item) => item.id == -1);
      _errorMessage = "加入收藏失敗: $e";
      rethrow; // 向上拋出，讓 UI 層可以顯示 SnackBar
    } finally {
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index == -1) return;

    // 樂觀更新：先在 UI 上移除
    final removedItem = _items.removeAt(index);
    notifyListeners();

    try {
      await _wishlistService.removeItemByProductId(productId);
    } catch (e) {
      // 如果 API 失敗，將剛剛移除的項目加回來 (回滾)
      _items.insert(index, removedItem);
      _errorMessage = "移除收藏失敗: $e";
      notifyListeners();
      rethrow;
    }
  }

  // 檢查商品是否在收藏列表中
  bool isProductInWishlist(Product product) {
    return _items.any((item) => item.productId == product.id);
  }
}

// 假設 WishlistService 的一個輔助方法 (在 WishlistService 類中定義)
// 只是為了讓上面的 removeFromWishlistByProductId 示例更完整
// abstract class WishlistService {
//   ...
//   Future<WishlistItem> addItemToWishlist(String productId);
//   Future<void> removeItemFromWishlist(String wishlistItemId);
//   Future<void> removeItemFromWishlistByProductId(String productId); // 如果支持
//   Future<List<WishlistItem>> getMyWishlistItems();
//   bool isRemoveByProductIdSupported() => false; // 默認不支持，具體服務實現時覆蓋
// }

