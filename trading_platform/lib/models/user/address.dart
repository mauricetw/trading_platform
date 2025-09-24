// --- FILE: lib/models/user/address.dart ---
import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake, // 確保與後端蛇形命名匹配
  explicitToJson: true,
)
class Address {
  // --- 關鍵修正：ID 類型改為 int ---
  final int id;
  final int userId;

  // --- 關鍵修正：核心欄位設為必填 ---
  final String recipientName;
  final String phoneNumber;
  final String city;
  final String postalCode;
  final String streetAddress1;

  // --- 保留的可選欄位 ---
  final String? country;
  final String? province;
  final String? district;
  final String? streetAddress2;
  final bool isDefault;
  final Map<String, dynamic>? additionalInfo;

  Address({
    required this.id,
    required this.userId,
    required this.recipientName,
    required this.phoneNumber,
    required this.city,
    required this.postalCode,
    required this.streetAddress1,
    this.country,
    this.province,
    this.district,
    this.streetAddress2,
    this.isDefault = false,
    this.additionalInfo,
  });

  /// 便利的 getter，用於在 UI 中顯示格式化的完整地址
  String get displayAddress {
    // 保留您組員設計的顯示邏輯
    final parts = [
      postalCode,
      country,
      province,
      city,
      district,
      streetAddress1,
      streetAddress2,
    ];
    // 過濾掉 null 或空字串的欄位，然後用空格連接
    return parts.where((p) => p != null && p.isNotEmpty).join(' ');
  }

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);

  // copyWith 方法對於狀態管理很有用，予以保留
  Address copyWith({
    int? id,
    int? userId,
    String? recipientName,
    String? phoneNumber,
    String? country,
    String? province,
    String? city,
    String? district,
    String? streetAddress1,
    String? streetAddress2,
    String? postalCode,
    bool? isDefault,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      country: country ?? this.country,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      streetAddress1: streetAddress1 ?? this.streetAddress1,
      streetAddress2: streetAddress2 ?? this.streetAddress2,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
