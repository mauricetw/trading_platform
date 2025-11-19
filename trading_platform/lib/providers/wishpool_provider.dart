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

  /// 載入願望池列表
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

  /// 新增願望
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

  /// 更新願望
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

  /// 刪除願望
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

  /// 收藏願望 (目前僅實作 API 呼叫)
  Future<void> favoriteWish(int id) async {
    try {
      await _service.favoriteWish(id);
      // 這裡可以優化：本地更新 likeCount + 1
    } catch (e) {
      debugPrint('收藏 WishPool 失敗: $e');
      rethrow;
    }
  }

  /// 取消收藏
  Future<void> unfavoriteWish(int id) async {
    try {
      await _service.unfavoriteWish(id);
      // 這裡可以優化：本地更新 likeCount - 1
    } catch (e) {
      debugPrint('取消收藏 WishPool 失敗: $e');
      rethrow;
    }
  }
}
