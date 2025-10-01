// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishlistItem _$WishlistItemFromJson(Map<String, dynamic> json) => WishlistItem(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  productId: (json['product_id'] as num).toInt(),
  addedAt: DateTime.parse(json['added_at'] as String),
  product: Product.fromJson(json['product'] as Map<String, dynamic>),
);

Map<String, dynamic> _$WishlistItemToJson(WishlistItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'product_id': instance.productId,
      'added_at': instance.addedAt.toIso8601String(),
      'product': instance.product.toJson(),
    };
