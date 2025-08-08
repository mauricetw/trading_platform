// --- FILE: lib/providers/product_provider.dart ---
import 'package:flutter/foundation.dart';
import '../models/product/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // --- 公開商品列表相關狀態 ---
  List<Product> _products = [];
  bool _isListLoading = false;
  String? _listError;
  int? _selectedCategoryId;

  // --- 賣家專屬商品列表相關狀態 ---
  List<Product> _sellerProducts = [];
  bool _isSellerListLoading = false;
  String? _sellerListError;

  // --- 商品詳情相關狀態 (保持不變) ---
  Product? _selectedProduct;
  bool _isDetailLoading = false;
  String? _detailError;

  // --- Getters ---
  List<Product> get products => _products; // 直接回傳篩選前的列表
  bool get isListLoading => _isListLoading;
  String? get listError => _listError;
  int? get selectedCategoryId => _selectedCategoryId;

  List<Product> get sellerProducts => _sellerProducts;
  bool get isSellerListLoading => _isSellerListLoading;
  String? get sellerListError => _sellerListError;

  Product? get selectedProduct => _selectedProduct;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;

  // ... fetchProducts, filterByCategory, fetchProductById, toggleFavoriteStatus 等方法保持不變 ...
  Future<void> fetchProducts({int? categoryId}) async {
    _isListLoading = true;
    _listError = null;
    if (categoryId == null) _selectedCategoryId = null;
    notifyListeners();
    try {
      final fetchedProducts = await _apiService.getProducts(categoryId: _selectedCategoryId);
      _products = fetchedProducts;
    } catch (e) {
      _listError = e.toString();
    } finally {
      _isListLoading = false;
      notifyListeners();
    }
  }
  void filterByCategory(int categoryId) {
    if (_selectedCategoryId == categoryId) _selectedCategoryId = null;
    else _selectedCategoryId = categoryId;
    fetchProducts(categoryId: _selectedCategoryId);
  }
  Future<void> fetchProductById(int productId) async { /* ... */ }
  void toggleFavoriteStatus(int productId) { /* ... */ }


  // --- 新增：獲取賣家自己的商品 ---
  Future<void> fetchSellerProducts() async {
    _isSellerListLoading = true;
    _sellerListError = null;
    notifyListeners();

    try {
      _sellerProducts = await _apiService.getMyProducts();
    } catch (e) {
      _sellerListError = e.toString();
    } finally {
      _isSellerListLoading = false;
      notifyListeners();
    }
  }

  // --- 新增：上架新商品 ---
  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      final newProduct = await _apiService.createProduct(productData);
      // 上架成功後，在本地列表最前面插入新商品，並通知 UI 更新
      _sellerProducts.insert(0, newProduct);
      // 同時也更新公開的商品列表
      _products.insert(0, newProduct);
      notifyListeners();
    } catch (e) {
      // 讓呼叫者 (UI 層) 處理錯誤訊息的顯示
      rethrow;
    }
  }

  // --- 新增：刪除商品 ---
  Future<void> deleteProduct(int productId) async {
    try {
      await _apiService.deleteProduct(productId);
      // 成功後，從本地列表中移除
      _sellerProducts.removeWhere((p) => p.id == productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
