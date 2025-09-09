import 'package:flutter/foundation.dart';
import '../models/announcement/announcement.dart';
import '../services/announcement_service.dart';

class AnnouncementProvider with ChangeNotifier {
  final AnnouncementService _announcementService;

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
      _announcements = await _announcementService.getAnnouncements();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}