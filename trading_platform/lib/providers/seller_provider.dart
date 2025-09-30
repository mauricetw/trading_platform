// --- FILE: lib/providers/seller_provider.dart ---
import 'package:flutter/foundation.dart';
import '../models/user/shipping_option.dart';
import '../services/order_service.dart';
import 'auth_provider.dart';

class SellerProvider with ChangeNotifier {
  final OrderService _orderService;
  AuthProvider? _authProvider;

  List<ShippingOption> _shippingOptions = [];
  bool _isLoading = false;
  String? _error;

  List<ShippingOption> get shippingOptions => _shippingOptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SellerProvider(this._orderService, this._authProvider) {
    if (_authProvider?.isLoggedIn == true) {
      fetchShippingOptions();
    }
  }

  void update(AuthProvider newAuthProvider) {
    if (newAuthProvider.isLoggedIn != _authProvider?.isLoggedIn) {
      _authProvider = newAuthProvider;
      if (newAuthProvider.isLoggedIn) {
        fetchShippingOptions();
      } else {
        _shippingOptions = [];
        notifyListeners();
      }
    }
  }

  Future<void> fetchShippingOptions() async {
    if (!(_authProvider?.isLoggedIn ?? false) || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 假設 OrderService 中有一個 getMyShippingOptions 方法
      // 這需要我們稍後在 OrderService 中加入
      _shippingOptions = await _orderService.getMyShippingOptions();
    } catch (e) {
      _error = "無法載入運送方式: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

    // 樂觀更新
    final backupOption = _shippingOptions.removeAt(index);
    notifyListeners();

    try {
      await _orderService.deleteShippingOption(optionId);
    } catch (e) {
      // 如果 API 失敗，則復原
      _shippingOptions.insert(index, backupOption);
      notifyListeners();
      rethrow;
    }
  }
}
