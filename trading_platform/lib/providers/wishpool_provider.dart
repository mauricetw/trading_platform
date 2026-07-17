import 'package:flutter/foundation.dart';
import '../models/wishpool/wishpool.dart';
import '../services/wishpool_service.dart';

class WishPoolProvider with ChangeNotifier {
  final WishPoolService _service;
  List<WishPool> _wishPools = [];
  bool _isLoading = false;
  String? _error;

  WishPoolProvider(this._service);

  List<WishPool> get wishPools => _wishPools;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ... (load, add, update, remove, favorite, unfavorite 保持不變) ...

  Future<void> loadWishPools() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _wishPools = await _service.getAllWishes();
    } catch (e) {
      _error = '載入 WishPool 失敗: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> addWishPool(Map<String, dynamic> body) async {
    try {
      final newWish = await _service.createWish(body);
      _wishPools.insert(0, newWish);
      notifyListeners();
    } catch (e) {
      debugPrint('新增 WishPool 失敗: $e');
      rethrow;
    }
  }
  Future<void> updateWishPool(int id, Map<String, dynamic> body) async {
    try {
      final updatedWish = await _service.updateWish(id, body);
      final index = _wishPools.indexWhere((w) => w.id == id);
      if (index != -1) {
        _wishPools[index] = updatedWish;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('更新 WishPool 失敗: $e');
      rethrow;
    }
  }
  Future<void> removeWishPool(int id) async {
    try {
      await _service.deleteWish(id);
      _wishPools.removeWhere((w) => w.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('刪除 WishPool 失敗: $e');
      rethrow;
    }
  }
  Future<void> favoriteWish(int id) async {
    try {
      await _service.favoriteWish(id);
    } catch (e) {
      debugPrint('收藏 WishPool 失敗: $e');
      rethrow;
    }
  }
  Future<void> unfavoriteWish(int id) async {
    try {
      await _service.unfavoriteWish(id);
    } catch (e) {
      debugPrint('取消收藏 WishPool 失敗: $e');
      rethrow;
    }
  }

  /// [修改] 賣家接單
  Future<void> fulfillWish(int wishId, {int? productId, String? newProductName}) async {
    try {
      final updatedWish = await _service.fulfillWish(wishId, productId: productId, newProductName: newProductName);
      // 更新列表中的狀態
      final index = _wishPools.indexWhere((w) => w.id == wishId);
      if (index != -1) {
        _wishPools[index] = updatedWish;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('接單失敗: $e');
      rethrow;
    }
  }
}