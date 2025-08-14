// --- FILE: lib/screens/announcement.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/announcement/announcement.dart';
import '../providers/announcement_provider.dart'; // 引入新的 Provider
import 'announcement_detail.dart';
import '../widgets/FullBottomConcaveAppBarShape.dart'; // 引入組員的自訂 AppBar

class AnnouncementListScreen extends StatelessWidget {
  // 從 StatefulWidget 改為 StatelessWidget，因為狀態由 Provider 管理
  const AnnouncementListScreen({super.key});

  // 將導航和標記已讀的邏輯移出，使其更清晰
  void _navigateToDetail(BuildContext context, Announcement announcement) {
    // TODO: 未來可以將已讀狀態的管理也移入 Provider
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementDetailScreen(announcement: announcement),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 透過 context.watch<T>() 來監聽 Provider 的變化
    final announcementProvider = context.watch<AnnouncementProvider>();

    return Scaffold(
      // --- UI 整合：使用組員版本的自訂 AppBar ---
      appBar: AppBar(
        title: const Text(''), // 標題可以留空，由形狀主導視覺
        backgroundColor: const Color(0xFF004E98),
        shape: const FullBottomConcaveAppBarShape(curveHeight: 25.0),
        elevation: 6.0,
        shadowColor: Colors.black.withOpacity(0.3),
        actions: [
          // 刷新按鈕
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            // 當正在載入時，禁用按鈕
            onPressed: announcementProvider.isLoading
                ? null
            // 點擊時，呼叫 Provider 的方法來重新獲取資料
                : () => context.read<AnnouncementProvider>().fetchAnnouncements(),
          ),
        ],
      ),
      // --- 資料流整合：根據 Provider 的狀態來建立 body ---
      body: _buildBody(context, announcementProvider),
    );
  }

  Widget _buildBody(BuildContext context, AnnouncementProvider provider) {
    // 狀態 1：正在載入
    if (provider.isLoading && provider.announcements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    // 狀態 2：發生錯誤
    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('載入公告失敗: ${provider.error}', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.read<AnnouncementProvider>().fetchAnnouncements(),
                child: const Text('重試'),
              )
            ],
          ),
        ),
      );
    }
    // 狀態 3：沒有公告
    if (provider.announcements.isEmpty) {
      return const Center(child: Text('暫無公告', style: TextStyle(fontSize: 18, color: Colors.grey)));
    }

    // 狀態 4：成功載入，顯示列表
    return RefreshIndicator(
      onRefresh: () => context.read<AnnouncementProvider>().fetchAnnouncements(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8.0), // 頂部留出一些空間
        itemCount: provider.announcements.length,
        itemBuilder: (context, index) {
          final announcement = provider.announcements[index];
          // TODO: isRead 狀態應由 Provider 管理
          final bool isRead = false;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: isRead
                  ? Icon(Icons.mark_email_read_outlined, color: Colors.grey[400])
                  : const Icon(Icons.new_releases, color: Colors.orangeAccent),
              title: Text(
                announcement.title,
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  color: isRead ? Colors.grey[700] : Colors.black87,
                ),
              ),
              subtitle: Text(
                announcement.shortDescription ?? '點擊查看詳情',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () => _navigateToDetail(context, announcement),
            ),
          );
        },
      ),
    );
  }
}
