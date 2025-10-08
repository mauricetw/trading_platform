// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtherPartyInfo _$OtherPartyInfoFromJson(Map<String, dynamic> json) =>
    OtherPartyInfo(
      id: (json['id'] as num).toInt(),
      name: json['nickname'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$OtherPartyInfoToJson(OtherPartyInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.name,
      'avatar_url': instance.avatarUrl,
    };

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => ChatRoom(
  id: (json['id'] as num).toInt(),
  otherParty: OtherPartyInfo.fromJson(
    json['other_party'] as Map<String, dynamic>,
  ),
  lastMessage:
      json['last_message'] == null
          ? null
          : Message.fromJson(json['last_message'] as Map<String, dynamic>),
  unreadCount: (json['unread_count'] as num).toInt(),
);

Map<String, dynamic> _$ChatRoomToJson(ChatRoom instance) => <String, dynamic>{
  'id': instance.id,
  'other_party': instance.otherParty.toJson(),
  'last_message': instance.lastMessage?.toJson(),
  'unread_count': instance.unreadCount,
};
