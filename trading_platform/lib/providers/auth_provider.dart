import 'package:flutter/foundation.dart';
import '../models/user/user.dart';

class AuthProvider with ChangeNotifier {
  // 1. 需要儲存當前使用者資料的變數
  User? _currentUser;

  // 2. 提供給外部訪問當前使用者的 getter
  User? get currentUser => _currentUser;

  // 3. 提供給外部判斷是否已登入的 getter
  bool get isLoggedIn => _currentUser != null;

  // 4. 模擬登入的方法：需要一個 User 物件作為參數
  void login(User user) {
    _currentUser = user;
    notifyListeners(); // 通知監聽者狀態已改變
  }

  // 5. 模擬登出的方法：不需要參數
  void logout() {
    _currentUser = null;
    notifyListeners(); // 通知監聽者狀態已改變
  }

  // 6. 模擬更新使用者資訊的方法：需要一個更新後的 User 物件作為參數
  void updateUser(User updatedUser) {
    // ... 更新邏輯 ...
    notifyListeners(); // 通知監聽者狀態已改變
  }

  // 7. （可選）在構造函數中進行初始化操作
  AuthProvider() {
    // 例如，可以在這裡檢查本地存儲是否有登入資訊，並自動登入
    // 這是一個進階功能，可以稍後實現
  }
}