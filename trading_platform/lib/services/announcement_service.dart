import '../models/announcement/announcement.dart';
import 'api_client.dart';

class AnnouncementService {
  final ApiClient _apiClient;
  AnnouncementService(this._apiClient);

  /// 從後端獲取所有公告列表
  Future<List<Announcement>> getAnnouncements() async {
    final responseBody = await _apiClient.get('/announcements');
    final List<dynamic> announcementsJson = responseBody;
    return announcementsJson.map((json) => Announcement.fromJson(json)).toList();
  }

  /// 根據ID獲取單個公告的詳情
  Future<Announcement?> getAnnouncementById(String id) async {
    try {
      final responseBody = await _apiClient.get('/announcements/$id');
      return Announcement.fromJson(responseBody as Map<String, dynamic>);
    } catch (e) {
      // 如果是 404 錯誤，返回 null
      if (e.toString().contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  /// 標記公告為已讀
  Future<bool> markAnnouncementAsRead(String announcementId, String userId) async {
    try {
      await _apiClient.post(
        '/announcements/$announcementId/read-status',
        body: {'userId': userId, 'read': true},
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}