// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishpool_invite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$WishPoolInviteToJson(WishPoolInvite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'wish_pool_id': instance.wishPoolId,
      'seller_id': instance.sellerId,
      'product_id': instance.productId,
      'message': instance.message,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'seller': instance.seller?.toJson(),
      'product': instance.product?.toJson(),
      'wishpool': instance.wishpool?.toJson(),
    };
