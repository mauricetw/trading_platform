// --- FILE: lib/providers/category_provider.dart ---
import 'package:flutter/foundation.dart' as flutter_foundation;

// 簡化的 Category 類，避免模型依賴
class Category {
  final String id;
  final String name;
  final String? parentId;

  Category({
    required this.id,
    required this.name,
    this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
    );
  }
}

class CategoryProvider with flutter_foundation.ChangeNotifier {
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  // 修正構造函數 - 不需要參數
  CategoryProvider() {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    // 模擬數據獲取
    await Future.delayed(const Duration(seconds: 1));
    final List<Map<String, dynamic>> jsonData = [
      {'id': 'cat1', 'name': '電子產品', 'parentId': null},
      {'id': 'cat2', 'name': '手機', 'parentId': 'cat1'},
      {'id': 'cat3', 'name': '服飾', 'parentId': null},
    ];

    _categories = jsonData.map((json) => Category.fromJson(json)).toList();
    notifyListeners();
  }
}