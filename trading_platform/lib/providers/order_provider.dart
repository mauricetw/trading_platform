// --- FILE: lib/providers/order_provider.dart ---
import 'package:flutter/foundation.dart';
import '../models/order/order.dart';
import '../services/order_service.dart';
import 'auth_provider.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService;
  AuthProvider? _authProvider;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  OrderProvider(this._orderService, this._authProvider) {
    if (_authProvider?.isLoggedIn == true) {
      fetchMyOrders();
    }
  }

  void update(AuthProvider newAuthProvider) {
    // 如果登入狀態改變，重新獲取訂單
    if (newAuthProvider.isLoggedIn != _authProvider?.isLoggedIn) {
      _authProvider = newAuthProvider;
      if (newAuthProvider.isLoggedIn) {
        fetchMyOrders();
      } else {
        _orders = [];
        notifyListeners();
      }
    }
  }

  Future<void> fetchMyOrders() async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderService.getMyOrders();
    } catch (e) {
      _error = "無法載入訂單: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}