import 'package:flutter/foundation.dart';
import '../models/wishpool/wishpool.dart';
import 'api_client.dart';

class WishPoolService {
  final ApiClient _apiClient;

  // 如果你在 main.dart 是用 WishPoolService() 初始化的，
  // 你可能需要一個方式注入 ApiClient，或者直接在這裡實例化 (視你的架構而定)。
  // 這裡假設透過建構子傳入 (推薦)，或者在 main.dart 中調整 Provider。
  // 為了配合你 main.dart 裡的 `create: (_) => WishPoolProvider(WishPoolService()),`
  // 暫時假設 ApiClient 是單例或內部獲取的，但最好的做法是像 OrderService 那樣傳入。
  WishPoolService([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  /// 獲取所有許願單 (瀏覽頁面)
  Future<List<WishPool>> getAllWishes() async {
    try {
      final response = await _apiClient.get('/wishpool');
      final List<dynamic> data = response;
      return data.map((json) => WishPool.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[WishPoolService] 獲取許願單失敗: $e');
      rethrow;
    }
  }

  /// 獲取單一許願單詳情
  Future<WishPool> getWishById(int id) async {
    try {
      final response = await _apiClient.get('/wishpool/$id');
      return WishPool.fromJson(response);
    } catch (e) {
      debugPrint('[WishPoolService] 獲取許願單詳情失敗: $e');
      rethrow;
    }
  }

  /// 建立許願單 (買家)
  Future<WishPool> createWish(Map<String, dynamic> wishData) async {
    try {
      final response = await _apiClient.post('/wishpool', body: wishData);
      return WishPool.fromJson(response);
    } catch (e) {
      debugPrint('[WishPoolService] 建立許願單失敗: $e');
      rethrow;
    }
  }

  /// 更新許願單 (買家)
  Future<WishPool> updateWish(int id, Map<String, dynamic> wishData) async {
    try {
      final response = await _apiClient.put('/wishpool/$id', body: wishData);
      return WishPool.fromJson(response);
    } catch (e) {
      debugPrint('[WishPoolService] 更新許願單失敗: $e');
      rethrow;
    }
  }

  /// 刪除許願單 (買家)
  Future<void> deleteWish(int id) async {
    try {
      await _apiClient.delete('/wishpool/$id');
    } catch (e) {
      debugPrint('[WishPoolService] 刪除許願單失敗: $e');
      rethrow;
    }
  }

  /// 收藏許願單 (我也想要)
  Future<void> favoriteWish(int id) async {
    try {
      await _apiClient.post('/wishpool/$id/favorite');
    } catch (e) {
      debugPrint('[WishPoolService] 收藏失敗: $e');
      rethrow;
    }
  }

  /// 取消收藏
  Future<void> unfavoriteWish(int id) async {
    try {
      await _apiClient.delete('/wishpool/$id/favorite');
    } catch (e) {
      debugPrint('[WishPoolService] 取消收藏失敗: $e');
      rethrow;
    }
  }
}