import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth/auth_response.dart';

class AuthService {
  final String baseUrl = "http://10.0.2.2:8000";

  /// 檢查HTTP狀態碼是否為成功
  bool _isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// 處理使用者登入
  ///
  /// 傳入使用者名稱/Email 和密碼，成功後回傳 AuthResponse。
  Future<AuthResponse> login(String identifier, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "login": identifier,
          "password": password,
        }),
      );

      if (_isSuccessStatusCode(response.statusCode)) {
        Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return AuthResponse.fromJson(responseData);
      } else {
        Map<String, dynamic> errorData;
        try {
          errorData = jsonDecode(utf8.decode(response.bodyBytes));
        } catch (e) {
          errorData = {
            "detail": "無法解析伺服器錯誤訊息 (狀態碼: ${response.statusCode})",
          };
        }
        throw Exception(errorData["detail"] ?? "登入失敗，請檢查您的帳號或密碼。");
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception("無法連接伺服器。請檢查網路連線。");
    }
  }

  /// 發送註冊用的電子郵件驗證碼
  ///
  /// 傳入電子郵件地址，後端將發送驗證碼郵件。
  Future<void> sendVerificationCode(String email) async {
    final url = Uri.parse('$baseUrl/auth/send-verification-code');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'email': email}),
      );

      if (_isSuccessStatusCode(response.statusCode)) {
        return; // 成功發送
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['detail'] ?? '發送驗證碼失敗 (狀態碼: ${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('伺服器連線失敗或請求處理出錯：$e');
    }
  }

  /// 處理使用者註冊
  ///
  /// 傳入使用者名稱、Email、密碼和驗證碼，成功後回傳 AuthResponse。
  ///
  /// **關鍵修復**: 現在接受所有2xx狀態碼（200-299），包括201 Created
  Future<AuthResponse> register(String username, String email, String password, String code) async {
    final url = Uri.parse('$baseUrl/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
          "code": code,
        }),
      );

      // 修復：接受所有成功狀態碼 (200-299)，而不只是200
      if (_isSuccessStatusCode(response.statusCode)) {
        Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return AuthResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        String errorMessage;
        if (errorData["detail"] is List) {
          errorMessage = errorData["detail"].join(", ");
        } else {
          errorMessage = errorData["detail"] ?? "註冊時發生未知錯誤";
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception("無法連線到伺服器，請檢查您的網路連線。");
    }
  }

  /// 請求發送忘記密碼驗證碼
  ///
  /// 成功後回傳後端發送的確認訊息。
  Future<String> forgotPassword(String identifier) async {
    final url = Uri.parse('$baseUrl/auth/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'login': identifier}),
      );

      if (_isSuccessStatusCode(response.statusCode)) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return responseData['message'] ?? '驗證信發送成功';
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['detail'] ?? '發送驗證信失敗 (狀態碼: ${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('伺服器連線失敗或請求處理出錯：$e');
    }
  }

  /// 驗證忘記密碼流程中的驗證碼
  ///
  /// 成功後回傳一個一次性的重設密碼 Token。
  Future<String> verifyCode(String login, String code) async {
    final url = Uri.parse('$baseUrl/auth/verify-code');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'login': login, 'code': code}),
      );

      if (_isSuccessStatusCode(response.statusCode)) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return responseData['reset_token'] ?? responseData['token'];
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['detail'] ?? '驗證碼錯誤或已過期 (狀態碼: ${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('伺服器連線失敗或請求處理出錯：$e');
    }
  }

  /// 使用 token 重設密碼
  ///
  /// 成功後回傳後端發送的確認訊息。
  Future<String> resetPassword(String token, String newPassword) async {
    final url = Uri.parse('$baseUrl/auth/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "new_password": newPassword,
        }),
      );

      if (_isSuccessStatusCode(response.statusCode)) {
        if (response.body.isNotEmpty) {
          final responseData = jsonDecode(utf8.decode(response.bodyBytes));
          return responseData['message'] ?? '密碼重設成功';
        }
        return '密碼重設成功';
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['detail'] ?? '重設密碼失敗 (狀態碼: ${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('伺服器連線失敗或請求處理出錯：$e');
    }
  }
}