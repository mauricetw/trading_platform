// --- FILE: lib/services/user_service.dart ---
import '../models/user/user.dart';
import 'api_client.dart';
import '../config/api_config.dart';

class UserService {
  final ApiClient _apiClient;
  UserService(this._apiClient);

  /// 獲取當前登入使用者的完整個人資料。
  Future<User> getMyProfile() async {
    final responseBody = await _apiClient.get('/users/me');
    return User.fromJson(responseBody);
  }

  /// 根據 ID 獲取其他使用者的公開個人資料。
  Future<User> getUserProfileById(String userId) async {
    final responseBody = await _apiClient.get('/users/$userId');
    return User.fromJson(responseBody['user']);
  }

  /// 更新當前登入使用者的個人資料。
  /// [updateData]: 一個 Map，只包含需要更新的欄位
  Future<User> updateMyProfile(Map<String, dynamic> updateData) async {
    final responseBody = await _apiClient.put(
        '/users/me',
        body: updateData
    );
    return User.fromJson(responseBody);
  }
}
