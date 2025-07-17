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
    _currentUser = User(
      id: 'defaultSellerXYZ789',
      username: '校園百寶小店 (預設)',
      email: 'default.seller.campus@example.com',
      registeredAt: DateTime.now().subtract(Duration(days: 120)), // 假設註冊於120天前
      phoneNumber: '0912-345-678',
      avatarUrl: 'https://i.pravatar.cc/150?u=defaultcampusstore', // Pravatar 是一個提供隨機頭像的服務
      lastLoginAt: DateTime.now().subtract(Duration(minutes: 30)), // 假設30分鐘前登錄
      bio: '本店預設提供各類優質商品，由 AuthProvider 直接生成。',
      schoolName: '預設模擬大學',
      isVerified: true,
      roles: ['user', 'seller'], // 明確角色
      isSeller: true,          // 明確是賣家
      sellerName: '校園百寶小店 (AuthProvider 預設)',
      sellerDescription: '這是一個由 AuthProvider 在構造時自動創建的模擬賣家，用於開發和測試。',
      sellerRating: 4.75,
      productCount: 42,
      favoriteProductIds: ['prod_sample_1', 'prod_sample_2', 'prod_sample_3'], // 模擬一些收藏
    );

    // 在構造函數中，通常不需要調用 notifyListeners()，
    // 因為 Provider 尚未被 Widget 監聽。
    // 如果您在 Provider 創建後立即在 Widget 中使用它，
    // Widget 的初始 build 會讀取到這個 _currentUser。
    print("AuthProvider Initialized: Simulated login for default seller '${_currentUser?.username}'");
  }
}