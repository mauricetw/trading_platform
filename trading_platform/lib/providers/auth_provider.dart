// lib/providers/auth_provider.dart
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
  User? get user => _currentUser; // 新增這個 getter 來修復 CartProvider 的錯誤
  String? get token => _token;
  bool get isLoggedIn => _token != null && _currentUser != null;

  AuthProvider(this._authService, this._userService, this._apiClient);

  // --- 內部輔助方法，作為獲取使用者資料的唯一入口 ---
  Future<void> _fetchAndSetCurrentUser() async {
    try {
      final user = await _userService.getMyProfile();
      _currentUser = user;
    } catch (e) {
      await logout();
      rethrow;
    }
  }

  // --- 處理登入/註冊成功後的通用邏輯 ---
  Future<void> _handleAuthSuccess(AuthResponse authResponse) async {
    _token = authResponse.token.accessToken;
    _apiClient.setAuthToken(_token);
    await _storage.write(key: 'auth_token', value: _token);
    await _fetchAndSetCurrentUser();
    notifyListeners();
  }

  // --- 公開方法 ---

  Future<void> login(String identifier, String password) async {
    try {
      final authResponse = await _authService.login(identifier, password);
      await _handleAuthSuccess(authResponse);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password, String code) async {
    try {
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
      await _fetchAndSetCurrentUser();
      notifyListeners();
      return true;
    } catch (e) {
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

  Future<void> sendVerificationCode(String email) async {
    await _authService.sendVerificationCode(email);
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _authService.forgotPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> verifyResetCode(String email, String code) async {
    try {
      return await _authService.verifyCode(email, code);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _authService.resetPassword(token, newPassword);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String username,
    required String bio,
    required String schoolName,
    required String avatarUrl,
  }) async {
    if (!isLoggedIn) return;
    try {
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