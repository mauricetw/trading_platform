import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../models/wishpool/wishpool_invite.dart';

class WishPoolInviteService {
  final String baseUrl = '${APIConfig.baseUrl}/wishpool_invites';

  /// 取得使用者收到的邀請
  Future<List<WishPoolInvite>> fetchReceivedInvites(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl?receiver_id=$userId'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => WishPoolInvite.fromJson(e)).toList();
    } else {
      throw Exception('無法取得邀請清單 (${res.statusCode})');
    }
  }

  /// 取得賣家發出的邀請
  Future<List<WishPoolInvite>> fetchSentInvites(int sellerId) async {
    final res = await http.get(Uri.parse('$baseUrl?seller_id=$sellerId'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => WishPoolInvite.fromJson(e)).toList();
    } else {
      throw Exception('無法取得發出邀請 (${res.statusCode})');
    }
  }

  /// 建立邀請（賣家發送）
  Future<WishPoolInvite> createInvite({
    required int wishPoolId,
    required int sellerId,
    required int productId,
    String? message,
  }) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'wish_pool_id': wishPoolId,
        'seller_id': sellerId,
        'product_id': productId,
        'message': message,
      }),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return WishPoolInvite.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('建立邀請失敗 (${res.statusCode})');
    }
  }

  /// 回覆邀請（買家端接受 / 拒絕）
  Future<void> respondInvite({
    required int inviteId,
    required String response, // 'accepted' or 'rejected'
  }) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/$inviteId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': response}),
    );
    if (res.statusCode != 200) {
      throw Exception('邀請回覆失敗 (${res.statusCode})');
    }
  }
}
