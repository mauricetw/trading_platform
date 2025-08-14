// --- FILE: lib/providers/product_provider.dart ---
import 'package:flutter/foundation.dart';
import '../models/product/product.dart';
import '../services/product_service.dart'; // 1. 引入職責單一的 ProductService

class ProductProvider with ChangeNotifier {
  final ProductService _productService; // 2. 依賴 ProductService 而不是 ApiService

  // --- 公開商品列表相關狀態 ---
  List<Product> _products = [];
  bool _isListLoading = false;
  String? _listError;
  int? _selectedCategoryId;

  // --- 賣家專屬商品列表相關狀態 ---
  List<Product> _sellerProducts = [];
  bool _isSellerListLoading = false;
  String? _sellerListError;

  // --- 商品詳情相關狀態 ---
  Product? _selectedProduct;
  bool _isDetailLoading = false;
  String? _detailError;

  // --- Getters ---
  List<Product> get products => _products;
  bool get isListLoading => _isListLoading;
  String? get listError => _listError;
  int? get selectedCategoryId => _selectedCategoryId;

  List<Product> get sellerProducts => _sellerProducts;
  bool get isSellerListLoading => _isSellerListLoading;
  String? get sellerListError => _sellerListError;

  Product? get selectedProduct => _selectedProduct;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;

  // 3. 建構函式，接收傳入的 ProductService
  ProductProvider(this._productService) {
    fetchProducts(); // Provider 被建立時，自動獲取第一頁商品
  }

  // --- 核心業務邏輯 (已全部改為呼叫 _productService) ---

  Future<void> fetchProducts({int? categoryId}) async {
    _isListLoading = true;
    _listError = null;
    notifyListeners();

    try {
      // 呼叫 ProductService 的方法
      final fetchedProducts = await _productService.getProducts(
        categoryId: _selectedCategoryId,
        // TODO: 未來可以加入搜尋和分頁參數
      );
      _products = fetchedProducts;
    } catch (e) {
      _listError = e.toString();
    } finally {
      _isListLoading = false;
      notifyListeners();
    }
  }

  void filterByCategory(int categoryId) {
    if (_selectedCategoryId == categoryId) {
      _selectedCategoryId = null;
    } else {
      _selectedCategoryId = categoryId;
    }
    // 呼叫 fetchProducts 進行後端篩選
    fetchProducts(categoryId: _selectedCategoryId);
  }

  Future<void> fetchProductById(int productId) async {
    _isDetailLoading = true;
    _detailError = null;
    _selectedProduct = null;
    notifyListeners();

    try {
      _selectedProduct = await _productService.getProductById(productId);
    } catch (e) {
      _detailError = e.toString();
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSellerProducts() async {
    _isSellerListLoading = true;
    _sellerListError = null;
    notifyListeners();

    try {
      _sellerProducts = await _productService.getMyProducts();
    } catch (e) {
      _sellerListError = e.toString();
    } finally {
      _isSellerListLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      final newProduct = await _productService.createProduct(productData);
      // 樂觀更新：上架成功後，在本地列表最前面插入新商品
      _sellerProducts.insert(0, newProduct);
      _products.insert(0, newProduct);
      notifyListeners();
    } catch (e) {
      // 向上拋出錯誤，讓 UI 層可以顯示 SnackBar
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    // 樂觀更新：先在 UI 上移除
    final originalSellerIndex = _sellerProducts.indexWhere((p) => p.id == productId);
    final originalPublicIndex = _products.indexWhere((p) => p.id == productId);
    Product? backupSellerProduct;
    Product? backupPublicProduct;

    if (originalSellerIndex != -1) {
      backupSellerProduct = _sellerProducts.removeAt(originalSellerIndex);
    }
    if (originalPublicIndex != -1) {
      backupPublicProduct = _products.removeAt(originalPublicIndex);
    }
    notifyListeners();

    try {
      await _productService.deleteProduct(productId);
    } catch (e) {
      // 如果 API 失敗，將剛剛移除的項目加回來 (回滾)
      if (backupSellerProduct != null && originalSellerIndex != -1) {
        _sellerProducts.insert(originalSellerIndex, backupSellerProduct);
      }
      if (backupPublicProduct != null && originalPublicIndex != -1) {
        _products.insert(originalPublicIndex, backupPublicProduct);
      }
      notifyListeners();
      rethrow;
    }
  }

  // 純前端 UI 狀態操作
  void toggleFavoriteStatus(int productId) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final oldProduct = _products[index];
      final newProduct = oldProduct.copyWith(isFavorite: !oldProduct.isFavorite);
      _products[index] = newProduct;
      notifyListeners();
      // TODO: 呼叫 WishlistService 將收藏狀態同步到後端
    }
  }
}
