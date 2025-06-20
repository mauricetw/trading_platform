// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) => Announcement(
  id: json['id'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  publishedDate: DateTime.parse(json['publishedDate'] as String),
  author: json['author'] as String?,
  category: json['category'] as String?,
  imageUrl: json['imageUrl'] as String?,
  isRead: json['isRead'] as bool? ?? false,
  shortDescription: json['shortDescription'] as String?,
);

Map<String, dynamic> _$AnnouncementToJson(Announcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'publishedDate': instance.publishedDate.toIso8601String(),
      'author': instance.author,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
      'isRead': instance.isRead,
      'shortDescription': instance.shortDescription,
    };
