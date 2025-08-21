// --- FILE: lib/providers/checkout_provider.dart ---
import 'package:flutter/foundation.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';

class CheckoutProvider with ChangeNotifier {
  AuthProvider? _authProvider;
  CartProvider? _cartProvider;

  bool _isLoading = false;
  bool _isLoadingAddresses = false;
  bool _isLoadingShippingOptions = false;
  bool _isApplyingCoupon = false;
  bool _isPlacingOrder = false;
  String? _checkoutError;

  List<dynamic> _availableAddresses = [];
  dynamic _selectedAddress;
  List<dynamic> _shippingOptions = [];
  dynamic _selectedShippingOption;
  dynamic _discountInfo;

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isLoadingAddresses => _isLoadingAddresses;
  bool get isLoadingShippingOptions => _isLoadingShippingOptions;
  bool get isApplyingCoupon => _isApplyingCoupon;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get error => _checkoutError;
  String? get checkoutError => _checkoutError;

  List<dynamic> get availableAddresses => _availableAddresses;
  dynamic get selectedAddress => _selectedAddress;
  List<dynamic> get shippingOptions => _shippingOptions;
  dynamic get selectedShippingOption => _selectedShippingOption;
  dynamic get discountInfo => _discountInfo;

  dynamic get checkoutItems {
    if (_cartProvider == null) return <dynamic>[];
    try {
      return _cartProvider!.items.where((item) => item.isSelected).toList();
    } catch (e) {
      return <dynamic>[];
    }
  }

  double get itemsSubtotal {
    if (checkoutItems.isEmpty) return 0.0;
    return checkoutItems.fold(0.0, (sum, item) =>
    sum + (item.product.price * item.quantity));
  }

  double get shippingCost {
    if (_discountInfo?.isFreeShipping == true) return 0.0;
    return _selectedShippingOption?.cost ?? 0.0;
  }

  double get discountAmount => _discountInfo?.discountAmount ?? 0.0;

  double get totalAmount {
    return (itemsSubtotal + shippingCost - discountAmount).clamp(0.0, double.infinity);
  }

  String? get lastAppliedCouponCode => _discountInfo?.appliedCouponCode;

  CheckoutProvider(
      dynamic orderService,
      dynamic addressService,
      AuthProvider? authProvider,
      CartProvider? cartProvider
      ) : _authProvider = authProvider, _cartProvider = cartProvider {
    _initializeCheckoutData();
  }

  void update(AuthProvider? newAuthProvider, CartProvider? newCartProvider) {
    _authProvider = newAuthProvider;
    _cartProvider = newCartProvider;
    _initializeCheckoutData();
    notifyListeners();
  }

  Future<void> _initializeCheckoutData() async {
    if (_authProvider?.isLoggedIn ?? false) {
      await fetchAddresses();
    }
  }

  Future<void> fetchAddresses() async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;

    _isLoadingAddresses = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // 模擬地址數據
      _availableAddresses = [
        MockAddress(
          id: 1,
          recipientName: "張三",
          phoneNumber: "0912345678",
          displayAddress: "台北市大安區忠孝東路四段123號5樓",
        ),
      ];
      if (_availableAddresses.isNotEmpty) {
        _selectedAddress = _availableAddresses.first;
        await fetchShippingMethods();
      }
    } catch (e) {
      _checkoutError = "加載地址失敗: $e";
    } finally {
      _isLoadingAddresses = false;
      notifyListeners();
    }
  }

  void selectAddress(dynamic address) {
    _selectedAddress = address;
    _shippingOptions = [];
    _selectedShippingOption = null;
    notifyListeners();
    if (checkoutItems.isNotEmpty) {
      fetchShippingMethods();
    }
  }

  Future<void> fetchShippingMethods() async {
    if (_selectedAddress == null || checkoutItems.isEmpty) return;

    _isLoadingShippingOptions = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // 模擬配送選項
      _shippingOptions = [
        MockShippingOption(
          id: "standard",
          name: "標準配送",
          description: "3-5個工作天",
          cost: 60.0,
          isEnabled: true,
        ),
        MockShippingOption(
          id: "express",
          name: "快速配送",
          description: "1-2個工作天",
          cost: 120.0,
          isEnabled: true,
        ),
      ];
      if (_shippingOptions.isNotEmpty) {
        _selectedShippingOption = _shippingOptions.first;
      }
    } catch (e) {
      _checkoutError = "加載配送方式失敗: $e";
    } finally {
      _isLoadingShippingOptions = false;
      notifyListeners();
    }
  }

  void selectShippingOption(dynamic option) {
    _selectedShippingOption = option;
    notifyListeners();
  }

  Future<void> applyCoupon(String code) async {
    if (code.isEmpty || checkoutItems.isEmpty) return;

    _isApplyingCoupon = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      // 模擬優惠券驗證
      if (code.toLowerCase() == "discount10") {
        _discountInfo = MockDiscountInfo(
          discountAmount: itemsSubtotal * 0.1,
          appliedCouponCode: code,
          message: "優惠券已套用！享受10%折扣",
          isFreeShipping: false,
        );
      } else {
        _discountInfo = MockDiscountInfo(
          discountAmount: 0.0,
          appliedCouponCode: null,
          message: "無效的優惠券代碼",
          isFreeShipping: false,
        );
      }
    } catch (e) {
      _checkoutError = "套用優惠券失敗: $e";
    } finally {
      _isApplyingCoupon = false;
      notifyListeners();
    }
  }

  Future<dynamic> placeOrder({String paymentMethodId = "default"}) async {
    if (!(_authProvider?.isLoggedIn ?? false)) {
      _checkoutError = "請先登入";
      notifyListeners();
      return null;
    }

    if (_selectedAddress == null || _selectedShippingOption == null || checkoutItems.isEmpty) {
      _checkoutError = "請完成所有必填選項：地址、配送方式和商品。";
      notifyListeners();
      return null;
    }

    _isPlacingOrder = true;
    _checkoutError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (_cartProvider != null) {
        await _cartProvider!.clearSelectedItems();
      }

      // 返回模擬訂單
      final order = MockOrder(
        orderId: "ORD${DateTime.now().millisecondsSinceEpoch}",
        totalAmount: totalAmount,
      );

      return order;
    } catch (e) {
      _checkoutError = "創建訂單失敗: $e";
      return null;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }

  void clearError() {
    _checkoutError = null;
    notifyListeners();
  }
}

// 模擬類
class MockAddress {
  final int id;
  final String recipientName;
  final String phoneNumber;
  final String displayAddress;

  MockAddress({
    required this.id,
    required this.recipientName,
    required this.phoneNumber,
    required this.displayAddress,
  });
}

class MockShippingOption {
  final String id;
  final String name;
  final String description;
  final double cost;
  final bool isEnabled;

  MockShippingOption({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.isEnabled,
  });
}

class MockDiscountInfo {
  final double discountAmount;
  final String? appliedCouponCode;
  final String? message;
  final bool isFreeShipping;

  MockDiscountInfo({
    required this.discountAmount,
    required this.appliedCouponCode,
    required this.message,
    required this.isFreeShipping,
  });
}

class MockOrder {
  final String orderId;
  final double totalAmount;

  MockOrder({
    required this.orderId,
    required this.totalAmount,
  });
}