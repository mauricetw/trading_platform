// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShippingInformation _$ShippingInformationFromJson(Map<String, dynamic> json) =>
    ShippingInformation(
      cost: (json['cost'] as num).toDouble(),
      region: json['region'] as String,
      carrier: json['carrier'] as String?,
    );

Map<String, dynamic> _$ShippingInformationToJson(
  ShippingInformation instance,
) => <String, dynamic>{
  'cost': instance.cost,
  'region': instance.region,
  'carrier': instance.carrier,
};
