// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishpool_invite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishPoolInvite _$WishPoolInviteFromJson(Map<String, dynamic> json) =>
    WishPoolInvite(
      id: (json['id'] as num).toInt(),
      wishPoolId: (json['wish_pool_id'] as num).toInt(),
      sellerId: (json['seller_id'] as num).toInt(),
      productId: (json['product_id'] as num?)?.toInt(),
      message: json['message'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] == null
              ? null
              : DateTime.parse(json['updated_at'] as String),
      seller:
          json['seller'] == null
              ? null
              : User.fromJson(json['seller'] as Map<String, dynamic>),
      product:
          json['product'] == null
              ? null
              : Product.fromJson(json['product'] as Map<String, dynamic>),
      wishpool:
          json['wishpool'] == null
              ? null
              : WishPool.fromJson(json['wishpool'] as Map<String, dynamic>),
    );

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
