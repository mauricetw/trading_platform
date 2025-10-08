// --- FILE: lib/models/chat/chat_room.dart ---
import 'package:json_annotation/json_annotation.dart';
import 'message.dart'; // 確保 message.dart 存在

part 'chat_room.g.dart';

// --- 新建：用於表示對話另一方的使用者資訊模型 ---
@JsonSerializable(fieldRename: FieldRename.snake)
class OtherPartyInfo {
  final int id;
  @JsonKey(name: 'nickname') // 對應後端的 nickname 欄位
  final String name;
  final String? avatarUrl;

  OtherPartyInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory OtherPartyInfo.fromJson(Map<String, dynamic> json) => _$OtherPartyInfoFromJson(json);
  Map<String, dynamic> toJson() => _$OtherPartyInfoToJson(this);
}

// --- ChatRoom 模型 (重構) ---
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ChatRoom {
  // --- 關鍵修正：ID 類型改為 int ---
  final int id;

  // --- 關鍵修正：使用 OtherPartyInfo 物件取代 participantIds ---
  // 這讓 UI 可以直接獲取對方資訊，無需額外 API 請求
  final OtherPartyInfo otherParty;

  final Message? lastMessage;

  // --- 關鍵修正：簡化為單一的 unreadCount ---
  final int unreadCount;

  // lastMessageTimestamp 已被移除，因為 lastMessage 中已包含 timestamp

  ChatRoom({
    required this.id,
    required this.otherParty,
    this.lastMessage,
    required this.unreadCount,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) => _$ChatRoomFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomToJson(this);

  // copyWith 方法對於狀態管理很有用，予以保留並更新
  ChatRoom copyWith({
    int? id,
    OtherPartyInfo? otherParty,
    Message? lastMessage,
    int? unreadCount,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      otherParty: otherParty ?? this.otherParty,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
