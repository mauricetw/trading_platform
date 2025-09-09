import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/announcement/announcement.dart';
import '../providers/announcement_provider.dart';
import 'announcement_detail.dart';
import '../widgets/FullBottomConcaveAppBarShape.dart';

class AnnouncementListScreen extends StatelessWidget {
  const AnnouncementListScreen({super.key});

  void _navigateToDetail(BuildContext context, Announcement announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementDetailScreen(announcement: announcement),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final announcementProvider = context.watch<AnnouncementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color(0xFF004E98),
        shape: const FullBottomConcaveAppBarShape(curveHeight: 25.0),
        elevation: 6.0,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: announcementProvider.isLoading
                ? null
                : () => context.read<AnnouncementProvider>().fetchAnnouncements(),
          ),
        ],
      ),
      body: _buildBody(context, announcementProvider),
    );
  }

  Widget _buildBody(BuildContext context, AnnouncementProvider provider) {
    if (provider.isLoading && provider.announcements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('載入公告失敗: ${provider.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
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

    if (provider.announcements.isEmpty) {
      return const Center(
          child: Text('暫無公告', style: TextStyle(fontSize: 18, color: Colors.grey))
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AnnouncementProvider>().fetchAnnouncements(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8.0),
        itemCount: provider.announcements.length,
        itemBuilder: (context, index) {
          final announcement = provider.announcements[index];
          final bool isRead = announcement.isRead == true;
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
                _getShortDescription(announcement),
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

  String _getShortDescription(Announcement announcement) {
    try {
      return announcement.shortDescription ?? '點擊查看詳情';
    } catch (e) {
      return '點擊查看詳情';
    }
  }
}