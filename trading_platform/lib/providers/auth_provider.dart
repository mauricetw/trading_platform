import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user/user.dart';
import '../models/auth/auth_response.dart';
import '../api_service.dart'; // 引入 ApiService

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
      _handleAuthSuccess(authResponse);
    } catch (e) {
      // 讓 UI 層去處理顯示錯誤
      rethrow;
    }
  }

  // --- 註冊 ---
  Future<void> register(String username, String email, String password) async {
    try {
      final authResponse = await _apiService.registerUser(username, email, password);
      _handleAuthSuccess(authResponse);
    } catch (e) {
      rethrow;
    }
  }

  // --- 處理登入/註冊成功後的通用邏輯 ---
  Future<void> _handleAuthSuccess(AuthResponse authResponse) async {
    _currentUser = authResponse.user;
    _token = authResponse.token.accessToken;

    // 將 token 傳遞給 ApiService 供後續請求使用
    _apiService.setAuthToken(_token);

    // 將 token 安全地儲存在手機上
    await _storage.write(key: 'auth_token', value: _token);

    // 通知所有監聽者，狀態已更新
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
      // 透過 token 獲取最新的使用者資料
      final user = await _apiService.getMyProfile();
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      // 如果 token 失效或網路錯誤，則登出
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
      // 更新 provider 內的 user 資料
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
