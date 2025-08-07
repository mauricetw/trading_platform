import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
)
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
    List<String> parts = [];
    // 您可以根據需要調整顯示的順序和包含的字段
    if (country != null && country!.isNotEmpty) parts.add(country!);
    if (province != null && province!.isNotEmpty) parts.add(province!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (district != null && district!.isNotEmpty) parts.add(district!);
    if (streetAddress1 != null && streetAddress1!.isNotEmpty) parts.add(streetAddress1!);
    if (streetAddress2 != null && streetAddress2!.isNotEmpty) parts.add(streetAddress2!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add('($postalCode)'); // 郵編可以加括號
    if (recipientName != null && recipientName!.isNotEmpty) parts.add('收件人: $recipientName');
    if (phoneNumber != null && phoneNumber!.isNotEmpty) parts.add('電話: $phoneNumber');

    return parts.where((part) => part.isNotEmpty).join(' ').trim();
  }


}

