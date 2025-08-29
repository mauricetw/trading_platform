// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellerInfo _$SellerInfoFromJson(Map<String, dynamic> json) => SellerInfo(
  id: (json['id'] as num).toInt(),
  username: json['nickname'] as String,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$SellerInfoToJson(SellerInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.username,
      'avatar_url': instance.avatarUrl,
    };

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'original_price': instance.originalPrice,
  'category_id': instance.categoryId,
  'image_urls': instance.imageUrls,
  'stock_quantity': instance.stockQuantity,
  'status': instance.status,
  'sales_count': instance.salesCount,
  'average_rating': instance.averageRating,
  'review_count': instance.reviewCount,
  'tags': instance.tags,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'seller_id': instance.sellerId,
  'seller': instance.seller?.toJson(),
  'shipping_info': instance.shippingInfo?.toJson(),
  'is_sold': instance.isSold,
};
