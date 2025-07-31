// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  registeredAt: DateTime.parse(json['registered_at'] as String),
  phoneNumber: json['phone_number'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  lastLoginAt:
      json['last_login_at'] == null
          ? null
          : DateTime.parse(json['last_login_at'] as String),
  bio: json['bio'] as String?,
  schoolName: json['school_name'] as String?,
  isVerified: json['is_verified'] as bool,
  roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
  isSeller: json['is_seller'] as bool,
  sellerName: json['seller_name'] as String?,
  sellerDescription: json['seller_description'] as String?,
  sellerRating: (json['seller_rating'] as num?)?.toDouble(),
  buyerRating: (json['buyer_rating'] as num?)?.toDouble(),
  productCount: (json['product_count'] as num).toInt(),
  favoriteProductIds:
      (json['favorite_product_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'avatar_url': instance.avatarUrl,
  'registered_at': instance.registeredAt.toIso8601String(),
  'last_login_at': instance.lastLoginAt?.toIso8601String(),
  'bio': instance.bio,
  'school_name': instance.schoolName,
  'is_verified': instance.isVerified,
  'roles': instance.roles,
  'is_seller': instance.isSeller,
  'seller_name': instance.sellerName,
  'seller_description': instance.sellerDescription,
  'seller_rating': instance.sellerRating,
  'buyer_rating': instance.buyerRating,
  'product_count': instance.productCount,
  'favorite_product_ids': instance.favoriteProductIds,
};
