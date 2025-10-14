// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishpool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$WishPoolToJson(WishPool instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title': instance.title,
  'description': instance.description,
  'category_id': instance.categoryId,
  'tags': instance.tags,
  'photo_url': instance.photoUrl,
  'price_min': instance.priceMin,
  'price_max': instance.priceMax,
  'location': instance.location,
  'course_code': instance.courseCode,
  'status': instance.status,
  'matched_item_id': instance.matchedItemId,
  'like_count': instance.likeCount,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'user': instance.user?.toJson(),
  'matched_item': instance.matchedItem?.toJson(),
};
