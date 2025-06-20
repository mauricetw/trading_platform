import 'package:flutter/material.dart';
import 'package:first_flutter_project/models/announcement/announcement.dart'; // 導入模型
import 'announcement_detail.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  // ApiService _apiService = ApiService(); // 如果使用ApiService
  List<Announcement> _announcements = [];
  bool _isLoading = true;
  String? _error;

  // 用於本地存儲已讀公告ID的集合 (示例，實際應用可能用SharedPreferences)
  final Set<String> _readAnnouncementIds = {};

  @override
  void initState() {
    super.initState();
    _fetchAnnouncementsData();
    // _loadReadStatus(); // 如果從本地加載已讀狀態
  }

  // void _loadReadStatus() async {
  //   // 示例：從 SharedPreferences 加載已讀ID
  //   // final prefs = await SharedPreferences.getInstance();
  //   // final List<String>? readIds = prefs.getStringList('read_announcement_ids');
  //   // if (readIds != null) {
  //   //   setState(() {
  //   //     _readAnnouncementIds = readIds.toSet();
  //   //   });
  //   // }
  // }

  Future<void> _fetchAnnouncementsData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // --- 模擬數據 ---
      await Future.delayed(const Duration(seconds: 1)); // 模擬網絡延遲
      final List<Announcement> fetchedAnnouncements = [
        Announcement(id: '1', title: '系統維護通知', content: '尊敬的用戶，系統將於今晚23:00至次日02:00進行維護...', publishedDate: DateTime.now().subtract(const Duration(days: 1)), shortDescription: '系統將於今晚23:00進行維護...'),
        Announcement(id: '2', title: '新功能上線！', content: '我們很高興地宣布，XX新功能已正式上線，快來體驗吧！', publishedDate: DateTime.now().subtract(const Duration(hours: 5)), shortDescription: 'XX新功能已正式上線...', imageUrl: 'https://via.placeholder.com/150/0000FF/FFFFFF?Text=NewFeature'),
        Announcement(id: '3', title: '節日祝福', content: '祝大家節日快樂！', publishedDate: DateTime.now(), shortDescription: '祝大家節日快樂！', category: '節日'),
      ];
      // --- 實際API調用 (取消註釋並替換模擬數據) ---
      // final List<Announcement> fetchedAnnouncements = await _apiService.getAnnouncements();

      if (mounted) {
        setState(() {
          _announcements = fetchedAnnouncements.map((ann) {
            // 檢查本地已讀狀態並更新
            return ann.copyWith(isRead: _readAnnouncementIds.contains(ann.id));
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "加載公告失敗: $e";
          _isLoading = false;
        });
      }
    }
  }

  void _markAsReadAndNavigate(Announcement announcement) async {
    // 導航到詳情頁
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementDetailScreen(announcement: announcement),
      ),
    );

    // 從詳情頁返回後，如果需要，可以在這裡更新狀態或做其他操作
    // 例如，如果詳情頁標記了已讀，這裡可以刷新列表的已讀狀態
    if (result == true || !_readAnnouncementIds.contains(announcement.id)) { // result == true 表示詳情頁標記了已讀
      setState(() {
        _readAnnouncementIds.add(announcement.id);
        // 更新列表中對應公告的 isRead 狀態
        _announcements = _announcements.map((ann) {
          if (ann.id == announcement.id) {
            return ann.copyWith(isRead: true);
          }
          return ann;
        }).toList();
      });
      // 示例：保存已讀ID到 SharedPreferences
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setStringList('read_announcement_ids', _readAnnouncementIds.toList());

      // 可選：調用 API 將已讀狀態同步到後端
      // await _apiService.markAnnouncementAsRead(announcement.id, "CURRENT_USER_ID");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('公告列表'),
        backgroundColor: const Color(0xFF004E98), // 與您聊天列表 AppBar 顏色一致
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchAnnouncementsData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center,),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchAnnouncementsData,
                child: const Text('重試'),
              )
            ],
          ),
        ),
      );
    }
    if (_announcements.isEmpty) {
      return const Center(child: Text('暫無公告', style: TextStyle(fontSize: 18, color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: _fetchAnnouncementsData,
      child: ListView.builder(
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          final announcement = _announcements[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 2,
            child: ListTile(
              leading: announcement.isRead
                  ? Icon(Icons.mark_email_read_outlined, color: Colors.grey[400])
                  : const Icon(Icons.new_releases, color: Colors.orangeAccent),
              title: Text(
                announcement.title,
                style: TextStyle(
                  fontWeight: announcement.isRead ? FontWeight.normal : FontWeight.bold,
                  color: announcement.isRead ? Colors.grey[700] : Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (announcement.shortDescription != null && announcement.shortDescription!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                      child: Text(
                        announcement.shortDescription!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  Text(
                    // 簡單格式化日期
                    '發布於: ${announcement.publishedDate.year}-${announcement.publishedDate.month.toString().padLeft(2, '0')}-${announcement.publishedDate.day.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                _markAsReadAndNavigate(announcement);
              },
            ),
          );
        },
      ),
    );
  }
}