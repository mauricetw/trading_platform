// --- FILE: lib/providers/product_provider.dart (修正版) ---
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/product/product.dart';
import '../models/product/category.dart'; // 假設您有一個 Category 模型
import '../services/product_service.dart';
import '../services/upload_service.dart'; // 引入新的上傳服務

class ProductProvider with ChangeNotifier {
  final ProductService _productService;
  final UploadService _uploadService; // 依賴 UploadService

  // --- 狀態 ---
  List<Product> _products = [];
  bool _isListLoading = false;
  String? _listError;
  int? _selectedCategoryId;

  List<Product> _sellerProducts = [];
  bool _isSellerListLoading = false;
  String? _sellerListError;

  List<Category> _categories = []; // 新增：儲存商品分類
  bool _areCategoriesLoading = false;

  // --- Getters ---
  List<Product> get products => _products;
  bool get isListLoading => _isListLoading;
  int? get selectedCategoryId => _selectedCategoryId;

  List<Product> get sellerProducts => _sellerProducts;
  bool get isSellerListLoading => _isSellerListLoading;
  
  List<Category> get categories => _categories;
  bool get areCategoriesLoading => _areCategoriesLoading;

  ProductProvider(this._productService, this._uploadService) {
    // Provider 被建立時，自動獲取初始資料
    fetchProducts();
    fetchCategories();
  }

  // --- 核心業務邏輯 ---

  Future<void> fetchCategories() async {
    _areCategoriesLoading = true;
    notifyListeners();
    try {
      _categories = await _productService.getCategories();
    } catch (e) {
      // 處理錯誤
      print("Failed to fetch categories: $e");
    } finally {
      _areCategoriesLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts({int? categoryId}) async {
    _isListLoading = true;
    _listError = null;
    notifyListeners();
    try {
      final fetchedProducts = await _productService.getProducts(categoryId: _selectedCategoryId);
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

  // --- 新增：上傳圖片的專屬方法 ---
  Future<String> uploadProductImage(File imageFile) async {
    try {
      // 呼叫 UploadService 來處理上傳
      final imageUrl = await _uploadService.uploadImage(imageFile);
      return imageUrl;
    } catch (e) {
      rethrow; // 向上拋出錯誤，讓 UI 層處理
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      final newProduct = await _productService.createProduct(productData);
      _sellerProducts.insert(0, newProduct);
      // 可選：也可以更新公開商品列表
      // _products.insert(0, newProduct);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      final updatedProduct = await _productService.updateProduct(productId, productData);
      // 更新賣家商品列表
      final sellerIndex = _sellerProducts.indexWhere((p) => p.id == productId);
      if (sellerIndex != -1) {
        _sellerProducts[sellerIndex] = updatedProduct;
      }
      // 更新公開商品列表
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
    // 樂觀更新
    final originalSellerIndex = _sellerProducts.indexWhere((p) => p.id == productId);
    Product? backupSellerProduct;
    if (originalSellerIndex != -1) {
      backupSellerProduct = _sellerProducts.removeAt(originalSellerIndex);
    }
    notifyListeners();

    try {
      await _productService.deleteProduct(productId);
    } catch (e) {
      // 回滾
      if (backupSellerProduct != null && originalSellerIndex != -1) {
        _sellerProducts.insert(originalSellerIndex, backupSellerProduct);
      }
      notifyListeners();
      rethrow;
    }
  }
}
