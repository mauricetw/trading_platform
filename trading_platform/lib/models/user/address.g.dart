// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  recipientName: json['recipient_name'] as String,
  phoneNumber: json['phone_number'] as String,
  city: json['city'] as String,
  postalCode: json['postal_code'] as String,
  streetAddress1: json['address_line_1'] as String,
  streetAddress2: json['address_line_2'] as String?,
  country: json['country'] as String?,
  province: json['province'] as String?,
  district: json['district'] as String?,
  isDefault: json['is_default'] as bool? ?? false,
  additionalInfo: json['additional_info'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'recipient_name': instance.recipientName,
  'phone_number': instance.phoneNumber,
  'city': instance.city,
  'postal_code': instance.postalCode,
  'address_line_1': instance.streetAddress1,
  'address_line_2': instance.streetAddress2,
  'country': instance.country,
  'province': instance.province,
  'district': instance.district,
  'is_default': instance.isDefault,
  'additional_info': instance.additionalInfo,
};
