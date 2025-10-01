// --- FILE: lib/providers/wishlist_provider.dart ---
import 'package:flutter/foundation.dart';
import 'dart:collection'; // 用於 HashSet

import '../models/user/wishlist_item.dart';
import '../models/product/product.dart';
import '../services/wishlist_service.dart';
import 'auth_provider.dart';

enum WishlistStatus { initial, loading, loaded, empty, error }

class WishlistProvider with ChangeNotifier {
  final WishlistService _wishlistService;
  AuthProvider? _authProvider;

  List<WishlistItem> _items = [];
  HashSet<int> _productIds = HashSet<int>();

  WishlistStatus _status = WishlistStatus.initial;
  String _errorMessage = '';

  // --- Getters ---
  List<WishlistItem> get items => _items;
  WishlistStatus get status => _status;
  String get errorMessage => _errorMessage;

  bool isFavorite(int productId) => _productIds.contains(productId);

  WishlistProvider(this._wishlistService, this._authProvider) {
    _updateDependencies();
  }

  void update(AuthProvider newAuthProvider) {
    if (newAuthProvider.isLoggedIn != _authProvider?.isLoggedIn) {
      _authProvider = newAuthProvider;
      _updateDependencies();
    }
  }

  void _updateDependencies() {
    if (_authProvider?.isLoggedIn == true) {
      fetchWishlistItems();
    } else {
      _items = [];
      _productIds = HashSet<int>();
      _status = WishlistStatus.initial;
      notifyListeners();
    }
  }

  Future<void> fetchWishlistItems({bool forceRefresh = false}) async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;
    if (_status == WishlistStatus.loading && !forceRefresh) return;

    _status = WishlistStatus.loading;
    notifyListeners();

    try {
      final fetchedItems = await _wishlistService.getWishlistItems();
      _items = fetchedItems;
      _productIds = HashSet<int>.from(fetchedItems.map((item) => item.productId));
      _status = _items.isEmpty ? WishlistStatus.empty : WishlistStatus.loaded;
    } catch (e) {
      _errorMessage = "無法載入收藏清單: $e";
      _status = WishlistStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> addToWishlist(int productId, {Product? product}) async {
    if (isFavorite(productId)) return;

    _productIds.add(productId);
    if (product != null) {
      _items.add(WishlistItem(
          id: 0,
          userId: 0,
          productId: productId,
          // --- 關鍵修正：將 createdAt 修正為 addedAt ---
          addedAt: DateTime.now(),
          product: product
      ));
      _status = WishlistStatus.loaded;
    }
    notifyListeners();

    try {
      final newItem = await _wishlistService.addToWishlist(productId);
      final index = _items.indexWhere((item) => item.productId == productId);
      if (index != -1) {
        _items[index] = newItem;
      } else {
        _items.add(newItem);
      }
    } catch (e) {
      _productIds.remove(productId);
      _items.removeWhere((item) => item.productId == productId);
      if (_items.isEmpty) _status = WishlistStatus.empty;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    if (!isFavorite(productId)) return;

    final backupItemIndex = _items.indexWhere((item) => item.productId == productId);
    WishlistItem? backupItem;
    if (backupItemIndex != -1) {
      backupItem = _items.removeAt(backupItemIndex);
    }
    _productIds.remove(productId);
    if (_items.isEmpty) _status = WishlistStatus.empty;
    notifyListeners();

    try {
      await _wishlistService.removeFromWishlist(productId);
    } catch (e) {
      _productIds.add(productId);
      if (backupItem != null && backupItemIndex != -1) {
        _items.insert(backupItemIndex, backupItem);
      }
      _status = WishlistStatus.loaded;
      notifyListeners();
      rethrow;
    }
  }
}
