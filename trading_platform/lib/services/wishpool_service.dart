import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wishpool/wishpool.dart';
import '../../config/api_config.dart';

class WishPoolService {
  final String baseUrl = '${APIConfig.baseUrl}/wishpools';

  /// 取得所有願望池資料
  Future<List<WishPool>> fetchAll() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => WishPool.fromJson(e)).toList();
    } else {
      throw Exception('取得願望池失敗 (${res.statusCode})');
    }
  }

  /// 根據 ID 取得單筆願望
  Future<WishPool> fetchById(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/$id'));
    if (res.statusCode == 200) {
      return WishPool.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('找不到願望 #$id');
    }
  }

  /// 新增願望
  Future<WishPool> create(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return WishPool.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('建立願望失敗');
    }
  }

  /// 刪除願望
  Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('刪除願望失敗');
    }
  }

  /// 收藏 / 取消收藏願望
  Future<void> toggleFavorite(int wishPoolId, int userId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$wishPoolId/favorite'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );
    if (res.statusCode != 200) {
      throw Exception('操作收藏失敗');
    }
  }

  /// 賣家對願望提出邀請
  Future<void> sendInvite({
    required int wishPoolId,
    required int sellerId,
    required int productId,
    String? message,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$wishPoolId/invite'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'seller_id': sellerId,
        'product_id': productId,
        'message': message,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('邀請失敗 (${res.statusCode})');
    }
  }

  Future<WishPool> update(int id, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) {
      return WishPool.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('更新願望失敗 (${res.statusCode})');
    }
  }

}

