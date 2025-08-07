import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shipping_option.g.dart'; // 指向將要生成的 part 文件

// 自定義 DateTime 轉換器，用於處理 API 返回的 ISO 8601 日期時間字符串
// 如果 API 返回的是 Unix 時間戳 (毫秒)，你需要修改這些轉換器
DateTime _dateTimeFromJson(String dateString) => DateTime.parse(dateString);
String _dateTimeToJson(DateTime date) => date.toIso8601String();

// 可空 DateTime 的轉換器
DateTime? _nullableDateTimeFromJson(String? dateString) {
  return dateString == null ? null : DateTime.parse(dateString);
}
String? _nullableDateTimeToJson(DateTime? date) {
  return date?.toIso8601String();
}

// 處理 API 可能返回字符串形式的布爾值 "true" 或 "false"
bool _boolFromString(dynamic value) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return false; // 默認或錯誤處理
}

// 處理 API 可能返回字符串形式的數字
double _doubleFromString(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0; // 默認或錯誤處理
}


@JsonSerializable(
  explicitToJson: true, // 推薦用於嵌套對象，雖然這裡沒有，但養成好習慣
  createToJson: true,   // 確保 toJson 方法被生成
  includeIfNull: false, // 可選: 如果為 true，則序列化時 null 值也會包含在 JSON 中；false 則不包含
)
class ShippingOption {
  // 如果 API 返回的 id 字段名不是 'id'，使用 @JsonKey(name: 'api_field_name')
  // 例如: @JsonKey(name: '_id')
  final String id;

  String name;

  @JsonKey(fromJson: _doubleFromString) // 使用自定義轉換器處理 cost
  double cost;

  String description; // 如果 API 可能不返回 description，可以設為 String? description;

  @JsonKey(fromJson: _boolFromString) // 使用自定義轉換器處理 isEnabled
  bool isEnabled;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt; // 通常 createdAt 由後端設置並返回，設為 final

  @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)
  DateTime? updatedAt; // updatedAt 可能為 null

  // String? sellerId; // 如果需要，也添加相應的 @JsonKey (如果 API 字段名不同)

  ShippingOption({
    required this.id,
    required this.name,
    required this.cost,
    this.description = '', // 構造函數中可以有默認值
    this.isEnabled = true,  // 構造函數中可以有默認值
    required this.createdAt,
    this.updatedAt,
    // this.sellerId,
  });

  /// Connect the generated [_$ShippingOptionFromJson] function to the `fromJson` factory.
  factory ShippingOption.fromJson(Map<String, dynamic> json) => _$ShippingOptionFromJson(json);

  /// Connect the generated [_$ShippingOptionToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$ShippingOptionToJson(this);


  /// 創建一個此 ShippingOption 的副本，但可以替換某些字段的值
  /// 注意: 使用 json_serializable 時，copyWith 通常不是必須的，
  /// 因為你可以直接修改非 final 的屬性，或者重新創建一個新的實例。
  /// 但如果你的使用模式依賴它，可以保留。
  ShippingOption copyWith({
    String? id,
    String? name,
    double? cost,
    String? description,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    // String? sellerId,
  }) {
    return ShippingOption(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // sellerId: sellerId ?? this.sellerId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ShippingOption &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              cost == other.cost &&
              description == other.description &&
              isEnabled == other.isEnabled &&
              createdAt == other.createdAt &&
              updatedAt == other.updatedAt; // 包含 updatedAt 如果它對相等性重要

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      cost.hashCode ^
      description.hashCode ^
      isEnabled.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'ShippingOption{id: $id, name: $name, cost: $cost, isEnabled: $isEnabled, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
