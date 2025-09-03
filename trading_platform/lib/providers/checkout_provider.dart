// --- FILE: lib/providers/checkout_provider.dart ---
import 'package:flutter/foundation.dart';

import '../models/user/address.dart';
import '../models/user/shipping_option.dart';
import '../models/user/cart_item.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';
import '../config/api_config.dart'; // 若要用 mock 判斷可使用
// 你如果有真正的 Order 回傳型別，可改為該型別
class OrderConfirmation {
  final String orderId;
  final double totalAmount;
  OrderConfirmation({required this.orderId, required this.totalAmount});
}

/// 優惠資訊（從 dynamic 換成強型別）
class DiscountInfo {
  final double discountAmount;
  final String? appliedCouponCode;
  final String? message;
  final bool isFreeShipping;

  const DiscountInfo({
    required this.discountAmount,
    this.appliedCouponCode,
    this.message,
    this.isFreeShipping = false,
  });

  DiscountInfo copyWith({
    double? discountAmount,
    String? appliedCouponCode,
    String? message,
    bool? isFreeShipping,
  }) {
    return DiscountInfo(
      discountAmount: discountAmount ?? this.discountAmount,
      appliedCouponCode: appliedCouponCode ?? this.appliedCouponCode,
      message: message ?? this.message,
      isFreeShipping: isFreeShipping ?? this.isFreeShipping,
    );
  }
}

class CheckoutProvider with ChangeNotifier {
  // services（保留為 dynamic/抽象，或改成你的具體型別）
  final dynamic _orderService;
  final dynamic _addressService;

  AuthProvider? _authProvider;
  CartProvider? _cartProvider;

  bool _isLoading = false;
  bool _isLoadingAddresses = false;
  bool _isLoadingShippingOptions = false;
  bool _isApplyingCoupon = false;
  bool _isPlacingOrder = false;
  String? _checkoutError;

  List<Address> _availableAddresses = <Address>[];
  Address? _selectedAddress;

  List<ShippingOption> _shippingOptions = <ShippingOption>[];
  ShippingOption? _selectedShippingOption;

  DiscountInfo? _discountInfo;

  // --- Getters ---
  bool get isLoading => _isLoading;
  bool get isLoadingAddresses => _isLoadingAddresses;
  bool get isLoadingShippingOptions => _isLoadingShippingOptions;
  bool get isApplyingCoupon => _isApplyingCoupon;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get checkoutError => _checkoutError;

  List<Address> get availableAddresses => _availableAddresses;
  Address? get selectedAddress => _selectedAddress;

  List<ShippingOption> get shippingOptions => _shippingOptions;
  ShippingOption? get selectedShippingOption => _selectedShippingOption;

  DiscountInfo? get discountInfo => _discountInfo;

  List<CartItem> get checkoutItems {
    final cart = _cartProvider;
    if (cart == null) return const <CartItem>[];
    return cart.items.where((it) => it.isSelected).toList();
  }

  double get itemsSubtotal {
    if (checkoutItems.isEmpty) return 0.0;
    return checkoutItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  double get shippingCost {
    if (_discountInfo?.isFreeShipping == true) return 0.0;
    return _selectedShippingOption?.cost ?? 0.0;
    // 若 ShippingOption.cost 是 double? 就改成: (_selectedShippingOption?.cost ?? 0.0)
  }

  double get discountAmount => _discountInfo?.discountAmount ?? 0.0;

  double get totalAmount => (itemsSubtotal + shippingCost - discountAmount).clamp(0.0, double.infinity);

  String? get lastAppliedCouponCode => _discountInfo?.appliedCouponCode;

  CheckoutProvider(
      this._orderService,
      this._addressService, {
        AuthProvider? authProvider,
        CartProvider? cartProvider,
      })  : _authProvider = authProvider,
        _cartProvider = cartProvider {
    _initializeCheckoutData();
  }

  /// 由 ProxyProvider 的 update 呼叫
  void update(AuthProvider? newAuth, CartProvider? newCart) {
    _authProvider = newAuth;
    _cartProvider = newCart;
    _initializeCheckoutData();
    notifyListeners();
  }

  Future<void> _initializeCheckoutData() async {
    if (_authProvider?.isLoggedIn ?? false) {
      await fetchAddresses();
    } else {
      _availableAddresses = <Address>[];
      _selectedAddress = null;
      _shippingOptions = <ShippingOption>[];
      _selectedShippingOption = null;
      _discountInfo = null;
      notifyListeners();
    }
  }

  // ----------------
  // 地址
  // ----------------
  Future<void> fetchAddresses() async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;
    _isLoadingAddresses = true;
    _checkoutError = null;
    notifyListeners();

    try {
      // 真實 or Mock（這裡示範 mock：請改成呼叫你的 AddressService）
      if (APIConfig.useMock) {
        // 你自己的 mock 地址來源，務必是 Address 型別的 List
        // 例如：final list = await _addressService.getMyAddresses();
        final list = <Address>[
          Address(
            id: 'addr_1',
            userId: 'u_mock',
            recipientName: '張三',
            phoneNumber: '0912345678',
            country: '台灣',
            city: '台北市',
            district: '大安區',
            streetAddress1: '忠孝東路四段123號5樓',
            isDefault: true,
          ),
        ];
        _availableAddresses = list;
      } else {
        final list = await _addressService.getMyAddresses();
        _availableAddresses = list;
      }

      if (_availableAddresses.isNotEmpty) {
        _selectedAddress = _availableAddresses.firstWhere(
              (a) => a.isDefault,
          orElse: () => _availableAddresses.first,
        );
        await fetchShippingMethods();
      }
    } catch (e) {
      _checkoutError = '加載地址失敗: $e';
    } finally {
      _isLoadingAddresses = false;
      notifyListeners();
    }
  }

