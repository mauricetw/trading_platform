import 'package:flutter/foundation.dart';
import '../models/wishpool/wishpool_invite.dart';
import 'api_client.dart';

class WishPoolInviteService {
  final ApiClient _apiClient;

  WishPoolInviteService([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  /// 發送邀請/報價 (賣家)
  /// [productId] 現在是可選的
  Future<WishPoolInvite> sendInvite(int wishPoolId, String message, {int? productId}) async {
    try {
      final body = {
        'message': message,
        // 只有當 productId 有值時才傳送，或者傳送 null (視後端需求，這裡直接放入 map 會是 null)
        'product_id': productId,
      };
      final response = await _apiClient.post('/wishpool/$wishPoolId/invite', body: body);
      return WishPoolInvite.fromJson(response);
    } catch (e) {
      debugPrint('[WishPoolInviteService] 發送邀請失敗: $e');
      rethrow;
    }
  }

  /// 獲取我收到的所有邀請 (買家)
  Future<List<WishPoolInvite>> getReceivedInvites() async {
    try {
      final response = await _apiClient.get('/wishpool/invites/received');
      final List<dynamic> data = response;
      return data.map((json) => WishPoolInvite.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[WishPoolInviteService] 獲取收到邀請失敗: $e');
      rethrow;
    }
  }

  /// [新功能] 獲取我發出的所有邀請 (賣家)
  Future<List<WishPoolInvite>> getSentInvites() async {
    try {
      final response = await _apiClient.get('/wishpool/invites/sent');
      final List<dynamic> data = response;
      return data.map((json) => WishPoolInvite.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[WishPoolInviteService] 獲取已發送邀請失敗: $e');
      rethrow;
    }
  }

  /// 接受邀請 (買家)
  Future<WishPoolInvite> acceptInvite(int inviteId) async {
    try {
      final response = await _apiClient.patch('/wishpool/invites/$inviteId/accept');
      return WishPoolInvite.fromJson(response);
    } catch (e) {
      debugPrint('[WishPoolInviteService] 接受邀請失敗: $e');
      rethrow;
    }
  }

  /// 拒絕邀請 (買家)
  Future<WishPoolInvite> rejectInvite(int inviteId) async {
    try {
      final response = await _apiClient.patch('/wishpool/invites/$inviteId/reject');
      return WishPoolInvite.fromJson(response);
    } catch (e) {
      debugPrint('[WishPoolInviteService] 拒絕邀請失敗: $e');
      rethrow;
    }
  }
}