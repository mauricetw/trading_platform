// lib/models/user/address.dart
import 'package:json_annotation/json_annotation.dart';
part 'address.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Address {
  final String id;
  final String? userId;
  final String? recipientName;
  final String? phoneNumber;
  final String? country;
  final String? province;
  final String? city;
  final String? district;
  final String? streetAddress1;
  final String? streetAddress2;
  final String? postalCode;
  final bool isDefault;
  final Map<String, dynamic>? additionalInfo;

  Address({
    required this.id,
    this.userId,
    this.recipientName,
    this.phoneNumber,
    this.country,
    this.province,
    this.city,
    this.district,
    this.streetAddress1,
    this.streetAddress2,
    this.postalCode,
    this.isDefault = false,
    this.additionalInfo,
  });

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);

  Address copyWith({
    String? id,
    String? userId,
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

  String get displayAddress {
    final parts = <String>[
      if (country?.isNotEmpty == true) country!,
      if (province?.isNotEmpty == true) province!,
      if (city?.isNotEmpty == true) city!,
      if (district?.isNotEmpty == true) district!,
      if (streetAddress1?.isNotEmpty == true) streetAddress1!,
      if (streetAddress2?.isNotEmpty == true) streetAddress2!,
      if (postalCode?.isNotEmpty == true) '($postalCode)',
      if (recipientName?.isNotEmpty == true) '收件人: $recipientName',
      if (phoneNumber?.isNotEmpty == true) '電話: $phoneNumber',
    ];
    return parts.join(' ').trim();
  }
}
