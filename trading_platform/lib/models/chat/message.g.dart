// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: (json['id'] as num).toInt(),
  chatRoomId: (json['chat_room_id'] as num).toInt(),
  senderId: (json['sender_id'] as num).toInt(),
  receiverId: (json['receiver_id'] as num).toInt(),
  text: json['text'] as String?,
  imageUrl: json['image_url'] as String?,
  videoUrl: json['video_url'] as String?,
  audioUrl: json['audio_url'] as String?,
  fileUrl: json['file_url'] as String?,
  fileName: json['file_name'] as String?,
  fileSize: (json['file_size'] as num?)?.toInt(),
  timestamp: _dateTimeFromJson(json['timestamp'] as String),
  type:
      json['type'] == null
          ? MessageType.text
          : _messageTypeFromString(json['type'] as String?),
  isRead: json['is_read'] as bool? ?? false,
  isEdited: json['is_edited'] as bool? ?? false,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'chat_room_id': instance.chatRoomId,
  'sender_id': instance.senderId,
  'receiver_id': instance.receiverId,
  'text': instance.text,
  'image_url': instance.imageUrl,
  'video_url': instance.videoUrl,
  'audio_url': instance.audioUrl,
  'file_url': instance.fileUrl,
  'file_name': instance.fileName,
  'file_size': instance.fileSize,
  'timestamp': _dateTimeToJson(instance.timestamp),
  'type': _messageTypeToString(instance.type),
  'is_read': instance.isRead,
  'is_edited': instance.isEdited,
  'metadata': instance.metadata,
};
