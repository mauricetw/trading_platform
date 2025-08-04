// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: json['id'] as String?,
  chatRoomId: json['chatRoomId'] as String,
  senderId: json['senderId'] as String,
  receiverId: json['receiverId'] as String,
  text: json['text'] as String?,
  imageUrl: json['imageUrl'] as String?,
  videoUrl: json['videoUrl'] as String?,
  audioUrl: json['audioUrl'] as String?,
  fileUrl: json['fileUrl'] as String?,
  fileName: json['fileName'] as String?,
  fileSize: (json['fileSize'] as num?)?.toInt(),
  timestamp: _dateTimeFromJson(json['timestamp'] as String),
  type:
      json['type'] == null
          ? MessageType.text
          : _messageTypeFromString(json['type'] as String?),
  isRead: json['isRead'] as bool? ?? false,
  isEdited: json['isEdited'] as bool? ?? false,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'chatRoomId': instance.chatRoomId,
  'senderId': instance.senderId,
  'receiverId': instance.receiverId,
  'text': instance.text,
  'imageUrl': instance.imageUrl,
  'videoUrl': instance.videoUrl,
  'audioUrl': instance.audioUrl,
  'fileUrl': instance.fileUrl,
  'fileName': instance.fileName,
  'fileSize': instance.fileSize,
  'timestamp': _dateTimeToJson(instance.timestamp),
  'type': _messageTypeToString(instance.type),
  'isRead': instance.isRead,
  'isEdited': instance.isEdited,
  'metadata': instance.metadata,
};
