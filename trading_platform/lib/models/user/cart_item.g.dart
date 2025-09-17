// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'product_id': instance.productId,
  'quantity': instance.quantity,
  'added_at': instance.addedAt.toIso8601String(),
  'product': instance.product.toJson(),
};
