import '../models/announcement/announcement.dart';
import 'api_client.dart';

class AnnouncementService {
  final ApiClient _apiClient;
  AnnouncementService(this._apiClient);

  /// 從後端獲取所有公告列表
  Future<List<Announcement>> getAnnouncements() async {
    // 假設 _apiClient.get('/announcements') 會返回一個 List<dynamic>
    // 每一項都是一個 Map<String, dynamic>
    final responseBody = await _apiClient.get('/announcements');

    // 確保 responseBody 確實是一個 List
    if (responseBody is List) {
      final List<dynamic> announcementsJson = responseBody;
      return announcementsJson.map((json) {
        // 確保列表中的每個元素都是 Map
        if (json is Map<String, dynamic>) {
          return Announcement.fromJson(json);
        } else {
          // 如果資料格式不對，拋出一個更明確的錯誤
          throw FormatException('Unexpected item in announcements list: $json');
        }
      }).toList();
    } else {
      // 如果後端回傳的不是一個 List，拋出錯誤
      throw FormatException('Unexpected response format: expected List, got ${responseBody.runtimeType}');
    }
  }

  /// 根據ID獲取單個公告的詳情
  // 修正：ID 應該是 int,
  Future<Announcement?> getAnnouncementById(int id) async {
    try {
      final responseBody = await _apiClient.get('/announcements/$id');
      // 確保 responseBody 是 Map
      if (responseBody is Map<String, dynamic>) {
        return Announcement.fromJson(responseBody);
      } else {
        throw FormatException('Unexpected response format: expected Map, got ${responseBody.runtimeType}');
      }
    } catch (e) {
      // 如果是 404 錯誤，返回 null
      // 這裡的錯誤檢查可能需要根據你的 ApiClient 如何拋出錯誤來調整
      if (e.toString().contains('404')) {
        return null;
      }
      rethrow; // 重新拋出其他錯誤
    }
  }

  /// 標記公告為已讀
  // 修正：announcementId 應該是 int
  Future<bool> markAnnouncementAsRead(int announcementId, String userId) async {
    try {
      // 假設你的後端 'read-status' API 尚未建立
      // 這是一個範例呼叫
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
