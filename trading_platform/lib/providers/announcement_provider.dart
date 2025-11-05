// --- FILE: lib/providers/announcement_provider.dart ---
import 'package:flutter/foundation.dart';
import '../models/announcement/announcement.dart';
// 解決方案 1: 導入你的 AnnouncementService
import '../services/announcement_service.dart';

class AnnouncementProvider with ChangeNotifier {
  // 解決方案 2: 明確指定 _announcementService 的類型，而不是 'dynamic'
  final AnnouncementService _announcementService;

  List<Announcement> _announcements = [];
  bool _isLoading = false;
  String? _error;

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AnnouncementProvider(this._announcementService) {
    // Provider 被建立時，自動去抓取資料
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 解決方案 3: 移除模擬程式碼，並取消註解下面這行
      //
      // await Future.delayed(const Duration(milliseconds: 500)); // (移除)
      // _announcements = []; // (移除)

      // 實際 API 調用：
      _announcements = await _announcementService.getAnnouncements();

    } catch (e) {
      _error = e.toString();
      // 養成好習慣：在除錯時印出錯誤
      debugPrint("Error fetching announcements: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
