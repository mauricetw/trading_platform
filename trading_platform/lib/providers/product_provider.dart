// --- FILE: lib/providers/product_provider.dart ---
import 'package:flutter/foundation.dart' hide Category;
import 'package:image_picker/image_picker.dart';

import '../models/product/product.dart';
import '../models/product/category.dart';
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
  String? get listError => _listError;
  int? get selectedCategoryId => _selectedCategoryId;

  List<Product> get sellerProducts => _sellerProducts;
  bool get isSellerListLoading => _isSellerListLoading;
  String? get sellerListError => _sellerListError;

  List<Category> get categories => _categories;
  bool get areCategoriesLoading => _areCategoriesLoading;

  Product? get selectedProduct => _selectedProduct;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;

  ProductProvider(this._productService, this._uploadService) {
    fetchProducts();
    fetchCategories();
  }

  // --- 關鍵修正：移除 toggleFavoriteStatus 方法 ---
  // 收藏狀態的邏輯現在完全由 WishlistProvider 負責，
  // 以確保狀態的單一事實來源 (Single Source of Truth)。
  /*
  void toggleFavoriteStatus(int productId) {
    // ... 此方法已被移除 ...
  }
  */

  Future<void> fetchCategories() async {
    if (_areCategoriesLoading) return;
    _areCategoriesLoading = true;
    notifyListeners();
    try {
      _categories = await _productService.getCategories();
    } catch (e) {
      debugPrint("Failed to fetch categories: $e");
    } finally {
      _areCategoriesLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts({int? categoryId, String? searchQuery}) async {
    _isListLoading = true;
    _listError = null;
    _selectedCategoryId = categoryId;
    notifyListeners();
    try {
      final fetchedProducts = await _productService.getProducts(
        categoryId: categoryId,
        search: searchQuery,
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
    final newCategoryId = (_selectedCategoryId == categoryId) ? null : categoryId;
    fetchProducts(categoryId: newCategoryId);
  }

  Future<void> fetchProductById(int productId) async {
    _isDetailLoading = true;
    _detailError = null;
    _selectedProduct = null;
    notifyListeners();
    try {
      _selectedProduct = await _productService.getProductById(productId);
    } catch (e) {
      _detailError = "無法載入商品詳情: $e";
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

  void clearSelectedProduct() {
    _selectedProduct = null;
    _detailError = null;
    notifyListeners();
  }
}
