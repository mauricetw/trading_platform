// --- FILE: lib/providers/wishlist_provider.dart ---
import 'package:flutter/foundation.dart';
import '../models/user/user.dart';
import '../models/product/product.dart';
import '../models/user/wishlist_item.dart';
import '../services/api_service.dart';

class WishlistProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;
  User? _currentUser;

  List<WishlistItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  // --- Getters ---
  List<WishlistItem> get items => [..._items];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- 核心方法：當 AuthProvider 狀態改變時被呼叫 ---
  void updateAuth(String? token, User? user) {
    _token = token;
    _currentUser = user;

    if (token == null || user == null) {
      // 使用者登出，清空收藏清單
      _items = [];
      notifyListeners();
    } else {
      // 使用者登入，獲取他的收藏清單
      fetchWishlist();
    }
  }

  Future<void> fetchWishlist() async {
    if (_token == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: 在 ApiService 中新增 getWishlist() 方法
      // final wishlistItems = await _apiService.getWishlist();
      // _items = wishlistItems;

      // --- 暫用模擬資料 ---
      print("模擬：正在為使用者 ${_currentUser?.username} 獲取收藏清單...");
      await Future.delayed(const Duration(seconds: 1));
      // _items = []; // 假設從 API 獲取了資料
      // --- 模擬資料結束 ---

    } catch (e) {
      _errorMessage = "獲取收藏清單失敗: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToWishlist(Product product) async {
    if (_token == null) return;
    if (isProductInWishlist(product)) return;

    // TODO: 呼叫 API 新增到收藏清單
    // final newItem = await _apiService.addToWishlist(product.id);
    // _items.add(newItem);
    notifyListeners();
    print("模擬：已將 ${product.name} 加入收藏");
  }

  Future<void> removeFromWishlist(int productId) async {
    if (_token == null) return;
    // TODO: 呼叫 API 從收藏清單中移除
    // await _apiService.removeFromWishlist(productId);
    // _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
    print("模擬：已從收藏中移除 ID 為 $productId 的商品");
  }

  // 檢查商品是否在收藏列表中
  bool isProductInWishlist(Product product) {
    return _items.any((item) => item.productId == product.id);
  }
}
