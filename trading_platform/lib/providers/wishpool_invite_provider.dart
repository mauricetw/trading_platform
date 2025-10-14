import 'package:flutter/foundation.dart';
import '../models/wishpool/wishpool_invite.dart';
import '../services/wishpool_invite_service.dart';

class WishPoolInviteProvider with ChangeNotifier {
  final WishPoolInviteService _service;
  List<WishPoolInvite> _receivedInvites = [];
  List<WishPoolInvite> _sentInvites = [];
  bool _isLoading = false;

  WishPoolInviteProvider(this._service);

  List<WishPoolInvite> get receivedInvites => _receivedInvites;
  List<WishPoolInvite> get sentInvites => _sentInvites;
  bool get isLoading => _isLoading;

  Future<void> loadReceivedInvites(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _receivedInvites = await _service.fetchReceivedInvites(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSentInvites(int sellerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _sentInvites = await _service.fetchSentInvites(sellerId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendInvite({
    required int wishPoolId,
    required int sellerId,
    required int productId,
    String? message,
  }) async {
    final newInvite = await _service.createInvite(
      wishPoolId: wishPoolId,
      sellerId: sellerId,
      productId: productId,
      message: message,
    );
    _sentInvites.insert(0, newInvite);
    notifyListeners();
  }

  Future<void> respondToInvite(int inviteId, String response) async {
    await _service.respondInvite(inviteId: inviteId, response: response);
    final index =
    _receivedInvites.indexWhere((invite) => invite.id == inviteId);
    if (index != -1) {
      _receivedInvites[index] =
          _receivedInvites[index].copyWith(status: response);
      notifyListeners();
    }
  }
}
