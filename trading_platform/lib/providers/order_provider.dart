// --- FILE: lib/providers/order_provider.dart ---
import 'package:flutter/foundation.dart';
import '../models/order/order.dart';
import '../services/order_service.dart';
import 'auth_provider.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService;
  AuthProvider? _authProvider;

  // --- 列表狀態 ---
  List<Order> _orders = [];
  bool _isListLoading = false;
  String? _listError;

  // --- 關鍵新增：詳情頁狀態 ---
  Order? _selectedOrder;
  bool _isDetailLoading = false;
  String? _detailError;

  // --- Getters ---
  List<Order> get orders => _orders;
  bool get isListLoading => _isListLoading;
  String? get listError => _listError;

  Order? get selectedOrder => _selectedOrder;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;

  OrderProvider(this._orderService, this._authProvider) {
    if (_authProvider?.isLoggedIn == true) {
      fetchMyOrders();
    }
  }

  void update(AuthProvider newAuthProvider) {
    if (newAuthProvider.isLoggedIn != _authProvider?.isLoggedIn) {
      _authProvider = newAuthProvider;
      if (newAuthProvider.isLoggedIn) {
        fetchMyOrders();
      } else {
        _orders = [];
        _selectedOrder = null; // 登出時也清除詳情
        notifyListeners();
      }
    }
  }

  Future<void> fetchMyOrders() async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;
    _isListLoading = true;
    _listError = null;
    notifyListeners();
    try {
      _orders = await _orderService.getMyOrders();
    } catch (e) {
      _listError = "無法載入訂單: $e";
    } finally {
      _isListLoading = false;
      notifyListeners();
    }
  }

  // --- 關鍵新增：獲取單一訂單的詳細資訊 ---
  Future<void> fetchOrderById(int orderId) async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;
    _isDetailLoading = true;
    _detailError = null;
    // _selectedOrder = null; // 開始載入前不清空，讓舊資料可以顯示直到新資料載入
    notifyListeners();

    try {
      _selectedOrder = await _orderService.getOrderById(orderId);
    } catch (e) {
      _detailError = "無法載入訂單詳情: $e";
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }
}
