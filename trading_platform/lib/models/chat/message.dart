import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'message.g.dart';


// Helper function for MessageType serialization
MessageType _messageTypeFromString(String? typeString) {
  if (typeString == null) return MessageType.text;
  switch (typeString.toLowerCase()) {
    case 'text':
      return MessageType.text;
    case 'image':
      return MessageType.image;
    case 'video':
      return MessageType.video;
    case 'audio':
      return MessageType.audio;
    case 'file':
      return MessageType.file;
    case 'system':
      return MessageType.system;
    default:
      return MessageType.text;
  }
}

String _messageTypeToString(MessageType type) {
  return type.toString().split('.').last;
}

// Helper functions for Firebase Timestamp conversion (or general DateTime)
// DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate(); // 如果只處理 Timestamp
// Timestamp _dateTimeToTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime); // 如果只處理 Timestamp

// Flexible DateTime deserializer (handles Timestamp or ISO String)
DateTime _dateTimeFlexibleFromJson(dynamic jsonValue) {
  if (jsonValue is Timestamp) {
    return jsonValue.toDate();
  }
  if (jsonValue is String) {
    // 嘗試解析，如果失敗或為空，則返回當前時間或拋出錯誤
    // 這裡的 DateTime.now() 是一個回退，您可能希望更嚴格地處理錯誤
    return DateTime.tryParse(jsonValue) ?? DateTime.now();
  }
  // 如果類型不是 Timestamp 或 String，決定如何處理
  // 例如，拋出一個格式異常，或者返回一個默認值
  print('Warning: Unexpected type for timestamp: ${jsonValue.runtimeType}. Using current time.');
  return DateTime.now(); // 或者 throw FormatException('Invalid type for timestamp: ${jsonValue.runtimeType}');
}

// DateTime serializer (converts DateTime to Timestamp for Firestore)
Timestamp _dateTimeToTimestamp(DateTime dateTime) {
  return Timestamp.fromDate(dateTime);
}
// 如果您的 API 期望 ISO 字符串：
// String _dateTimeToIsoString(DateTime dateTime) {
//   return dateTime.toIso8601String();
// }


@JsonSerializable(explicitToJson: true)
class Message {
  // id 仍然是 final，但構造函數中變為可選，由 fromFirestore 或 copyWith 設置
  final String? id; // 改為可選 String?

  // ... (其他字段保持不變) ...
  final String chatRoomId;
  final String senderId;
  final String receiverId;
  final String? text;
  final String? imageUrl;
  final String? videoUrl;
  final String? audioUrl;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;

  @JsonKey(
      fromJson: _dateTimeFlexibleFromJson,
      toJson: _dateTimeToTimestamp
  )
  final DateTime timestamp;

  @JsonKey(
      fromJson: _messageTypeFromString,
      toJson: _messageTypeToString,
      defaultValue: MessageType.text
  )
  final MessageType type;

  @JsonKey(defaultValue: false)
  final bool isRead;

  @JsonKey(defaultValue: false)
  final bool isEdited;

  final Map<String, dynamic>? metadata;


  Message({
    this.id, // <--- 改為可選，不再是 required
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

  factory Message.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Missing data for Message ${snapshot.id}');
    }
    // _$MessageFromJson 會創建一個 Message 實例，其 id 為 null
    final messageFromJson = _$MessageFromJson(data);
    // 使用 copyWith (或直接構造新實例) 來設置 id
    return messageFromJson.copyWith(id: snapshot.id);
  }

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    String? id, // copyWith 的 id 參數也應該是 String?
    String? chatRoomId,
    String? senderId,
    String? receiverId,
    String? text,
    String? imageUrl,
    String? videoUrl,
    String? audioUrl,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    DateTime? timestamp,
    MessageType? type,
    bool? isRead,
    bool? isEdited,
    Map<String, dynamic>? metadata,
    bool clearId = false, // 可選: 添加一個標記來顯式清除 id
  }) {
    return Message(
      id: clearId ? null : (id ?? this.id), // 在 copyWith 中處理 id
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      isEdited: isEdited ?? this.isEdited,
      metadata: metadata ?? this.metadata,
    );
  }
}

// ... (MessageType enum and helper functions remain the same) ...

// Enum (no changes needed for json_serializable if using helper functions)
enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  system,
}