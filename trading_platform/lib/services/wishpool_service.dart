import 'package:flutter/foundation.dart';
import '../models/wishpool/wishpool.dart';
import 'api_client.dart';

class WishPoolService {
  final ApiClient _apiClient;

  WishPoolService([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  // ... (其他方法保持不變，get, create, update, delete...)

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
  Future<WishPool> getWishById(int id) async {
    try {
      final response = await _apiClient.get('/wishpool/$id');
      return WishPool.fromJson(response);
    } catch (e) {
      debugPrint('[WishPoolService] 獲取許願單詳情失敗: $e');
      rethrow;
    }
  }
  Future<WishPool> createWish(Map<String, dynamic> wishData) async {
    try {
      final response = await _apiClient.post('/wishpool', body: wishData);
      return WishPool.fromJson(response);
    } catch (e) {
      debugPrint('[WishPoolService] 建立許願單失敗: $e');
      rethrow;
    }
  }
  Future<WishPool> updateWish(int id, Map<String, dynamic> wishData) async {
    try {
      final response = await _apiClient.put('/wishpool/$id', body: wishData);
      return WishPool.fromJson(response);
    } catch (e) {
      debugPrint('[WishPoolService] 更新許願單失敗: $e');
      rethrow;
    }
  }
  Future<void> deleteWish(int id) async {
    try {
      await _apiClient.delete('/wishpool/$id');
    } catch (e) {
      debugPrint('[WishPoolService] 刪除許願單失敗: $e');
      rethrow;
    }
  }
  Future<void> favoriteWish(int id) async {
    try {
      await _apiClient.post('/wishpool/$id/favorite');
    } catch (e) {
      debugPrint('[WishPoolService] 收藏失敗: $e');
      rethrow;
    }
  }
  Future<void> unfavoriteWish(int id) async {
    try {
      await _apiClient.delete('/wishpool/$id/favorite');
    } catch (e) {
      debugPrint('[WishPoolService] 取消收藏失敗: $e');
      rethrow;
    }
  }

  /// [修改] 賣家接單
  /// 支援兩種模式：
  /// 1. [productId] 不為空 -> 使用現有商品
  /// 2. [productId] 為空 -> 快速接單 (需後端支援)
  Future<WishPool> fulfillWish(int wishId, {int? productId, String? newProductName}) async {
    try {
      final Map<String, dynamic> body = {};

      if (productId != null) {
        body['product_id'] = productId;
      } else {
        // 快速接單模式
        body['product_id'] = null;
        if (newProductName != null) {
          body['new_product_name'] = newProductName;
        }
      }

      final response = await _apiClient.post('/wishpool/$wishId/fulfill', body: body);
      return WishPool.fromJson(response);
    } catch (e) {
      debugPrint('[WishPoolService] 接單失敗: $e');
      rethrow;
    }
  }
}