// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishlistItem _$WishlistItemFromJson(Map<String, dynamic> json) => WishlistItem(
  id: json['id'] as String,
  userId: json['userId'] as String,
  productId: json['productId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  product: Product.fromJson(json['product'] as Map<String, dynamic>),
);

Map<String, dynamic> _$WishlistItemToJson(WishlistItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'productId': instance.productId,
      'createdAt': instance.createdAt.toIso8601String(),
      'product': instance.product.toJson(),
    };
