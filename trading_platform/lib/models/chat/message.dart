// --- FILE: lib/models/chat/message.dart ---
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

// --- MessageType Enum and Helpers (保留組員的優秀設計) ---
enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  system, // 用於系統訊息，例如 "對方已加入聊天"
}

MessageType _messageTypeFromString(String? typeString) {
  return MessageType.values.firstWhere(
        (e) => e.name == typeString,
    orElse: () => MessageType.text,
  );
}

String _messageTypeToString(MessageType type) => type.name;

// --- DateTime Helpers (保留組員的設計) ---
DateTime _dateTimeFromJson(String isoString) => DateTime.parse(isoString);
String _dateTimeToJson(DateTime dateTime) => dateTime.toIso8601String();


@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Message {
  // --- 關鍵修正：ID 類型改為 int ---
  final int id;
  final int chatRoomId;
  final int senderId;
  final int receiverId;

  final String? text;
  final String? imageUrl;
  final String? videoUrl;
  final String? audioUrl;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime timestamp;

  @JsonKey(fromJson: _messageTypeFromString, toJson: _messageTypeToString, defaultValue: MessageType.text)
  final MessageType type;

  @JsonKey(defaultValue: false)
  final bool isRead;

  @JsonKey(defaultValue: false)
  final bool isEdited;

  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.receiverId,
    this.text,
    this.imageUrl,
    this.videoUrl,
    this.audioUrl,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    required this.timestamp,
    this.type = MessageType.text,
    this.isRead = false,
    this.isEdited = false,
    this.metadata,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  // copyWith 方法對於狀態管理很有用，予以保留並更新
  Message copyWith({
    int? id,
    int? chatRoomId,
    int? senderId,
    int? receiverId,
    String? text,
    String? imageUrl,
    // ... 其他欄位 ...
  }) {
    return Message(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp, // copyWith 通常會複製所有欄位
      type: type,
      isRead: isRead,
      isEdited: isEdited,
      metadata: metadata,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
    );
  }
}
