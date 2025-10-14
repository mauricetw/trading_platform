import 'package:flutter/foundation.dart';
import '../models/wishpool/wishpool.dart';
import '../services/wishpool_service.dart';

class WishPoolProvider with ChangeNotifier {
  final WishPoolService _service;
  List<WishPool> _wishPools = [];
  bool _isLoading = false;

  WishPoolProvider(this._service);

  List<WishPool> get wishPools => _wishPools;
  bool get isLoading => _isLoading;

  /// 載入願望池列表
  Future<void> loadWishPools() async {
    _isLoading = true;
    notifyListeners();

    try {
      _wishPools = await _service.fetchAll();
    } catch (e) {
      debugPrint('載入 WishPool 失敗: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 新增願望
  Future<void> addWishPool(Map<String, dynamic> body) async {
    try {
      final newWish = await _service.create(body);
      _wishPools.insert(0, newWish);
      notifyListeners();
    } catch (e) {
      debugPrint('新增 WishPool 失敗: $e');
    }
  }

  /// 刪除願望
  Future<void> removeWishPool(int id) async {
    try {
      await _service.delete(id);
      _wishPools.removeWhere((w) => w.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('刪除 WishPool 失敗: $e');
    }
  }

  /// 收藏願望
  Future<void> toggleFavorite(int wishPoolId, int userId) async {
    try {
      await _service.toggleFavorite(wishPoolId, userId);
      // 可根據需要更新 UI 狀態（例如 likeCount++）
    } catch (e) {
      debugPrint('收藏 WishPool 失敗: $e');
    }
  }

  /// 發送邀請（賣家端）
  Future<void> sendInvite({
    required int wishPoolId,
    required int sellerId,
    required int productId,
    String? message,
  }) async {
    try {
      await _service.sendInvite(
        wishPoolId: wishPoolId,
        sellerId: sellerId,
        productId: productId,
        message: message,
      );
    } catch (e) {
      debugPrint('發送邀請失敗: $e');
    }
  }

  Future<void> updateWishPool(int id, Map<String, dynamic> body) async {
    try {
      final updatedWish = await _service.update(id, body);
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

}

