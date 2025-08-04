// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => ChatRoom(
  id: json['id'] as String?,
  participantIds:
      (json['participantIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  lastMessage:
      json['lastMessage'] == null
          ? null
          : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
  lastMessageTimestamp: _dateTimeFromStringOptional(
    json['lastMessageTimestamp'] as String?,
  ),
  unreadCounts: (json['unreadCounts'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
);

Map<String, dynamic> _$ChatRoomToJson(ChatRoom instance) => <String, dynamic>{
  'id': instance.id,
  'participantIds': instance.participantIds,
  'lastMessage': instance.lastMessage?.toJson(),
  'lastMessageTimestamp': _dateTimeToStringOptional(
    instance.lastMessageTimestamp,
  ),
  'unreadCounts': instance.unreadCounts,
};
