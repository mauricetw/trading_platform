import 'package:json_annotation/json_annotation.dart';

part 'announcement.g.dart';

@JsonSerializable()
class Announcement {
  // 修正 1: 後端的 id 是 int (數字)，不是 String (字串)
  final int id;
  final String title; // 公告標題
  final String content; // 公告的詳細內容

  // 修正 2: 告訴 Dart，JSON 裡的 key 叫做 'published_at'
  @JsonKey(name: 'published_at')
  final DateTime publishedDate; // 發布日期

  // 修正 3: 告訴 Dart，JSON 裡的 key 叫做 'short_description'
  @JsonKey(name: 'short_description')
  final String? shortDescription; // 公告的簡短描述或摘要

  final String? category; // 公告分類 (名稱剛好一樣，不用改)

  // 修正 4: 告訴 Dart，JSON 裡的 key 叫做 'image_url'
  @JsonKey(name: 'image_url')
  final String? imageUrl; // 公告相關的圖片URL

  // --- 以下是後端沒有，但 App 需要的欄位 ---

  // 後端沒有 'author' 欄位，所以 'author' 會是 null (因為可選 '?'，這沒問題)
  final String? author;

  // 使用 defaultValue，如果 JSON 中沒有 'isRead' 欄位，則默認為 false
  // 這在你的原始碼中已經做對了，非常好！
  @JsonKey(defaultValue: false)
  final bool isRead;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedDate,
    this.shortDescription,
    this.category,
    this.imageUrl,
    this.author,
    this.isRead = false,
  });

  /// Connect the generated [_$AnnouncementFromJson] function to the `fromJson`
  /// factory.
  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);

  /// Connect the generated [_$AnnouncementToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$AnnouncementToJson(this);

  // copyWith 方法保持不變，它很有用
  Announcement copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? publishedDate,
    String? shortDescription,
    String? category,
    String? imageUrl,
    String? author,
    bool? isRead,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      publishedDate: publishedDate ?? this.publishedDate,
      shortDescription: shortDescription ?? this.shortDescription,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      isRead: isRead ?? this.isRead,
    );
  }
}
