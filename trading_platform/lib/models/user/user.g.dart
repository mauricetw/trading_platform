// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  username: json['username'] as String,
  email: json['email'] as String,
  registeredAt: DateTime.parse(json['registeredAt'] as String),
  phoneNumber: json['phoneNumber'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  lastLoginAt:
      json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
  bio: json['bio'] as String?,
  schoolName: json['schoolName'] as String?,
  isVerified: json['isVerified'] as bool?,
  roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  isSeller: json['isSeller'] as bool? ?? false,
  sellerName: json['sellerName'] as String?,
  sellerDescription: json['sellerDescription'] as String?,
  sellerRating: (json['sellerRating'] as num?)?.toDouble(),
  productCount: (json['productCount'] as num?)?.toInt(),
  favoriteProductIds:
      (json['favoriteProductIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'avatarUrl': instance.avatarUrl,
  'registeredAt': instance.registeredAt.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'bio': instance.bio,
  'schoolName': instance.schoolName,
  'isVerified': instance.isVerified,
  'roles': instance.roles,
  'isSeller': instance.isSeller,
  'sellerName': instance.sellerName,
  'sellerDescription': instance.sellerDescription,
  'sellerRating': instance.sellerRating,
  'productCount': instance.productCount,
  'favoriteProductIds': instance.favoriteProductIds,
};
