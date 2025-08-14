// --- FILE: lib/services/announcement_service.dart (新檔案) ---
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
}
