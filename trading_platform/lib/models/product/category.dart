import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Category {
  final int id;            // 分類 ID（int）
  final String name;       // 分類名稱
  final int? parentId;     // 父級分類 ID（int?，一級分類為 null）

  const Category({
    required this.id,
    required this.name,
    this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  String toString() => 'Category(id: $id, name: $name, parentId: $parentId)';
}
