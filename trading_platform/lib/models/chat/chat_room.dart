import 'message.dart';
// 範例 ChatRoom 模型 (如果需要更詳細的信息)
class ChatRoom {
  final String id;
  final List<String> participantIds;
  final Message? lastMessage; // 或者只存 lastMessageText 和 lastMessageSenderId
  final DateTime? lastMessageTimestamp;
  final Map<String, int>? unreadCounts;
  // ... 其他你需要的欄位

  ChatRoom({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageTimestamp,
    this.unreadCounts,
  });
}