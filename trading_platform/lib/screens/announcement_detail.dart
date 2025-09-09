import 'package:flutter/material.dart';
import '../models/announcement/announcement.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.announcement.title, style: const TextStyle(fontSize: 18)),
        backgroundColor: const Color(0xFF004E98),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 標題
            Text(
              widget.announcement.title,
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),

            // 發布日期和作者 (如果有的話)
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[700]),
                const SizedBox(width: 4.0),
                Text(
                  '發布於: ${widget.announcement.publishedDate.year}-${widget.announcement.publishedDate.month.toString().padLeft(2, '0')}-${widget.announcement.publishedDate.day.toString().padLeft(2, '0')} ${widget.announcement.publishedDate.hour.toString().padLeft(2, '0')}:${widget.announcement.publishedDate.minute.toString().padLeft(2, '0')}',
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
            if (widget.announcement.author != null && widget.announcement.author!.isNotEmpty) ...[
              const SizedBox(height: 4.0),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 4.0),
                  Text(
                    '發布者: ${widget.announcement.author}',
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
            if (widget.announcement.category != null && widget.announcement.category!.isNotEmpty) ...[
              const SizedBox(height: 4.0),
              Row(
                children: [
                  Icon(Icons.category_outlined, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 4.0),
                  Text(
                    '分類: ${widget.announcement.category}',
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16.0),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 16.0),

            // 公告圖片 (如果有的話)
            if (widget.announcement.imageUrl != null && widget.announcement.imageUrl!.isNotEmpty) ...[
              Center( // 將圖片居中
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    widget.announcement.imageUrl!,
                    fit: BoxFit.cover, // 或 BoxFit.contain，取決於您的需求
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('圖片加載失敗'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
            ],

            // 公告內容
            SelectableText( // 使用 SelectableText 允許用戶複製內容
              widget.announcement.content,
              style: textTheme.bodyLarge?.copyWith(height: 1.5), // 調整行高以提高可讀性
            ),

            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}