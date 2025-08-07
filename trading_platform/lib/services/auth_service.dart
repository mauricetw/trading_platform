import 'dart:convert';
import 'package:flutter/foundation.dart'; // 使用 debugPrint 需要
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // 用於本地存儲 token
import '../config/api_config.dart'; // 【【新增】】引入 APIConfig

class AuthService {
  // 【【修改】】從 APIConfig 獲取 baseUrl
  final String _baseUrl = APIConfig.baseUrl;
  static const String _tokenKey = 'user_auth_token'; // 用於 SharedPreferences 的鍵
  static const String _userIdKey = 'user_id_key'; // 【【可選】】用於存儲用戶 ID

  // 登入方法
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // 檢查連接可用性 - 這部分可以保留，但真實 API 調用時，如果 API 本身不通，後續請求也會失敗
      // final testResponse = await http.get(Uri.parse('https://www.google.com'));
      // if (testResponse.statusCode != 200) {
      //   return {
      //     'success': false,
      //     'message': '網絡連接有問題，請檢查您的網絡',
      //   };
      // }

      final loginUrl = Uri.parse('$_baseUrl/auth/login'); // 【【修改】】假設登錄端點是 /auth/login
      debugPrint('正在發送登入請求到: $loginUrl');
      debugPrint('用戶名: $username'); // 密碼通常不在生產日誌中打印

      final response = await http.post(
        loginUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // 推薦添加 charset
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username, // 或 'email'，根據後端要求
          'password': password,
        }),
      );

      debugPrint('API 回應狀態碼: ${response.statusCode}');
      debugPrint('API 回應內容 (登入): ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {
            'success': false, // 登錄成功通常需要返回 token
            'message': '登入成功但沒有返回數據 (例如 token)',
          };
        }
        try {
          final responseData = jsonDecode(response.body);

          // 【【新增】】假設後端返回的 JSON 中包含 'token' 和可選的 'userId'
          final String? token = responseData['token'] as String?;
          final String? userId = responseData['userId'] as String?; // 或 'user_id', 'id' 等

          if (token != null) {
            await _saveToken(token);
            if (userId != null) {
              await _saveUserId(userId); // 【【可選】】保存用戶 ID
            }
            return {
              'success': true,
              'data': responseData, // 可以將整個響應數據返回給調用者
            };
          } else {
            return {
              'success': false,
              'message': '登入成功，但未在回應中找到 token',
            };
          }
        } catch (e) {
          debugPrint('JSON 解析或 Token 保存錯誤: $e');
          return {
            'success': false, // 解析錯誤意味著無法獲取 token
            'message': '登入回應解析錯誤: $e',
          };
        }
      } else {
        String errorMessage = '登入失敗: 狀態碼 ${response.statusCode}';
        try {
          if (response.body.isNotEmpty && (response.body.trim().startsWith('{') || response.body.trim().startsWith('['))) {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          }
        } catch (e) {
          // 忽略解析錯誤，使用默認錯誤信息
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      debugPrint('網絡或其他錯誤 (登入): $e');
      return {
        'success': false,
        'message': '連接伺服器時出現問題: $e',
      };
    }
  }

  // --- 【【新增】】Token 和 UserId 管理方法 ---
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    debugPrint("Token saved: $token");
  }

  Future<void> _saveUserId(String userId) async { // 【【可選】】
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    debugPrint("UserId saved: $userId");
  }

  Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    // debugPrint("Retrieved token: $token"); // 避免在每次獲取時都打印 token
    return token;
  }

  Future<String?> getUserId() async { // 【【可選】】
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey); // 【【可選】】同時移除用戶 ID
    debugPrint("Token and UserId removed on logout.");
    // 在這裡，您可能還想清除應用程序中的其他用戶特定狀態，
    // 例如，通過調用 AuthProvider 或類似的狀態管理器來通知 UI 用戶已登出。
  }

  Future<bool> isLoggedIn() async {
    final token = await getUserToken();
    return token != null && token.isNotEmpty;
  }

  // 如果不能連接真實 API，可以使用此模擬方法 (可以保留用於測試)
  Future<Map<String, dynamic>> mockLogin(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (username == 'admin' && password == 'password') {
      const mockToken = 'mock_admin_jwt_token';
      const mockUserId = 'admin123';
      await _saveToken(mockToken);
      await _saveUserId(mockUserId);
      return {
        'success': true,
        'data': {
          'token': mockToken,
          'userId': mockUserId,
          'username': 'admin',
          'role': 'administrator',
        },
      };
    } else if (username.isEmpty) {
      return {'success': false, 'message': '使用者帳號不存在'};
    } else if (password.isEmpty || password != 'password') {
      return {'success': false, 'message': '密碼錯誤'};
    } else {
      return {'success': false, 'message': '登入失敗，請檢查帳號和密碼'};
    }
  }
}
