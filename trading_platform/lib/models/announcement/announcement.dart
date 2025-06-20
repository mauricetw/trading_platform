import 'package:json_annotation/json_annotation.dart';

part 'announcement.g.dart'; // 生成的文件名

// models/announcement.dart (建議將模型放在單獨的文件中)

@JsonSerializable()
class Announcement {
  final String id; // 公告的唯一ID (來自後端)
  final String title; // 公告標題
  final String content; // 公告的詳細內容 (可以是純文本，也可以是支持富文本/Markdown的字符串)
  final DateTime publishedDate; // 發布日期
  final String? author; // 發布者 (可選)
  final String? category; // 公告分類 (例如："系統維護", "優惠活動", "重要通知"，可選)
  final String? imageUrl; // 公告相關的圖片URL (可選)

  @JsonKey(defaultValue: false) // 如果 API 可能不返回 isRead，則提供默認值
  final bool isRead; // 標記用戶是否已讀此公告 (這個狀態通常在客戶端管理或結合後端同步)

  final String? shortDescription; // 公告的簡短描述或摘要 (可選, 用於列表頁展示)

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedDate,
    this.author,
    this.category,
    this.imageUrl,
    this.isRead = false, // 默認為未讀, @JsonKey(defaultValue: false) 已處理反序列化時的情況
    this.shortDescription,
  });

  /// Connect the generated [_$AnnouncementFromJson] function to the `fromJson`
  /// factory.
  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);

  /// Connect the generated [_$AnnouncementToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$AnnouncementToJson(this);

  // 創建一個copyWith方法可以方便地更新isRead等狀態
  // json_serializable 不會自動生成 copyWith，如果您還需要它，可以保留。
  // 或者，如果您決定使用 freezed 包，它會自動生成 copyWith。
  Announcement copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? publishedDate,
    String? author,
    String? category,
    String? imageUrl,
    bool? isRead,
    String? shortDescription,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      publishedDate: publishedDate ?? this.publishedDate,
      author: author ?? this.author,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      shortDescription: shortDescription ?? this.shortDescription,
    );
  }
}