  void selectAddress(Address address) {
    _selectedAddress = address;
    _shippingOptions = <ShippingOption>[];
    _selectedShippingOption = null;
    notifyListeners();

    if (checkoutItems.isNotEmpty) {
      fetchShippingMethods();
    }
  }

  // ----------------
  // 配送方式
  // ----------------
  Future<void> fetchShippingMethods() async {
    if (_selectedAddress == null || checkoutItems.isEmpty) return;

    _isLoadingShippingOptions = true;
    _checkoutError = null;
    notifyListeners();

    try {
      if (APIConfig.useMock) {
        _shippingOptions = <ShippingOption>[
          ShippingOption(
            id: 'standard',
            name: '標準配送',
            cost: 60,
            description: '3-5 個工作天',
            isEnabled: true,
            createdAt: DateTime.now(),
          ),
          ShippingOption(
            id: 'express',
            name: '快速配送',
            cost: 120,
            description: '1-2 個工作天',
            isEnabled: true,
            createdAt: DateTime.now(),
          ),
        ];
      } else {
        // 依據 _selectedAddress + checkoutItems 呼叫後端算運費/可用方案
        // _shippingOptions = await _orderService.getShippingOptions(...);
        _shippingOptions = <ShippingOption>[]; // TODO: 改成真實呼叫
      }

      if (_shippingOptions.isNotEmpty) {
        _selectedShippingOption = _shippingOptions.first;
      }
    } catch (e) {
      _checkoutError = '加載配送方式失敗: $e';
    } finally {
      _isLoadingShippingOptions = false;
      notifyListeners();
    }
  }

  void selectShippingOption(ShippingOption option) {
    _selectedShippingOption = option;
    notifyListeners();
  }

  // ----------------
  // 優惠券
  // ----------------
  Future<void> applyCoupon(String code) async {
    if (code.isEmpty || checkoutItems.isEmpty) return;

    _isApplyingCoupon = true;
    _checkoutError = null;
    notifyListeners();

    try {
      if (APIConfig.useMock) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (code.toLowerCase() == 'discount10') {
          _discountInfo = DiscountInfo(
            discountAmount: itemsSubtotal * 0.1,
            appliedCouponCode: code,
            message: '優惠券已套用！享受 10% 折扣',
            isFreeShipping: false,
          );
        } else {
          _discountInfo = const DiscountInfo(
            discountAmount: 0.0,
            appliedCouponCode: null,
            message: '無效的優惠券代碼',
            isFreeShipping: false,
          );
        }
      } else {
        // 真實 API 驗證優惠券
        // final res = await _orderService.applyCoupon(code, checkoutItems, ...);
        // _discountInfo = DiscountInfo(...);
      }
    } catch (e) {
      _checkoutError = '套用優惠券失敗: $e';
    } finally {
      _isApplyingCoupon = false;
      notifyListeners();
    }
  }

  // ----------------
  // 下單
  // ----------------
  Future<OrderConfirmation?> placeOrder({String paymentMethodId = 'default'}) async {
    if (!(_authProvider?.isLoggedIn ?? false)) {
      _checkoutError = '請先登入';
      notifyListeners();
      return null;
    }
    if (_selectedAddress == null || _selectedShippingOption == null || checkoutItems.isEmpty) {
      _checkoutError = '請完成所有必填選項：地址、配送方式和商品。';
      notifyListeners();
      return null;
    }

    _isPlacingOrder = true;
    _checkoutError = null;
    notifyListeners();

    try {
      if (APIConfig.useMock) {
        await Future.delayed(const Duration(milliseconds: 800));

        // 清掉已勾選的購物車
        await _cartProvider?.clearSelectedItems();

        return OrderConfirmation(
          orderId: 'ORD${DateTime.now().millisecondsSinceEpoch}',
          totalAmount: totalAmount,
        );
      } else {
        // 呼叫真實 API 建立訂單
        // final order = await _orderService.placeOrder(...);
        // await _cartProvider?.clearSelectedItems();
        // return OrderConfirmation(orderId: order.id, totalAmount: order.total);
        return null; // TODO
      }
    } catch (e) {
      _checkoutError = '創建訂單失敗: $e';
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
