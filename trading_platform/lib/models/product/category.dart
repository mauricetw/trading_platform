// lib/models/product/category.dart

class Category {
  final String id; // 分類 ID
  final String name; // 分類名稱
  final String? parentId; // 父級分類的 ID，如果是一級分類則為 null
  // final String? iconUrl; // 可選：分類圖標的 URL
  // final int? order; // 可選：分類的排序順序

  Category({
    required this.id,
    required this.name,
    this.parentId, // 父級分類 ID 是可選的
    // this.iconUrl,
    // this.order,
  });

  // 添加一個 fromJson 工廠方法來解析 JSON 數據
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?, // JSON 中的 parentId 可能為 null
      // iconUrl: json['iconUrl'] as String?,
      // order: json['order'] as int?,
    );
  }

  // （可選）添加一個 toJson 方法來將 Category 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      // 'iconUrl': iconUrl,
      // 'order': order,
    };
  }

  // （可選）覆寫 toString() 方法方便調試
  @override
  String toString() {
    return 'Category(id: $id, name: $name, parentId: $parentId)';
  }
}