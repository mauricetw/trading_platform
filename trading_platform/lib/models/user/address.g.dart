// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
  id: json['id'] as String,
  userId: json['userId'] as String?,
  recipientName: json['recipientName'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  country: json['country'] as String?,
  province: json['province'] as String?,
  city: json['city'] as String?,
  district: json['district'] as String?,
  streetAddress1: json['streetAddress1'] as String?,
  streetAddress2: json['streetAddress2'] as String?,
  postalCode: json['postalCode'] as String?,
  isDefault: json['isDefault'] as bool? ?? false,
  additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
  'id': instance.id,
  if (instance.userId case final value?) 'userId': value,
  if (instance.recipientName case final value?) 'recipientName': value,
  if (instance.phoneNumber case final value?) 'phoneNumber': value,
  if (instance.country case final value?) 'country': value,
  if (instance.province case final value?) 'province': value,
  if (instance.city case final value?) 'city': value,
  if (instance.district case final value?) 'district': value,
  if (instance.streetAddress1 case final value?) 'streetAddress1': value,
  if (instance.streetAddress2 case final value?) 'streetAddress2': value,
  if (instance.postalCode case final value?) 'postalCode': value,
  'isDefault': instance.isDefault,
  if (instance.additionalInfo case final value?) 'additionalInfo': value,
};
