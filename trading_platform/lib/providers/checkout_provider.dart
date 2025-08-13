// --- FILE: lib/providers/checkout_provider.dart ---
import 'package:flutter/material.dart';
import '../models/user/address.dart';
import '../models/user/cart_item.dart';
import '../models/user/shipping_option.dart';
import '../models/order/order.dart';
import '../models/order/order_creation_data.dart';
import '../models/order/discount_info.dart';
import '../services/interfaces/order_service_interface.dart';
import '../services/interfaces/address_service_interface.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';

class CheckoutProvider with ChangeNotifier {
  final IOrderService _orderService;
  final IAddressService _addressService;
  AuthProvider? _authProvider;
  CartProvider? _cartProvider;

  // --- 狀態變量 ---
  bool _isLoadingAddresses = false;
  bool get isLoadingAddresses => _isLoadingAddresses;
  bool _isLoadingShippingOptions = false;
  bool get isLoadingShippingOptions => _isLoadingShippingOptions;
  bool _isApplyingCoupon = false;
  bool get isApplyingCoupon => _isApplyingCoupon;
  bool _isPlacingOrder = false;
  bool get isPlacingOrder => _isPlacingOrder;

  List<Address> _availableAddresses = [];
  List<Address> get availableAddresses => List.unmodifiable(_availableAddresses);
  Address? _selectedAddress;
  Address? get selectedAddress => _selectedAddress;

  List<ShippingOption> _shippingOptions = [];
  List<ShippingOption> get shippingOptions => List.unmodifiable(_shippingOptions);
  ShippingOption? _selectedShippingOption;
  ShippingOption? get selectedShippingOption => _selectedShippingOption;

  List<CartItem> get checkoutItems => _cartProvider?.items.where((item) => item.isSelected).toList() ?? [];

  DiscountInfo? _discountInfo;
  DiscountInfo? get discountInfo => _discountInfo;

  String? _checkoutError;
  String? get checkoutError => _checkoutError;

  OrderModel? _createdOrder;
  OrderModel? get createdOrder => _createdOrder;

  int? get _currentUserId => _authProvider?.currentUser?.id;

  // 建構函式，接收傳入的 Provider
  CheckoutProvider(
      this._orderService,
      this._addressService,
      this._authProvider,
      this._cartProvider,
      ) {
    _initializeCheckoutData();
    _authProvider?.addListener(_onDependenciesChanged);
    _cartProvider?.addListener(_onDependenciesChanged);
  }

  @override
  void dispose() {
    _authProvider?.removeListener(_onDependenciesChanged);
    _cartProvider?.removeListener(_onDependenciesChanged);
    super.dispose();
  }

  // 當依賴的 AuthProvider 或 CartProvider 更新時，由 ProxyProvider 呼叫
  void update(AuthProvider newAuthProvider, CartProvider newCartProvider) {
    _authProvider?.removeListener(_onDependenciesChanged);
    _cartProvider?.removeListener(_onDependenciesChanged);

    _authProvider = newAuthProvider;
    _cartProvider = newCartProvider;

    _initializeCheckoutData();
    _authProvider?.addListener(_onDependenciesChanged);
    _cartProvider?.addListener(_onDependenciesChanged);
  }

  void _onDependenciesChanged() {
    _initializeCheckoutData();
    _discountInfo = null;
    if (checkoutItems.isEmpty) {
      _selectedShippingOption = null;
      _shippingOptions = [];
    }
    notifyListeners();
  }

  Future<void> _initializeCheckoutData() async {
    if (_currentUserId == null) {
      resetCheckoutState(notify: true);
      return;
    }
    if (_availableAddresses.isEmpty) {
      await fetchAddresses();
    }
    else if (_selectedAddress != null && checkoutItems.isNotEmpty && _shippingOptions.isEmpty) {
      await fetchShippingMethods();
    }
  }

  // --- Getters ---
  double get itemsSubtotal {
    if (checkoutItems.isEmpty) return 0.0;
    return checkoutItems.fold(
        0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  double get shippingCost {
    if (_discountInfo?.isFreeShipping == true) return 0.0;
    return _selectedShippingOption?.cost ?? 0.0;
  }

  double get discountAmount => _discountInfo?.discountAmount ?? 0.0;
  double get totalAmount => (itemsSubtotal + shippingCost - discountAmount).clamp(0.0, double.infinity);
  String? get lastAppliedCouponCode => _discountInfo?.appliedCouponCode;


  // --- Methods ---

  Future<void> fetchAddresses() async {
    if (_currentUserId == null) return;
    _isLoadingAddresses = true;
    notifyListeners();
    try {
      _availableAddresses = await _addressService.getUserAddresses(_currentUserId!.toString());
      if (_availableAddresses.isNotEmpty) {
        selectAddress(_availableAddresses.first);
      }
    } catch (e) {
      _checkoutError = "加載地址失敗: $e";
    } finally {
      _isLoadingAddresses = false;
      notifyListeners();
    }
  }

  void selectAddress(Address address) {
    if (_selectedAddress?.id == address.id) return;
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
      _shippingOptions = await _orderService.getAvailableShippingMethods(_selectedAddress!, checkoutItems);
      if (_shippingOptions.isNotEmpty) {
        _selectedShippingOption = _shippingOptions.firstWhere((opt) => opt.isEnabled, orElse: () => _shippingOptions.first);
      }
    } catch (e) {
      _checkoutError = "加載配送方式失敗: $e";
    } finally {
      _isLoadingShippingOptions = false;
      notifyListeners();
    }
  }

  void selectShippingOption(ShippingOption option) {
    if (_selectedShippingOption?.id == option.id) return;
    _selectedShippingOption = option;
    notifyListeners();
  }

  Future<void> applyCoupon(String code) async {
    if (code.isEmpty || checkoutItems.isEmpty) return;
    _isApplyingCoupon = true;
    notifyListeners();
    try {
      _discountInfo = await _orderService.applyCoupon(code, checkoutItems, itemsSubtotal, shippingCost);
    } catch (e) {
      _checkoutError = "套用優惠券失敗: $e";
    } finally {
      _isApplyingCoupon = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> placeOrder({String paymentMethodId = "default"}) async {
    if (_currentUserId == null || _selectedAddress == null || _selectedShippingOption == null || checkoutItems.isEmpty) {
      _checkoutError = "請完成所有必填選項：地址、配送方式和商品。";
      notifyListeners();
      return null;
    }
    _isPlacingOrder = true;
    notifyListeners();
    try {
      final orderData = OrderCreationData(
        userId: _currentUserId!.toString(),
        items: checkoutItems,
        shippingAddress: _selectedAddress!,
        shippingMethodId: _selectedShippingOption!.id,
        paymentMethodId: paymentMethodId,
        subtotal: itemsSubtotal,
        shippingFee: _selectedShippingOption!.cost,
        discountAmount: discountAmount,
        couponCode: lastAppliedCouponCode,
        totalAmount: totalAmount,
      );
      _createdOrder = await _orderService.createOrder(orderData);
      if (_createdOrder != null) {
        _cartProvider?.clearSelectedItems();
      }
      return _createdOrder;
    } catch (e) {
      _checkoutError = "訂單建立失敗: $e";
      return null;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }

  void resetCheckoutState({bool notify = true}) {
    _availableAddresses = [];
    _selectedAddress = null;
    _shippingOptions = [];
    _selectedShippingOption = null;
    _discountInfo = null;
    _checkoutError = null;
    _createdOrder = null;
    if (notify) notifyListeners();
  }
}
