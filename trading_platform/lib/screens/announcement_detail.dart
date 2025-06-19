// screens/announcement_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:first_flutter_project/models/announcement/announcement.dart'; // 導入您的公告模型
// import 'package:flutter_markdown/flutter_markdown.dart'; // 如果內容是Markdown格式，可以使用此包
// import 'package:url_launcher/url_launcher.dart'; // 如果內容中有鏈接需要點擊打開

class AnnouncementDetailScreen extends StatefulWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({Key? key, required this.announcement}) : super(key: key);

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  bool _isMarkedAsRead = false; // 本地狀態，標記是否已在本頁面操作過“標記已讀”

  @override
  void initState() {
    super.initState();
    // 可以在進入詳情頁時就認為用戶已讀，或者提供一個按鈕讓用戶手動標記
    // 這裡我們假設進入即視為嘗試標記已讀，並將結果返回給列表頁
    if (!widget.announcement.isRead) {
      _isMarkedAsRead = true; // 標記在本頁面中觸發了“已讀”狀態的改變
    }
  }

  // 可選：如果您想支持Markdown格式的內容
  // Widget _buildContent(String content) {
  //   return MarkdownBody(
  //     data: content,
  //     onTapLink: (text, href, title) {
  //       if (href != null) {
  //         canLaunchUrl(Uri.parse(href)).then((value) {
  //           if (value) {
  //             launchUrl(Uri.parse(href));
  //           }
  //         });
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return WillPopScope( // 處理返回按鈕事件
      onWillPop: () async {
        // 當用戶點擊返回按鈕時，將 _isMarkedAsRead 的結果返回給列表頁
        Navigator.pop(context, _isMarkedAsRead);
        return true; // true 表示允許彈出，false 阻止彈出
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.announcement.title, style: const TextStyle(fontSize: 18)),
          backgroundColor: const Color(0xFF004E98), // 與列表頁 AppBar 顏色一致
          // 可選：如果想在AppBar中直接返回“已讀”狀態，可以在這裡修改 leading 或 actions
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back),
          //   onPressed: () {
          //     Navigator.pop(context, _isMarkedAsRead);
          //   },
          // ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 標題 (也可以只在AppBar顯示)
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
              // 如果內容是純文本:
              SelectableText( // 使用 SelectableText 允許用戶複製內容
                widget.announcement.content,
                style: textTheme.bodyLarge?.copyWith(height: 1.5), // 調整行高以提高可讀性
              ),
              // 如果內容是Markdown (需要引入 flutter_markdown 包):
              // _buildContent(widget.announcement.content),

              const SizedBox(height: 24.0),
              // 可選：可以添加一個“標記為已讀/未讀”的按鈕，或者其他操作
            ],
          ),
        ),
      ),
    );
  }
}