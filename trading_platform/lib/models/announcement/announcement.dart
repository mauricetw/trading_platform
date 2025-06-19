// models/announcement.dart (建議將模型放在單獨的文件中)

class Announcement {
  final String id;          // 公告的唯一ID (來自後端)
  final String title;       // 公告標題
  final String content;     // 公告的詳細內容 (可以是純文本，也可以是支持富文本/Markdown的字符串)
  final DateTime publishedDate; // 發布日期
  final String? author;      // 發布者 (可選)
  final String? category;    // 公告分類 (例如："系統維護", "優惠活動", "重要通知"，可選)
  final String? imageUrl;    // 公告相關的圖片URL (可選)
  final bool isRead;        // 標記用戶是否已讀此公告 (這個狀態通常在客戶端管理或結合後端同步)
  final String? shortDescription; // 公告的簡短描述或摘要 (可選, 用於列表頁展示)

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedDate,
    this.author,
    this.category,
    this.imageUrl,
    this.isRead = false, // 默認為未讀
    this.shortDescription,
  });

  // 如果需要從JSON反序列化 (例如從API獲取數據)
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      publishedDate: DateTime.parse(json['publishedDate'] as String), // 確保日期格式能被正確解析
      author: json['author'] as String?,
      category: json['category'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isRead: json['isRead'] as bool? ?? false, // API可能不直接返回isRead，客戶端處理
      shortDescription: json['shortDescription'] as String?,
    );
  }

  // 如果需要序列化為JSON (例如發送給API或本地存儲)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'publishedDate': publishedDate.toIso8601String(),
      'author': author,
      'category': category,
      'imageUrl': imageUrl,
      'isRead': isRead,
      'shortDescription': shortDescription,
    };
  }

  // 創建一個copyWith方法可以方便地更新isRead等狀態
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