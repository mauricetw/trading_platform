// --- FILE: lib/services/auth_service.dart ---
import '../models/auth/auth_response.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  // AuthService 現在依賴於 ApiClient 來完成所有網路任務
  AuthService(this._apiClient);

  /// 處理使用者登入
  Future<AuthResponse> login(String identifier, String password) async {
    // 將請求轉發給 ApiClient
    final responseBody = await _apiClient.post(
      '/auth/login',
      body: {"login": identifier, "password": password},
    );
    // 將 ApiClient 回傳的 JSON 資料轉換為強型別的 AuthResponse 物件
    return AuthResponse.fromJson(responseBody);
  }

  /// 發送註冊用的電子郵件驗證碼
  Future<void> sendVerificationCode(String email) async {
    await _apiClient.post(
      '/auth/send-verification-code',
      body: {'email': email},
    );
  }

  /// 處理使用者註冊
  Future<AuthResponse> register(String username, String email, String password, String code) async {
    final responseBody = await _apiClient.post(
      '/auth/register',
      body: {
        "nickname": username, // 確保 key 與後端 UserCreate schema 的 nickname 匹配
        "email": email,
        "password": password,
        "code": code,
      },
    );
    return AuthResponse.fromJson(responseBody);
  }

  /// 請求發送忘記密碼驗證碼
  Future<String> forgotPassword(String identifier) async {
    final responseBody = await _apiClient.post(
      '/auth/forgot-password',
      body: {'login': identifier},
    );
    return responseBody['message'];
  }

  /// 驗證忘記密碼流程中的驗證碼
  Future<String> verifyCode(String login, String code) async {
    final responseBody = await _apiClient.post(
      '/auth/verify-code',
      body: {'login': login, 'code': code},
    );
    return responseBody['reset_token'];
  }

  /// 使用 token 重設密碼
  Future<String> resetPassword(String token, String newPassword) async {
    final responseBody = await _apiClient.post(
      '/auth/reset-password',
      body: {
        "token": token,
        "new_password": newPassword,
      },
    );
    return responseBody['message'];
  }
}
