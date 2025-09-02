// --- FILE: lib/models/product/category.dart ---
class Category {
  // --- 關鍵修正：將 id 的類型從 String 改為 int ---
  // 這樣才能與後端資料庫的 Integer 類型匹配。
  final int id;
  final String name; // 分類名稱
  final String? parentId; // 父級分類的 ID，如果是一級分類則為 null

  Category({
    required this.id,
    required this.name,
    this.parentId,
  });

  /// 從 JSON Map 建立一個 Category 物件的工廠方法。
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      // --- 同步修正：將 json['id'] 解析為 int ---
      id: json['id'] as int,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
    );
  }

  /// 將 Category 物件轉換為 JSON Map 的方法。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
    };
  }

  /// 覆寫 toString() 方法，方便在開發和除錯時印出物件資訊。
  @override
  String toString() {
    return 'Category(id: $id, name: $name, parentId: $parentId)';
  }
}
