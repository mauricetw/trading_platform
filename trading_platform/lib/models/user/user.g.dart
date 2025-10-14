// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'nickname': instance.username,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'avatar_url': instance.avatarUrl,
  'registered_at': instance.registeredAt.toIso8601String(),
  'last_login_at': instance.lastLoginAt?.toIso8601String(),
  'bio': instance.bio,
  'school_name': instance.schoolName,
  'address': instance.address,
  'is_verified': instance.isVerified,
  'roles': instance.roles,
  'is_seller': instance.isSeller,
  'seller_name': instance.sellerName,
  'seller_description': instance.sellerDescription,
  'seller_rating': instance.sellerRating,
  'buyer_rating': instance.buyerRating,
  'product_count': instance.productCount,
  'favorite_product_ids': instance.favoriteProductIds,
  'public_display_name': instance.publicDisplayName,
  'public_bio': instance.publicBio,
  'public_cover_photo_url': instance.publicCoverPhotoUrl,
  'is_school_public': instance.isSchoolPublic,
  'effective_public_display_name': instance.effectivePublicDisplayName,
};
