// --- FILE: lib/providers/product_provider.dart ---
import 'package:flutter/foundation.dart' hide Category; // 1. 關鍵修正：隱藏 Flutter 內部的 Category，避免命名衝突
import 'package:image_picker/image_picker.dart';

import '../models/product/product.dart';
import '../models/product/category.dart'; // 現在可以安全地使用您自己的 Category 模型
import '../services/product_service.dart';
import '../services/upload_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService;
  final UploadService _uploadService;

  // --- 狀態 ---
  List<Product> _products = [];
  bool _isListLoading = false;
  String? _listError;
  int? _selectedCategoryId;
  String _searchQuery = ''; // 新增：儲存當前的搜尋關鍵字

  List<Product> _sellerProducts = [];
  bool _isSellerListLoading = false;
  String? _sellerListError;

  List<Category> _categories = [];
  bool _areCategoriesLoading = false;

  Product? _selectedProduct;
  bool _isDetailLoading = false;
  String? _detailError;

  // --- Getters ---
  List<Product> get products => _products;
  bool get isListLoading => _isListLoading;
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  List<Product> get sellerProducts => _sellerProducts;
  bool get isSellerListLoading => _isSellerListLoading;

  List<Category> get categories => _categories;
  bool get areCategoriesLoading => _areCategoriesLoading;

  Product? get selectedProduct => _selectedProduct;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;
  String? get listError => _listError;

  ProductProvider(this._productService, this._uploadService) {
    fetchProducts();
    fetchCategories();
  }

  // --- 核心業務邏輯 ---
  void toggleFavoriteStatus(int productId) {
    final i = _products.indexWhere((p) => p.id == productId);
    if (i != -1) {
      final p = _products[i];
      _products[i] = p.copyWith(isFavorite: !(p.isFavorite));
      notifyListeners();
    }
    final si = _sellerProducts.indexWhere((p) => p.id == productId);
    if (si != -1) {
      final p = _sellerProducts[si];
      _sellerProducts[si] = p.copyWith(isFavorite: !(p.isFavorite));
      notifyListeners();
    }
  }


  Future<void> fetchCategories() async {
    _areCategoriesLoading = true;
    notifyListeners();
    try {
      // 現在可以正確呼叫 _productService.getCategories()
      _categories = await _productService.getCategories();
    } catch (e) {
      print("Failed to fetch categories: $e");
    } finally {
      _areCategoriesLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts({int? categoryId, String? searchQuery}) async {
    _isListLoading = true;
    _listError = null;
    _selectedCategoryId = categoryId; // 更新當前選擇的分類
    _searchQuery = searchQuery ?? ''; // 更新當前的搜尋關鍵字
    notifyListeners();

    try {
      final fetchedProducts = await _productService.getProducts(
        categoryId: _selectedCategoryId,
        search: _searchQuery, // 將搜尋關鍵字傳遞給 service
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
    _selectedCategoryId = (_selectedCategoryId == categoryId) ? null : categoryId;
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

  Future<String> uploadProductImage(XFile imageFile) async {
    try {
      final imageUrl = await _uploadService.uploadImage(imageFile);
      return imageUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      final newProduct = await _productService.createProduct(productData);
      _sellerProducts.insert(0, newProduct);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      final updatedProduct = await _productService.updateProduct(productId, productData);
      final sellerIndex = _sellerProducts.indexWhere((p) => p.id == productId);
      if (sellerIndex != -1) {
        _sellerProducts[sellerIndex] = updatedProduct;
      }
      final publicIndex = _products.indexWhere((p) => p.id == productId);
      if (publicIndex != -1) {
        _products[publicIndex] = updatedProduct;
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    final originalSellerIndex = _sellerProducts.indexWhere((p) => p.id == productId);
    Product? backupSellerProduct;
    if (originalSellerIndex != -1) {
      backupSellerProduct = _sellerProducts.removeAt(originalSellerIndex);
    }
    notifyListeners();

    try {
      await _productService.deleteProduct(productId);
    } catch (e) {
      if (backupSellerProduct != null && originalSellerIndex != -1) {
        _sellerProducts.insert(originalSellerIndex, backupSellerProduct);
      }
      notifyListeners();
      rethrow;
    }
  }
}