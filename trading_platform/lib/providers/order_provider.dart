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
      _orders = await _orderService.getMyBuyerOrders();
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

  // --- [新功能] 買家確認完成訂單 ---
  Future<void> completeOrder(int orderId) async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;

    try {
      // 1. 呼叫 API，獲取更新後的訂單
      final updatedOrder = await _orderService.completeOrderAsBuyer(orderId);

      // 2. 更新本地列表中的訂單
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }

      // 3. 如果這筆訂單剛好是 "selectedOrder"，也更新它
      if (_selectedOrder?.orderId == orderId) {
        _selectedOrder = updatedOrder;
      }

      // 4. 通知 UI 更新
      notifyListeners();

    } catch (e) {
      // 顯示錯誤，但不修改本地狀態
      _detailError = "完成訂單失敗: $e"; // 顯示在詳情錯誤中
      notifyListeners();
      rethrow; // 讓 UI 知道失敗了
    }
  }
}