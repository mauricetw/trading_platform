import 'package:flutter/foundation.dart';
import '../models/wishpool/wishpool_invite.dart';
import '../services/wishpool_invite_service.dart';

class WishPoolInviteProvider with ChangeNotifier {
  final WishPoolInviteService _service;

  List<WishPoolInvite> _receivedInvites = [];
  List<WishPoolInvite> _sentInvites = [];

  bool _isLoading = false;
  String? _error;

  WishPoolInviteProvider(this._service);

  List<WishPoolInvite> get receivedInvites => _receivedInvites;
  List<WishPoolInvite> get sentInvites => _sentInvites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReceivedInvites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _receivedInvites = await _service.getReceivedInvites();
    } catch (e) {
      _error = '載入收到邀請失敗: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSentInvites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sentInvites = await _service.getSentInvites();
    } catch (e) {
      _error = '載入已發送邀請失敗: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// [賣家] 發送邀請 (productId 可選)
  Future<void> sendInvite({
    required int wishPoolId,
    required String message,
    int? productId,
  }) async {
    try {
      // 呼叫 Service，傳入可選的 productId
      await _service.sendInvite(wishPoolId, message, productId: productId);
      loadSentInvites();
    } catch (e) {
      debugPrint('發送邀請失敗: $e');
      rethrow;
    }
  }

  Future<void> acceptInvite(int inviteId) async {
    try {
      final updatedInvite = await _service.acceptInvite(inviteId);
      final index = _receivedInvites.indexWhere((i) => i.id == inviteId);
      if (index != -1) {
        _receivedInvites[index] = updatedInvite;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('接受邀請失敗: $e');
      rethrow;
    }
  }

  Future<void> rejectInvite(int inviteId) async {
    try {
      final updatedInvite = await _service.rejectInvite(inviteId);
      final index = _receivedInvites.indexWhere((i) => i.id == inviteId);
      if (index != -1) {
        _receivedInvites[index] = updatedInvite;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('拒絕邀請失敗: $e');
      rethrow;
    }
  }
}