// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => ChatRoom(
  participantIds:
      (json['participantIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  lastMessage:
      json['lastMessage'] == null
          ? null
          : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
  lastMessageTimestamp: _dateTimeFlexibleFromJsonOptional(
    json['lastMessageTimestamp'],
  ),
  unreadCounts: (json['unreadCounts'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
);

Map<String, dynamic> _$ChatRoomToJson(ChatRoom instance) => <String, dynamic>{
  'participantIds': instance.participantIds,
  'lastMessage': instance.lastMessage?.toJson(),
  'lastMessageTimestamp': _dateTimeToTimestampOptional(
    instance.lastMessageTimestamp,
  ),
  'unreadCounts': instance.unreadCounts,
};
