// --- FILE: lib/providers/auth_provider.dart ---
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user/user.dart';
import '../models/auth/auth_response.dart';
import '../services/api_service.dart'; // 確保路徑正確

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _currentUser != null;

  // --- 登入 ---
  Future<void> login(String identifier, String password) async {
    try {
      final authResponse = await _apiService.login(identifier, password);
      await _handleAuthSuccess(authResponse);
    } catch (e) {
      // 將 API 錯誤向上拋出，讓 UI 層可以捕捉並顯示
      rethrow;
    }
  }

  // --- 新增：發送註冊驗證碼 ---
  Future<void> sendVerificationCode(String email) async {
    try {
      await _apiService.sendVerificationCode(email);
    } catch (e) {
      rethrow;
    }
  }

  // --- 修改後的註冊方法 ---
  Future<void> register(String username, String email, String password, String code) async {
    try {
      final authResponse = await _apiService.registerUser(username, email, password, code);
      await _handleAuthSuccess(authResponse);
    } catch (e) {
      rethrow;
    }
  }

  // --- 處理登入/註冊成功後的通用邏輯 ---
  Future<void> _handleAuthSuccess(AuthResponse authResponse) async {
    _currentUser = authResponse.user;
    _token = authResponse.token.accessToken;

    // 將 token 傳遞給 ApiService 供後續所有請求使用
    _apiService.setAuthToken(_token);

    // 將 token 安全地儲存在手機的 Keychain/Keystore 中
    await _storage.write(key: 'auth_token', value: _token);

    // 通知所有正在監聽的 Widget 更新 UI
    notifyListeners();
  }

  // --- App 啟動時嘗試自動登入 ---
  Future<bool> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'auth_token');

    if (storedToken == null) {
      return false;
    }

    _token = storedToken;
    _apiService.setAuthToken(_token);

    try {
      // 透過儲存的 token 獲取最新的使用者資料
      final user = await _apiService.getMyProfile();
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      // 如果 token 失效或網路錯誤，則清除舊的 token 並登出
      await logout();
      return false;
    }
  }

  // --- 更新使用者資料 ---
  Future<void> updateUserProfile({
    required String username,
    required String bio,
    required String schoolName,
    required String avatarUrl,
  }) async {
    if (!isLoggedIn) return;

    try {
      final updatedUser = await _apiService.updateUserProfile(
        username: username,
        bio: bio,
        schoolName: schoolName,
        avatarUrl: avatarUrl,
      );
      // 成功後，更新 Provider 內部保存的 user 資料
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // --- 登出 ---
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _apiService.setAuthToken(null);
    await _storage.delete(key: 'auth_token');
    notifyListeners();
  }
}
