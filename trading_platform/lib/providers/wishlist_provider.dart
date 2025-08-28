import 'package:flutter/foundation.dart';
import '../models/user/wishlist_item.dart';
import '../services/wishlist_service.dart';
import 'auth_provider.dart';
import '../config/api_config.dart';

enum WishlistStatus { initial, loading, loaded, empty, error }

class WishlistProvider with ChangeNotifier {
  final WishlistService _wishlistService;
  AuthProvider? _authProvider;

  List<WishlistItem> _items = [];
  WishlistStatus _status = WishlistStatus.initial;
  String _errorMessage = '';

  List<WishlistItem> get items => [..._items];
  WishlistStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == WishlistStatus.loading;

  WishlistProvider(this._wishlistService, this._authProvider) {
    _updateDependencies();
  }

  void update(AuthProvider? newAuthProvider) {
    if (_authProvider?.isLoggedIn != newAuthProvider?.isLoggedIn) {
      _authProvider = newAuthProvider;
      _updateDependencies();
    }
  }

  void _updateDependencies() {
    if (_authProvider?.isLoggedIn ?? false) {
      fetchWishlistItems();
    } else {
      _items = [];
      _status = WishlistStatus.initial;
      notifyListeners();
    }
  }

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

  Future<void> addToWishlist(int productId) async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;

    try {
      final newItem = await _wishlistService.addItem(productId);
      _items.add(newItem);
      _status = WishlistStatus.loaded;
      notifyListeners();
    } catch (e) {
      _errorMessage = "加入收藏失敗: $e";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    try {
      await _wishlistService.removeItemByProductId(productId);
      _items.removeWhere((item) => item.productId == productId);
      _status = _items.isEmpty ? WishlistStatus.empty : WishlistStatus.loaded;
      notifyListeners();
    } catch (e) {
      _errorMessage = "移除收藏失敗: $e";
      notifyListeners();
      rethrow;
    }
  }

  void clearWishlist() {
    _items = [];
    _status = WishlistStatus.empty;
    notifyListeners();
  }

  bool isProductInWishlist(int productId) {
    return _items.any((item) => item.productId == productId);
  }
}
