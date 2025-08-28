import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user/user.dart';
import '../models/auth/auth_response.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider with ChangeNotifier {
  // --- 依賴注入 ---
  final AuthService _authService;
  final UserService _userService;
  final ApiClient _apiClient; // 用於設定 token
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _currentUser != null;
  ApiClient get apiClient => _apiClient;

  // 建構函式，AuthService 現在不需要 ApiClient
  AuthProvider(this._authService, this._userService, this._apiClient);

  // ===== DEV ONLY: 一鍵假登入，繞過後端 =====
  Future<void> mockLoginForDev({int userId = 999}) async {
    // 構造一個最小可用的 User（依你的 User model 必填欄位）
    final fakeUser = User(
      id: userId,
      username: 'dev_user_$userId',
      email: 'dev$userId@example.com',
      registeredAt: DateTime.now().subtract(const Duration(days: 30)),
      isVerified: true,
      roles: const ['user'],
      isSeller: false,
      productCount: 0,
      // 可選欄位先不給或給個簡單值
      phoneNumber: null,
      avatarUrl: null,
      lastLoginAt: DateTime.now(),
      bio: '這是開發用假帳號',
      schoolName: 'Dev 大學',
      sellerName: null,
      sellerDescription: null,
      sellerRating: null,
      buyerRating: null,
      favoriteProductIds: const [],
      publicDisplayName: 'Dev 用戶',
      publicBio: '僅供開發測試',
      publicCoverPhotoUrl: null,
      isSchoolPublic: true,
    );

    // 依你的 AuthResponse / Token 結構建立假回應
    final fakeAuthResponse = AuthResponse(
      token: Token(
        accessToken: 'dev-access-token-123', // 任意字串
        tokenType: 'bearer',
      ),
      user: fakeUser,
    );

    // 用同一套成功處理邏輯：會自動設好 ApiClient token、寫入 secure storage、notifyListeners
    await _handleAuthSuccess(fakeAuthResponse);
  }


  // --- 登入 ---
  Future<void> login(String identifier, String password) async {
    try {
      // 呼叫 AuthService 的 login 方法
      final authResponse = await _authService.login(identifier, password);
      await _handleAuthSuccess(authResponse);
    } catch (e) {
      rethrow;
    }
  }

  // --- 發送註冊驗證碼 ---
  Future<void> sendVerificationCode(String email) async {
    // 呼叫 AuthService 的方法
    await _authService.sendVerificationCode(email);
  }

  // --- 註冊 ---
  Future<void> register(String username, String email, String password, String code) async {
    try {
      // 呼叫 AuthService 的方法
      final authResponse = await _authService.register(username, email, password, code);
      await _handleAuthSuccess(authResponse);
    } catch (e) {
      rethrow;
    }
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

  // --- 處理登入/註冊成功後的通用邏輯 ---
  Future<void> _handleAuthSuccess(AuthResponse authResponse) async {
    _currentUser = authResponse.user;
    _token = authResponse.token.accessToken;

    // 將 token 傳遞給底層的 ApiClient 供後續所有請求使用
    _apiClient.setAuthToken(_token);

    // 將 token 安全地儲存在手機上
    await _storage.write(key: 'auth_token', value: _token);
    notifyListeners();
  }

  // --- App 啟動時嘗試自動登入 ---
  Future<bool> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'auth_token');
    if (storedToken == null) return false;

    _token = storedToken;
    _apiClient.setAuthToken(_token);

    try {
      // 透過 UserService 獲取最新的使用者資料
      final user = await _userService.getMyProfile();
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
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

  // --- 登出 ---
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _apiClient.setAuthToken(null);
    await _storage.delete(key: 'auth_token');
    notifyListeners();
  }
}

