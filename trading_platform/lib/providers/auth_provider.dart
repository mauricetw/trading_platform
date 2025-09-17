// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart'; // 1. 引入 XFile 類型

import '../models/user/user.dart';
import '../models/auth/auth_response.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/upload_service.dart'; // 2. 引入 UploadService

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;
  final ApiClient _apiClient;
  final UploadService _uploadService; // 3. 加入 UploadService 依賴
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;

  User? get user => _currentUser; // 增加這個 getter 來修復 CartProvider 的錯誤
  String? get token => _token;

  bool get isLoggedIn => _token != null && _currentUser != null;

  // 4. 修改建構函式以接收 UploadService
  AuthProvider(this._authService, this._userService, this._apiClient,
      this._uploadService);

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

  Future<void> register(String username, String email, String password,
      String code) async {
    try {
      final authResponse = await _authService.register(
          username, email, password, code);
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

  // --- 關鍵修正：重構 updateUserProfile 方法 ---
  /// 更新使用者個人資料，支援部分更新和圖片上傳
  Future<void> updateUserProfile({
    XFile? newAvatarFile, // 接收一個可選的圖片檔案
    String? nickname,
    String? bio,
    String? schoolName,
    String? phoneNumber,
  }) async {
    if (!isLoggedIn) throw Exception('使用者未登入');

    try {
      final updateData = <String, dynamic>{};
      String? finalAvatarUrl;

      // 步驟 1: 如果有新圖片，先上傳
      if (newAvatarFile != null) {
        finalAvatarUrl = await _uploadService.uploadImage(newAvatarFile);
        updateData['avatar_url'] = finalAvatarUrl;
      }

      // 步驟 2: 準備要更新的文字資料
      if (nickname != null && nickname != _currentUser?.username) {
        updateData['nickname'] = nickname;
      }
      if (bio != null && bio != _currentUser?.bio) {
        updateData['bio'] = bio;
      }
      if (schoolName != null && schoolName != _currentUser?.schoolName) {
        updateData['school_name'] = schoolName;
      }
      if (phoneNumber != null && phoneNumber != _currentUser?.phoneNumber) {
        updateData['phone_number'] = phoneNumber;
      }

      // 如果沒有任何資料需要更新，則直接返回
      if (updateData.isEmpty) return;

      // 步驟 3: 呼叫 UserService 更新資料
      final updatedUser = await _userService.updateMyProfile(updateData);

      // 步驟 4: 更新本地狀態並通知 UI
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider: 更新個人資料失敗: $e');
      rethrow;
    }
  }
}