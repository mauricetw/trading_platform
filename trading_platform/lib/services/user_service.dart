// --- FILE: lib/services/user_service.dart ---
import '../models/user/user.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _apiClient;
  // UserService 現在依賴於 ApiClient 來完成任務
  UserService(this._apiClient);

  /// 獲取當前登入使用者的完整個人資料。
  ///
  /// 此方法會呼叫後端的 `/users/me` 端點。
  /// 成功時回傳一個完整的 `User` 物件。
  /// 如果使用者未登入或 token 失效，ApiClient 會拋出 ApiException。
  Future<User> getMyProfile() async {
    final responseBody = await _apiClient.get('/users/me');
    return User.fromJson(responseBody);
  }

  /// 更新當前登入使用者的個人資料。
  ///
  /// 此方法會呼叫後端的 `PUT /users/me` 端點。
  /// [username], [bio], [schoolName], [avatarUrl] 是要更新的欄位。
  /// 成功時回傳更新後的 `User` 物件。
  Future<User> updateUserProfile({
    required String username,
    required String bio,
    required String schoolName,
    required String avatarUrl,
  }) async {
    final responseBody = await _apiClient.put(
        '/users/me',
        body: {
          'nickname': username,
          'bio': bio,
          'school_name': schoolName, // 注意：key 使用蛇形命名以匹配後端
          'avatar_url': avatarUrl,
        }
    );
    return User.fromJson(responseBody);
  }

  /// 根據 ID 獲取任何使用者的公開個人資料。
  ///
  /// 此方法會呼叫後端的 `/users/{userId}` 端點。
  /// 成功時回傳一個 `User` 物件。
  /// 注意：後端回傳的 JSON 結構是 `{"user": {...}}`，因此我們需要從中提取 'user'。
  Future<User> getUserProfile(int userId) async {
    final responseBody = await _apiClient.get('/users/$userId');
    // 後端回傳的是 {"user": {...}}，所以要從 'user' key 取出資料
    return User.fromJson(responseBody['user']);
  }
}
