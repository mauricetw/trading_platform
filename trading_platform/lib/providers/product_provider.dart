import 'package:flutter/foundation.dart';
import '../models/product/product.dart';
import '../api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // --- 列表相關狀態 ---
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  int? _selectedCategoryId;
  bool _isListLoading = false;
  String? _listError;

  // --- 商品詳情相關狀態 ---
  Product? _selectedProduct;
  bool _isDetailLoading = false;
  String? _detailError;

  // --- Getters ---
  List<Product> get products => _filteredProducts;
  bool get isListLoading => _isListLoading;
  String? get listError => _listError;
  int? get selectedCategoryId => _selectedCategoryId;

  Product? get selectedProduct => _selectedProduct;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;

  ProductProvider() {
    fetchProducts();
  }

  // --- 列表相關方法 ---
  Future<void> fetchProducts({int? categoryId}) async {
    _isListLoading = true;
    _listError = null;
    if (categoryId == null) {
      _selectedCategoryId = null; // 如果是全局刷新，清除分類
    }
    notifyListeners();

    try {
      final fetchedProducts = await _apiService.getProducts(categoryId: _selectedCategoryId);
      _products = fetchedProducts;
      _filterProducts();
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
    // 呼叫 fetchProducts 進行後端篩選，而不是前端
    fetchProducts(categoryId: _selectedCategoryId);
  }

  void _filterProducts() {
    // 現在這個方法主要用於同步 _filteredProducts，因為篩選已交給後端
    _filteredProducts = List.from(_products);
  }

  // --- 商品詳情相關方法 ---
  Future<void> fetchProductById(int productId) async {
    _isDetailLoading = true;
    _detailError = null;
    _selectedProduct = null; // 每次獲取前先清空
    notifyListeners();

    try {
      final product = await _apiService.getProductById(productId);
      _selectedProduct = product;
    } catch (e) {
      _detailError = e.toString();
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  // --- 收藏狀態方法 (保持不變) ---
  void toggleFavoriteStatus(int productId) {
    final productIndex = _products.indexWhere((p) => p.id == productId);
    if (productIndex != -1) {
      final oldProduct = _products[productIndex];
      final newProduct = oldProduct.copyWith(isFavorite: !oldProduct.isFavorite);
      _products[productIndex] = newProduct;

      _filterProducts();
      notifyListeners();

      // TODO: 呼叫 ApiService 將收藏狀態同步到後端
    }
  }
}
