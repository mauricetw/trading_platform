// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShippingOption _$ShippingOptionFromJson(Map<String, dynamic> json) =>
    ShippingOption(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      cost: (json['cost'] as num).toDouble(),
      description: json['description'] as String?,
      isEnabled: json['is_enabled'] as bool? ?? true,
      sellerId: (json['seller_id'] as num).toInt(),
    );

Map<String, dynamic> _$ShippingOptionToJson(ShippingOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'cost': instance.cost,
      'is_enabled': instance.isEnabled,
      'seller_id': instance.sellerId,
    };
