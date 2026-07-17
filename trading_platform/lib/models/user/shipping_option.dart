// --- FILE: lib/models/user/shipping_option.dart ---
import 'package:json_annotation/json_annotation.dart';

part 'shipping_option.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ShippingOption {
  // --- 關鍵修正：ID 類型從 String 改為 int ---
  final int id;
  final String name;
  final String? description;
  final double cost;
  final bool isEnabled;
  // --- 關鍵新增：加入 seller_id 以匹配後端 ---
  final int sellerId;

  ShippingOption({
    required this.id,
    required this.name,
    required this.cost,
    this.description,
    this.isEnabled = true,
    required this.sellerId,
  });

  factory ShippingOption.fromJson(Map<String, dynamic> json) => _$ShippingOptionFromJson(json);
  Map<String, dynamic> toJson() => _$ShippingOptionToJson(this);

  // copyWith 方法對於狀態管理很有用，予以保留並更新
  ShippingOption copyWith({
    int? id,
    String? name,
    double? cost,
    String? description,
    bool? isEnabled,
    int? sellerId,
  }) {
    return ShippingOption(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      sellerId: sellerId ?? this.sellerId,
    );
  }

  // 為了讓 RadioListTile 能正確比較物件，重寫 == 和 hashCode
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ShippingOption &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}