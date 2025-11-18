// --- FILE: lib/providers/seller_provider.dart ---
import 'package:flutter/foundation.dart';
import '../models/user/shipping_option.dart';
import '../models/order/order.dart';
import '../services/order_service.dart';
import 'auth_provider.dart';

class SellerProvider with ChangeNotifier {
  final OrderService _orderService;
  AuthProvider? _authProvider;

  List<ShippingOption> _shippingOptions = [];
  List<Order> _sellerOrders = [];
  bool _isLoading = false;
  String? _error;

  List<ShippingOption> get shippingOptions => _shippingOptions;
  List<Order> get sellerOrders => _sellerOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SellerProvider(this._orderService, this._authProvider) {
    _updateDependencies();
  }

  void update(AuthProvider newAuthProvider) {
    if (newAuthProvider.isLoggedIn != _authProvider?.isLoggedIn) {
      _authProvider = newAuthProvider;
      _updateDependencies();
    }
  }

  void _updateDependencies() {
    if (_authProvider?.isLoggedIn == true) {
      // 2. 登入時，同時獲取所有賣家相關資料
      fetchMySellerData();
    } else {
      _shippingOptions = [];
      _sellerOrders = [];
      notifyListeners();
    }
  }

  /// 整合所有賣家資料的獲取
  Future<void> fetchMySellerData() async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // 3. 使用 Future.wait 並行獲取，提升效率
      await Future.wait([
        _fetchShippingOptionsInternal(),
        _fetchSellerOrdersInternal(),
      ]);
    } catch (e) {
      _error = "無法載入賣家資料: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- (運送選項的 CRUD 方法保持不變) ---

  Future<void> _fetchShippingOptionsInternal() async {
    _shippingOptions = await _orderService.getMyShippingOptions();
  }

  Future<void> fetchShippingOptions() async {
    // 外部呼叫的刷新方法
    await _fetchShippingOptionsInternal();
    notifyListeners();
  }

  Future<void> addShippingOption(Map<String, dynamic> data) async {
    final newOption = await _orderService.addShippingOption(data);
    _shippingOptions.insert(0, newOption);
    notifyListeners();
  }

  Future<void> updateShippingOption(int optionId, Map<String, dynamic> data) async {
    final updatedOption = await _orderService.updateShippingOption(optionId, data);
    final index = _shippingOptions.indexWhere((opt) => opt.id == optionId);
    if (index != -1) {
      _shippingOptions[index] = updatedOption;
      notifyListeners();
    }
  }

  Future<void> deleteShippingOption(int optionId) async {
    final index = _shippingOptions.indexWhere((opt) => opt.id == optionId);
    if (index == -1) return;
    final backupOption = _shippingOptions.removeAt(index);
    notifyListeners();
    try {
      await _orderService.deleteShippingOption(optionId);
    } catch (e) {
      _shippingOptions.insert(index, backupOption);
      notifyListeners();
      rethrow;
    }
  }

  // --- 關鍵新增：獲取和更新賣家訂單的方法 ---

  Future<void> _fetchSellerOrdersInternal({OrderStatus? status}) async {
    _sellerOrders = await _orderService.getMySellerOrders(status: status);
  }

  Future<void> fetchSellerOrders({OrderStatus? status}) async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _fetchSellerOrdersInternal(status: status);
    } catch (e) {
      _error = "無法載入收到的訂單: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(int orderId, OrderStatus newStatus, {String? description}) async {
    try {
      final updatedOrder = await _orderService.updateOrderStatusAsSeller(
        orderId: orderId,
        newStatus: newStatus,
        description: description,
      );
      // 更新本地列表中的訂單狀態
      final index = _sellerOrders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        _sellerOrders[index] = updatedOrder;
        notifyListeners();
      }
    } catch (e) {
      _error = "更新訂單狀態失敗: $e";
      notifyListeners();
      rethrow; // 向上拋出，讓 UI 顯示提示
    }
  }

  // --- [新功能] 賣家標記為未取貨退回 ---
  Future<void> markOrderAsReturned(int orderId) async {
    try {
      // 1. 呼叫我們在 Service 中建立的新函式
      final updatedOrder = await _orderService.markOrderAsReturned(orderId);

      // 2. 更新本地列表中的訂單狀態
      final index = _sellerOrders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        _sellerOrders[index] = updatedOrder;
        notifyListeners();
      }
    } catch (e) {
      _error = "標記訂單退回失敗: $e";
      notifyListeners();
      rethrow; // 向上拋出，讓 UI 顯示提示
    }
  }
}
