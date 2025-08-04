import 'package:json_annotation/json_annotation.dart';
import 'message.dart'; // 確保 message.dart 已經更新為不使用 Firestore

part 'chat_room.g.dart'; // 生成的文件名

// --- DateTime Helpers for optional ISO 8601 String ---
DateTime? _dateTimeFromStringOptional(String? isoString) {
  if (isoString == null) return null;
  try {
    return DateTime.parse(isoString);
  } catch (e) {
    // Handle parsing error for optional fields, e.g., return null or log
    print('Error parsing optional DateTime from string "$isoString": $e. Returning null.');
    return null; // Or rethrow if strict parsing is needed
  }
}

String? _dateTimeToStringOptional(DateTime? dateTime) {
  if (dateTime == null) return null;
  return dateTime.toIso8601String();
}
// --- End DateTime Helpers ---


@JsonSerializable(explicitToJson: true) // explicitToJson: true because it includes Message objects
class ChatRoom {
  // 'id' is optional and would typically come from your API response
  final String? id;

  final List<String> participantIds;

  // Message type already has its own fromJson/toJson if it's JsonSerializable
  final Message? lastMessage; // Assuming Message class is also JsonSerializable

  @JsonKey(
      fromJson: _dateTimeFromStringOptional, // Use the new helper
      toJson: _dateTimeToStringOptional      // Use the new helper
  )
  final DateTime? lastMessageTimestamp;

  // Map<String, int> can be handled directly by json_serializable
  final Map<String, int>? unreadCounts;
  // ... other fields you might need

  ChatRoom({
    this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageTimestamp,
    this.unreadCounts,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomToJson(this);

  ChatRoom copyWith({
    String? id,
    List<String>? participantIds,
    Message? lastMessage, // If Message itself is copyWith-able, you could be more granular
    DateTime? lastMessageTimestamp,
    bool clearLastMessageTimestamp = false, // To explicitly clear the date
    Map<String, int>? unreadCounts,
    bool clearUnreadCounts = false, // To explicitly clear the map
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: clearLastMessageTimestamp ? null : (lastMessageTimestamp ?? this.lastMessageTimestamp),
      unreadCounts: clearUnreadCounts ? null : (unreadCounts ?? this.unreadCounts),
    );
  }
}
