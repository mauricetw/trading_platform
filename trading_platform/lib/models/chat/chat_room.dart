import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 需要導入以處理 Timestamp (如果 lastMessageTimestamp 使用它)
import 'message.dart'; // 確保路徑正確 (如果 Message.dart 在上一級目錄)
// 或者 'message.dart' (如果在同一目錄)

part 'chat_room.g.dart'; // 生成的文件名

// 輔助函數 (與 Message 模型中的類似，如果 lastMessageTimestamp 使用 Timestamp)
DateTime? _dateTimeFlexibleFromJsonOptional(dynamic jsonValue) {
  if (jsonValue == null) return null;
  if (jsonValue is Timestamp) {
    return jsonValue.toDate();
  }
  if (jsonValue is String) {
    return DateTime.tryParse(jsonValue);
  }
  return null; // 或者拋出錯誤，或者返回一個默認的 DateTime
}

Timestamp? _dateTimeToTimestampOptional(DateTime? dateTime) {
  if (dateTime == null) return null;
  return Timestamp.fromDate(dateTime);
}
// 如果您的 API 期望 ISO 字符串：
// String? _dateTimeToIsoStringOptional(DateTime? dateTime) {
//   if (dateTime == null) return null;
//   return dateTime.toIso8601String();
// }


@JsonSerializable(explicitToJson: true) // explicitToJson: true 因為包含了 Message 對象
class ChatRoom {
  @JsonKey(includeFromJson: false, includeToJson: false) // 假設 id 也是來自 Firestore document ID
  final String? id; // 改為可選，以便 fromJson 可以創建實例，然後由 fromFirestore 設置

  final List<String> participantIds;

  // Message 類型已經有自己的 fromJson/toJson，json_serializable 會自動調用它們
  final Message? lastMessage;

  @JsonKey(
      fromJson: _dateTimeFlexibleFromJsonOptional,
      toJson: _dateTimeToTimestampOptional // 或 _dateTimeToIsoStringOptional
  )
  final DateTime? lastMessageTimestamp;

  // Map<String, int> 是 json_serializable 可以直接處理的
  final Map<String, int>? unreadCounts;
  // ... 其他你需要的欄位

  ChatRoom({
    this.id, // 改為可選
    required this.participantIds,
    this.lastMessage,
    this.lastMessageTimestamp,
    this.unreadCounts,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);

  /// Creates a ChatRoom from a Firestore document snapshot.
  factory ChatRoom.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Missing data for ChatRoom ${snapshot.id}');
    }
    final chatRoom = _$ChatRoomFromJson(data);
    return chatRoom.copyWith(id: snapshot.id);
  }

  Map<String, dynamic> toJson() => _$ChatRoomToJson(this);

  ChatRoom copyWith({
    String? id,
    List<String>? participantIds,
    Message? lastMessage,
    DateTime? lastMessageTimestamp, // 注意可空性
    bool clearLastMessageTimestamp = false, // 用於顯式清除日期
    Map<String, int>? unreadCounts,
    bool clearUnreadCounts = false, // 用於顯式清除 map
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage, // 如果 Message 也是可copyWith的，可以更精細
      lastMessageTimestamp: clearLastMessageTimestamp ? null : (lastMessageTimestamp ?? this.lastMessageTimestamp),
      unreadCounts: clearUnreadCounts ? null : (unreadCounts ?? this.unreadCounts),
    );
  }
}