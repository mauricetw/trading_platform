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
  int? get selectedCategoryId => _selectedCategoryId;

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
      _categories = await _productService.getCategories();
    } catch (e) {
      debugPrint("Failed to fetch categories: $e");
    } finally {
      _areCategoriesLoading = false;
      notifyListeners();
    }
  }

  /// 修正版本：支援搜索查詢
  Future<void> fetchProducts({int? categoryId, String? searchQuery}) async {
    _isListLoading = true;
    _listError = null;
    notifyListeners();
    try {
      final fetchedProducts = await _productService.getProducts(
        categoryId: categoryId,
        search: searchQuery, // 注意：ProductService 使用 'search' 參數
      );
      _products = fetchedProducts;
    } catch (e) {
      _listError = e.toString();
      debugPrint('獲取商品列表失敗: $e');
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
    debugPrint('===============================');
    debugPrint('ProductProvider: 開始獲取商品詳情');
    debugPrint('ProductProvider: 商品 ID: $productId');
    debugPrint('===============================');

    _isDetailLoading = true;
    _detailError = null;
    _selectedProduct = null;
    notifyListeners();

    try {
      debugPrint('ProductProvider: 呼叫 ProductService.getProductById...');
      final product = await _productService.getProductById(productId);

      debugPrint('ProductProvider: 成功獲取商品:');
      debugPrint('- 商品名稱: ${product.name}');
      debugPrint('- 商品 ID: ${product.id}');
      debugPrint('- 賣家 ID: ${product.sellerId}');
      debugPrint('- 賣家資訊: ${product.seller?.username ?? '無'}');
      debugPrint('- 圖片數量: ${product.imageUrls.length}');
      debugPrint('- 狀態: ${product.status}');
      debugPrint('- 價格: ${product.price}');

      _selectedProduct = product;

    } catch (e, stackTrace) {
      debugPrint('===============================');
      debugPrint('ProductProvider: 獲取商品詳情發生錯誤');
      debugPrint('ProductProvider: 商品 ID: $productId');
      debugPrint('ProductProvider: 錯誤類型: ${e.runtimeType}');
      debugPrint('ProductProvider: 錯誤訊息: $e');
      debugPrint('===============================');
      debugPrint('ProductProvider: 完整堆疊追蹤:');
      debugPrint('$stackTrace');
      debugPrint('===============================');

      // 根據不同錯誤類型提供友好的錯誤訊息
      if (e.toString().contains('FormatException') ||
          e.toString().contains('type \'Null\' is not a subtype')) {
        _detailError = '商品資料格式錯誤，請稍後再試';
        debugPrint('ProductProvider: 診斷 - 這是資料格式或類型轉換問題');
      } else if (e.toString().contains('404')) {
        _detailError = '找不到此商品，可能已被刪除';
        debugPrint('ProductProvider: 診斷 - HTTP 404 錯誤');
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('network') ||
          e.toString().contains('connection')) {
        _detailError = '網路連接問題，請檢查網路狀態';
        debugPrint('ProductProvider: 診斷 - 網路連接問題');
      } else if (e.toString().contains('TimeoutException')) {
        _detailError = '請求超時，請稍後再試';
        debugPrint('ProductProvider: 診斷 - 請求超時');
      } else {
        _detailError = '載入商品失敗: ${e.toString()}';
        debugPrint('ProductProvider: 診斷 - 未知錯誤類型');
      }
    } finally {
      _isDetailLoading = false;
      notifyListeners();

      debugPrint('===============================');
      debugPrint('ProductProvider: 商品詳情獲取流程結束');
      debugPrint('ProductProvider: 最終狀態:');
      debugPrint('- 載入中: $_isDetailLoading');
      debugPrint('- 錯誤訊息: $_detailError');
      debugPrint('- 商品資料: ${_selectedProduct?.name ?? '無'}');
      debugPrint('===============================');
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
      debugPrint('獲取賣家商品失敗: $e');
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
      debugPrint('上傳商品圖片失敗: $e');
      rethrow;
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      final newProduct = await _productService.createProduct(productData);
      _sellerProducts.insert(0, newProduct);
      notifyListeners();
    } catch (e) {
      debugPrint('新增商品失敗: $e');
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
      debugPrint('更新商品失敗: $e');
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
      debugPrint('刪除商品失敗: $e');
      if (backupSellerProduct != null && originalSellerIndex != -1) {
        _sellerProducts.insert(originalSellerIndex, backupSellerProduct);
      }
      notifyListeners();
      rethrow;
    }
  }

  /// 清除錯誤狀態 - 供 UI 重置用
  void clearErrors() {
    _detailError = null;
    _listError = null;
    _sellerListError = null;
    notifyListeners();
  }

  /// 重置選中的商品 - 供頁面離開時清理用
  void clearSelectedProduct() {
    _selectedProduct = null;
    _detailError = null;
    notifyListeners();
  }
}