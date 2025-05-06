import 'package:flutter/foundation.dart' as flutter_foundation;
import '../models/product/category.dart'; // 導入 Category Model

class CategoryProvider with flutter_foundation.ChangeNotifier {
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  // 初始化時獲取分類數據
  CategoryProvider() {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    // TODO: 在這裡實現從後端獲取分類數據的邏輯
    // 模擬數據獲取
    await Future.delayed(const Duration(seconds: 1));
    final List<Map<String, dynamic>> jsonData = [
      {'id': 'cat1', 'name': '電子產品', 'parentId': null},
      {'id': 'cat2', 'name': '手機', 'parentId': 'cat1'},
      {'id': 'cat3', 'name': '服飾', 'parentId': null},
    ];

    _categories = jsonData.map((json) => Category.fromJson(json)).toList();
    notifyListeners(); // 通知監聽者數據已更新
  }

// 其他方法...
}