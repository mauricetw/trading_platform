// --- FILE: lib/providers/wishlist_provider.dart ---
import 'package:flutter/foundation.dart';
import 'auth_provider.dart';

enum WishlistStatus { initial, loading, loaded, empty, error }

class WishlistProvider with ChangeNotifier {
  AuthProvider? _authProvider;

  List<dynamic> _items = [];
  WishlistStatus _status = WishlistStatus.initial;
  String _errorMessage = '';

  List<dynamic> get items => [..._items];
  WishlistStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == WishlistStatus.loading;

  WishlistProvider(dynamic wishlistService, AuthProvider? authProvider)
      : _authProvider = authProvider {
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
      await Future.delayed(const Duration(milliseconds: 500));
      _items = [];
      _status = _items.isEmpty ? WishlistStatus.empty : WishlistStatus.loaded;
    } catch (e) {
      _errorMessage = "獲取收藏清單失敗: $e";
      _status = WishlistStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> addToWishlist(dynamic product) async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;

    try {
      _items.add(product);
      notifyListeners();
    } catch (e) {
      _errorMessage = "加入收藏失敗: $e";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    try {
      _items.removeWhere((item) => item.id == productId);
      notifyListeners();
    } catch (e) {
      _errorMessage = "移除收藏失敗: $e";
      notifyListeners();
      rethrow;
    }
  }

  bool isProductInWishlist(dynamic product) {
    return _items.any((item) => item.id == product.id);
  }
}