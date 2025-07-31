// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShippingOption _$ShippingOptionFromJson(Map<String, dynamic> json) =>
    ShippingOption(
      id: json['id'] as String,
      name: json['name'] as String,
      cost: _doubleFromString(json['cost']),
      description: json['description'] as String? ?? '',
      isEnabled:
          json['isEnabled'] == null ? true : _boolFromString(json['isEnabled']),
      createdAt: _dateTimeFromJson(json['createdAt'] as String),
      updatedAt: _nullableDateTimeFromJson(json['updatedAt'] as String?),
    );

Map<String, dynamic> _$ShippingOptionToJson(ShippingOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cost': instance.cost,
      'description': instance.description,
      'isEnabled': instance.isEnabled,
      'createdAt': _dateTimeToJson(instance.createdAt),
      if (_nullableDateTimeToJson(instance.updatedAt) case final value?)
        'updatedAt': value,
    };
