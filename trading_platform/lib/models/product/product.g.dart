// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellerInfo _$SellerInfoFromJson(Map<String, dynamic> json) => SellerInfo(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$SellerInfoToJson(SellerInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
    };

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  originalPrice: (json['original_price'] as num?)?.toDouble(),
  categoryId: (json['category_id'] as num).toInt(),
  category: json['category'] as String,
  stockQuantity: (json['stock_quantity'] as num).toInt(),
  imageUrls:
      (json['image_urls'] as List<dynamic>).map((e) => e as String).toList(),
  status: json['status'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  salesCount: (json['sales_count'] as num).toInt(),
  averageRating: (json['average_rating'] as num?)?.toDouble(),
  reviewCount: (json['review_count'] as num).toInt(),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  sellerId: (json['seller_id'] as num).toInt(),
  seller:
      json['seller'] == null
          ? null
          : SellerInfo.fromJson(json['seller'] as Map<String, dynamic>),
  shippingInfo:
      json['shipping_info'] == null
          ? null
          : ShippingInformation.fromJson(
            json['shipping_info'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'original_price': instance.originalPrice,
  'category_id': instance.categoryId,
  'category': instance.category,
  'stock_quantity': instance.stockQuantity,
  'status': instance.status,
  'image_urls': instance.imageUrls,
  'sales_count': instance.salesCount,
  'average_rating': instance.averageRating,
  'review_count': instance.reviewCount,
  'tags': instance.tags,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'seller_id': instance.sellerId,
  'seller': instance.seller?.toJson(),
  'shipping_info': instance.shippingInfo?.toJson(),
};
