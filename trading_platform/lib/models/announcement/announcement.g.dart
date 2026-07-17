// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) => Announcement(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String,
  publishedDate: DateTime.parse(json['published_at'] as String),
  shortDescription: json['short_description'] as String?,
  category: json['category'] as String?,
  imageUrl: json['image_url'] as String?,
  author: json['author'] as String?,
  isRead: json['isRead'] as bool? ?? false,
);

Map<String, dynamic> _$AnnouncementToJson(Announcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'published_at': instance.publishedDate.toIso8601String(),
      'short_description': instance.shortDescription,
      'category': instance.category,
      'image_url': instance.imageUrl,
      'author': instance.author,
      'isRead': instance.isRead,
    };
