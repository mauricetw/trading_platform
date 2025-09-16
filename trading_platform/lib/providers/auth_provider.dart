// --- FILE: lib/providers/auth_provider.dart ---
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user/user.dart';
import '../models/auth/auth_response.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _currentUser != null;

  AuthProvider(this._authService, this._userService, this._apiClient);

  // --- 內部輔助方法，作為獲取使用者資料的唯一入口 ---
  Future<void> _fetchAndSetCurrentUser() async {
    try {
      // 透過 UserService 獲取最新的使用者資料
      final user = await _userService.getMyProfile();
      _currentUser = user;
    } catch (e) {
      // 如果獲取失敗 (例如 token 過期)，則登出
      await logout();
      rethrow; // 重新拋出錯誤，讓呼叫者知道發生了問題
    }
  }

  // --- 處理登入/註冊成功後的通用邏輯 ---
  Future<void> _handleAuthSuccess(AuthResponse authResponse) async {
    // 1. 先設定 token
    _token = authResponse.token.accessToken;
    _apiClient.setAuthToken(_token);
    await _storage.write(key: 'auth_token', value: _token);

    // 2. 使用新的 token 來獲取完整的使用者資料
    //    這裡不再使用 authResponse.user，因為它可能不是最新的
    await _fetchAndSetCurrentUser();

    // 3. 通知 UI 更新
    notifyListeners();
  }

  // --- 公開方法 ---

  Future<void> login(String identifier, String password) async {
    try {
      final authResponse = await _authService.login(identifier, password);
      // _handleAuthSuccess 會處理後續所有事情
      await _handleAuthSuccess(authResponse);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password, String code) async {
    try {
      // 註冊成功後，後端回傳的結構與登入相同
      final authResponse = await _authService.register(username, email, password, code);
      await _handleAuthSuccess(authResponse);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'auth_token');
    if (storedToken == null) return false;

    _token = storedToken;
    _apiClient.setAuthToken(_token);

    try {
      // 重用獲取使用者的邏輯
      await _fetchAndSetCurrentUser();
      notifyListeners();
      return true;
    } catch (e) {
      // 如果自動登入失敗 (token 失效)，_fetchAndSetCurrentUser 內部會自動呼叫 logout
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _apiClient.setAuthToken(null);
    await _storage.delete(key: 'auth_token');
    notifyListeners();
  }

  // --- 發送註冊驗證碼 ---
  Future<void> sendVerificationCode(String email) async {
    // 呼叫 AuthService 的方法
    await _authService.sendVerificationCode(email);
  }

  // --- 忘記密碼 ---
  Future<void> forgotPassword(String email) async {
    try {
      // 呼叫 AuthService 的 forgotPassword 方法
      // 注意：AuthService.forgotPassword 返回 String，但我們在 UI 層不需要使用這個訊息
      await _authService.forgotPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  // --- 驗證重設密碼驗證碼 ---
  Future<String> verifyResetCode(String email, String code) async {
    try {
      // 呼叫 AuthService 的 verifyCode 方法，返回重設密碼的 token
      return await _authService.verifyCode(email, code);
    } catch (e) {
      rethrow;
    }
  }

  // --- 重設密碼 ---
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      // 呼叫 AuthService 的 resetPassword 方法
      await _authService.resetPassword(token, newPassword);
    } catch (e) {
      rethrow;
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
      // 呼叫 UserService 的方法
      final updatedUser = await _userService.updateUserProfile(
        username: username,
        bio: bio,
        schoolName: schoolName,
        avatarUrl: avatarUrl,
      );
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}