// --- FILE: lib/providers/checkout_provider.dart ---
import 'package:flutter/foundation.dart';
import '../models/user/address.dart';
import '../models/user/shipping_option.dart';
import '../models/user/cart_item.dart';
import '../models/order/discount_info.dart';
import '../models/order/order.dart';
import '../services/order_service.dart';
import '../services/address_service.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';

class CheckoutProvider with ChangeNotifier {
  final OrderService _orderService;
  final AddressService _addressService;
  AuthProvider? _authProvider;
  CartProvider? _cartProvider;

  // --- 狀態 (已全部改為強型別) ---
  List<Address> _availableAddresses = [];
  Address? _selectedAddress;
  List<ShippingOption> _shippingOptions = [];
  ShippingOption? _selectedShippingOption;
  DiscountInfo? _discountInfo;
  String? _lastAppliedCouponCode;

  bool _isLoadingAddresses = false;
  bool _isLoadingShippingOptions = false;
  bool _isApplyingCoupon = false;
  bool _isPlacingOrder = false;
  String? _checkoutError;

  // --- Getters (維持不變) ---
  List<CartItem> get checkoutItems => _cartProvider?.items.where((item) => item.isSelected).toList() ?? [];
  List<Address> get availableAddresses => _availableAddresses;
  Address? get selectedAddress => _selectedAddress;
  List<ShippingOption> get shippingOptions => _shippingOptions;
  ShippingOption? get selectedShippingOption => _selectedShippingOption;
  DiscountInfo? get discountInfo => _discountInfo;
  String? get lastAppliedCouponCode => _lastAppliedCouponCode;

  bool get isLoadingAddresses => _isLoadingAddresses;
  bool get isLoadingShippingOptions => _isLoadingShippingOptions;
  bool get isApplyingCoupon => _isApplyingCoupon;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get checkoutError => _checkoutError;

  double get itemsSubtotal => _cartProvider?.totalSelectedAmount ?? 0.0;
  double get shippingCost => _discountInfo?.isFreeShipping == true ? 0.0 : _selectedShippingOption?.cost ?? 0.0;
  double get discountAmount => _discountInfo?.discountAmount ?? 0.0;
  double get totalAmount => (itemsSubtotal + shippingCost - discountAmount).clamp(0.0, double.infinity);

  // --- 核心邏輯 (已串接真實服務) ---
  CheckoutProvider(this._orderService, this._addressService, this._authProvider, this._cartProvider) {
    if (_authProvider?.isLoggedIn == true) {
      loadInitialData();
    }
  }

  void update(AuthProvider auth, CartProvider cart) {
    _authProvider = auth;
    _cartProvider = cart;
  }

  Future<void> loadInitialData() async {
    _isLoadingAddresses = true;
    _checkoutError = null;
    notifyListeners();
    try {
      // 呼叫真實的 AddressService
      _availableAddresses = await _addressService.getMyAddresses();
      if (_availableAddresses.isNotEmpty) {
        // 預設選擇標記為 isDefault 的地址，如果沒有，則選擇第一個
        final defaultAddress = _availableAddresses.firstWhere((a) => a.isDefault, orElse: () => _availableAddresses.first);
        await selectAddress(defaultAddress);
      }
    } catch (e) {
      _checkoutError = "無法載入地址: $e";
    } finally {
      _isLoadingAddresses = false;
      notifyListeners();
    }
  }

  Future<void> selectAddress(Address address) async {
    _selectedAddress = address;
    _selectedShippingOption = null;
    notifyListeners();
    await fetchShippingOptions();
  }

  Future<void> fetchShippingOptions() async {
    if (_selectedAddress == null || checkoutItems.isEmpty) {
      _shippingOptions = [];
      notifyListeners();
      return;
    }

    _isLoadingShippingOptions = true;
    _checkoutError = null;
    notifyListeners();

    try {
      final sellerId = checkoutItems.first.product.sellerId;
      final options = await _orderService.getAvailableShippingMethods(sellerId);
      _shippingOptions = options;

      if (_shippingOptions.isNotEmpty) {
        _selectedShippingOption = _shippingOptions.firstWhere(
                (opt) => opt.isEnabled,
            orElse: () => _shippingOptions.first
        );
      }
    } catch (e) {
      _checkoutError = "無法載入運送方式: $e";
      _shippingOptions = [];
    } finally {
      _isLoadingShippingOptions = false;
      notifyListeners();
    }
  }

  void selectShippingOption(ShippingOption option) {
    _selectedShippingOption = option;
    notifyListeners();
  }

  Future<void> applyCoupon(String code) async {
    if (code.isEmpty) return;
    _isApplyingCoupon = true;
    _checkoutError = null;
    _lastAppliedCouponCode = code;
    notifyListeners();
    try {
      // TODO: 未來在此處呼叫真實的後端 API
      await Future.delayed(const Duration(seconds: 1));
      if (code.toUpperCase() == "SALE50") {
        _discountInfo = DiscountInfo(discountAmount: 50, message: "已成功折抵 NT\$50", appliedCouponCode: code);
      } else {
        _discountInfo = DiscountInfo(discountAmount: 0, message: "無效的優惠券代碼", appliedCouponCode: code);
      }
    } catch (e) {
      _discountInfo = DiscountInfo(discountAmount: 0, message: "驗證優惠券失敗: $e", appliedCouponCode: code);
    } finally {
      _isApplyingCoupon = false;
      notifyListeners();
    }
  }

  Future<Order?> placeOrder() async {
    if (_isPlacingOrder || _selectedAddress == null || _selectedShippingOption == null || checkoutItems.isEmpty) {
      _checkoutError = "請確認所有欄位皆已選擇";
      notifyListeners();
      return null;
    }
    _isPlacingOrder = true;
    _checkoutError = null;
    notifyListeners();

    try {
      // --- 直接使用 int 類型的 ID ---
      final order = await _orderService.createOrder(
        addressId: _selectedAddress!.id,
        shippingOptionId: _selectedShippingOption!.id, // id 已經是 int
        cartItemIds: checkoutItems.map((item) => item.id!).where((id) => id != null).toList(), // 確保 id 不為 null
        couponCode: _discountInfo?.appliedCouponCode,
      );

      _cartProvider?.clearLocalCart();
      return order;

    } catch (e) {
      _checkoutError = "下單失敗: $e";
      return null;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }
}
