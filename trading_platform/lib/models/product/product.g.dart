// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  originalPrice: (json['originalPrice'] as num?)?.toDouble(),
  categoryId: (json['categoryId'] as num).toInt(),
  stockQuantity: (json['stockQuantity'] as num).toInt(),
  imageUrls:
      (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
  category: json['category'] as String,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  salesCount: (json['salesCount'] as num?)?.toInt() ?? 0,
  averageRating: (json['averageRating'] as num?)?.toDouble(),
  reviewCount: (json['reviewCount'] as num?)?.toInt(),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  shippingInfo:
      json['shippingInfo'] == null
          ? null
          : ShippingInformation.fromJson(
            json['shippingInfo'] as Map<String, dynamic>,
          ),
  seller:
      json['seller'] == null
          ? null
          : User.fromJson(json['seller'] as Map<String, dynamic>),
  isFavorite: json['isFavorite'] as bool? ?? false,
  isSold: json['isSold'] as bool? ?? false,
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'originalPrice': instance.originalPrice,
  'price': instance.price,
  'categoryId': instance.categoryId,
  'stockQuantity': instance.stockQuantity,
  'imageUrls': instance.imageUrls,
  'category': instance.category,
  'status': instance.status,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'salesCount': instance.salesCount,
  'averageRating': instance.averageRating,
  'reviewCount': instance.reviewCount,
  'tags': instance.tags,
  'shippingInfo': instance.shippingInfo?.toJson(),
  'seller': instance.seller?.toJson(),
  'isFavorite': instance.isFavorite,
  'isSold': instance.isSold,
};
