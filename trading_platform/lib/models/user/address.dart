// --- FILE: lib/models/user/address.dart ---
import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

// 雖然我們手動實現 fromJson，但 toJson 仍然可以由 build_runner 產生
@JsonSerializable(
  fieldRename: FieldRename.snake,
  explicitToJson: true,
  createFactory: false, // 告訴產生器：fromJson 由我們自己處理
)
class Address {
  final int id;
  final int userId;
  final String recipientName;
  final String phoneNumber;
  final String city;
  final String postalCode;
  final String streetAddress1;

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

  // --- 手動實現 fromJson，確保最高程度的健壯性 ---
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      recipientName: json['recipient_name'] as String? ?? 'N/A',
      phoneNumber: json['phone_number'] as String? ?? 'N/A',
      city: json['city'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      // 明確地從 street_address_1 和 street_address_2 讀取
      streetAddress1: json['street_address_1'] as String? ?? '',
      streetAddress2: json['street_address_2'] as String?,
      country: json['country'] as String?,
      province: json['province'] as String?,
      district: json['district'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      additionalInfo: json['additional_info'] as Map<String, dynamic>?,
    );
  }

  // toJson 方法將由 build_runner 根據我們的欄位自動產生
  Map<String, dynamic> toJson() => _$AddressToJson(this);

  // copyWith 方法保持不變
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
