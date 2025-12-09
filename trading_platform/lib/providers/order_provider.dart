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

  // --- 詳情頁狀態 ---
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
        _selectedOrder = null;
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
      _orders = await _orderService.getMyBuyerOrders();
    } catch (e) {
      _listError = "無法載入訂單: $e";
    } finally {
      _isListLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderById(int orderId) async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;
    _isDetailLoading = true;
    _detailError = null;
    notifyListeners();

    try {
      _selectedOrder = await _orderService.getBuyerOrderById(orderId);
    } catch (e) {
      _detailError = "無法載入訂單詳情: $e";
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  // --- 買家確認完成訂單 ---
  Future<void> completeOrder(int orderId) async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;

    try {
      final updatedOrder = await _orderService.completeOrderAsBuyer(orderId);
      _updateLocalOrder(updatedOrder);
      notifyListeners();
    } catch (e) {
      _detailError = "完成訂單失敗: $e";
      notifyListeners();
      rethrow;
    }
  }

  // --- [新功能] 買家取消訂單 ---
  Future<void> cancelOrder(int orderId) async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;

    try {
      final updatedOrder = await _orderService.cancelOrderAsBuyer(orderId);
      _updateLocalOrder(updatedOrder);
      notifyListeners();
    } catch (e) {
      _detailError = "取消訂單失敗: $e";
      notifyListeners();
      rethrow;
    }
  }

  // 輔助函式：更新本地列表和詳情
  void _updateLocalOrder(Order updatedOrder) {
    // 1. 更新列表
    final index = _orders.indexWhere((o) => o.orderId == updatedOrder.orderId);
    if (index != -1) {
      _orders[index] = updatedOrder;
    }
    // 2. 更新詳情
    if (_selectedOrder?.orderId == updatedOrder.orderId) {
      _selectedOrder = updatedOrder;
    }
  }
}