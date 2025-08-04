import 'package:json_annotation/json_annotation.dart';

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

// --- DateTime Helpers for standard JSON (ISO 8601 String) ---
DateTime _dateTimeFromJson(String isoString) {
  try {
    return DateTime.parse(isoString);
  } catch (e) {
    // Handle parsing error, e.g., return a default or rethrow
    print('Error parsing DateTime from string "$isoString": $e. Using current time.');
    return DateTime.now(); // Or throw FormatException('Invalid date format: $isoString');
  }
}

String _dateTimeToJson(DateTime dateTime) {
  return dateTime.toIso8601String();
}
// --- End DateTime Helpers ---


@JsonSerializable(explicitToJson: true)
class Message {
  // 'id' is optional and would typically come from your API response
  final String? id;

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
      fromJson: _dateTimeFromJson, // Use the new helper
      toJson: _dateTimeToJson      // Use the new helper
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
    this.id,
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

  Message copyWith({
    String? id,
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
    bool clearId = false,
  }) {
    return Message(
      id: clearId ? null : (id ?? this.id),
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

// Enum (no changes needed for json_serializable if using helper functions)
enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  system,
}
