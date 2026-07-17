// --- FILE: lib/providers/category_provider.dart ---
// --- [BUG 修正] ---
// 使用 'hide Category' 來避免與我們自己的 Category 模型發生衝突
import 'package:flutter/foundation.dart' hide Category;
import '../models/product/category.dart';
import '../services/product_service.dart';

class CategoryProvider with ChangeNotifier {
  final ProductService _productService;

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 建構子：注入 ProductService
  CategoryProvider(this._productService);

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 使用 ProductService 從後端獲取真實分類
      _categories = await _productService.getCategories();
    } catch (e) {
      _error = "獲取分類失敗: $e";
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}