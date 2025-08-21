// --- FILE: lib/providers/announcement_provider.dart ---
import 'package:flutter/foundation.dart';
import '../models/announcement/announcement.dart'; // 使用你現有的模型

class AnnouncementProvider with ChangeNotifier {
  final dynamic _announcementService;

  List<Announcement> _announcements = [];
  bool _isLoading = false;
  String? _error;

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AnnouncementProvider(this._announcementService) {
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模擬 API 調用，暫時返回空列表
      await Future.delayed(const Duration(milliseconds: 500));
      _announcements = [];

      // TODO: 實際 API 調用應該是：
      // _announcements = await _announcementService.getAnnouncements();

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}