import 'package:flutter/material.dart';
import '../models/user/address.dart';
import '../models/user/cart_item.dart';
import '../models/user/shipping_option.dart';
import '../models/order/order.dart'; // 包含 OrderModel
import '../models/order/order_creation_data.dart';
import '../models/order/discount_info.dart';
import '../services/interfaces/order_service_interface.dart';
import '../services/interfaces/address_service_interface.dart';

// 【【新增】】導入您項目中的 AuthProvider 和 CartProvider
import 'auth_provider.dart'; // 假設路徑，請根據您的項目結構修改
import 'cart_provider.dart';   // 假設路徑，請根據您的項目結構修改

class CheckoutProvider with ChangeNotifier {
  final IOrderService _orderService;
  final IAddressService _addressService;
  final AuthProvider _authProvider; // 【【新增】】
  final CartProvider _cartProvider;   // 【【新增】】

  // --- 狀態變量 ---
  bool _isLoadingOverall = false;
  bool get isLoadingOverall => _isLoadingOverall;

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

  // _checkoutItems 現在將從 CartProvider 的選中商品獲取
  List<CartItem> get checkoutItems => _cartProvider.selectedItems; // 【【修改】】直接從 CartProvider 獲取

  DiscountInfo? _discountInfo;
  DiscountInfo? get discountInfo => _discountInfo;

  String? _checkoutError;
  String? get checkoutError => _checkoutError;

  OrderModel? _createdOrder;
  OrderModel? get createdOrder => _createdOrder;

  String? get _currentUserId => _authProvider.currentUser?.id; // 【【新增】】輔助 getter

  // 【【修改】】構造函數以接收 AuthProvider 和 CartProvider
  CheckoutProvider(
      this._orderService,
      this._addressService,
      this._authProvider,
      this._cartProvider,
      ) {
    // 【【新增】】監聽 AuthProvider 和 CartProvider 的變化
    _authProvider.addListener(_handleAuthOrCartChange);
    _cartProvider.addListener(_handleAuthOrCartChange);

    // 初始加載數據（如果用戶已登錄且購物車有商品）
    _initializeCheckoutData();
  }

  // 【【新增】】處理認證或購物車變化的方法
  void _handleAuthOrCartChange() {
    print("CheckoutProvider: Auth or Cart changed. Re-initializing checkout data.");
    // 當用戶登錄狀態或購物車選中項變化時，重新初始化結帳數據
    _initializeCheckoutData();
    // 購物車變化可能導致優惠券失效或運費變化
    _discountInfo = null; // 清除舊的優惠券信息
    if (checkoutItems.isEmpty) { // 如果購物車變為空
      _selectedShippingOption = null; // 清除配送方式
      _shippingOptions = [];
    }
    notifyListeners(); // 通知UI更新
  }

  // 【【新增】】初始化或刷新結帳數據的邏輯
  Future<void> _initializeCheckoutData() async {
    if (_currentUserId == null) {
      print("CheckoutProvider: User not logged in. Clearing checkout state.");
      resetCheckoutState(notify: false); // 重置狀態但不立即通知，等待後續操作
      _availableAddresses = []; // 清空地址
      _selectedAddress = null;
      notifyListeners();
      return;
    }

    // 如果購物車為空，則不需要加載配送等
    if (checkoutItems.isEmpty) {
      print("CheckoutProvider: Checkout items are empty. Not fetching shipping methods.");
      _shippingOptions = [];
      _selectedShippingOption = null;
      // 仍然需要加載地址
      if (_availableAddresses.isEmpty) { // 只有在地址列表為空時才加載
        await fetchAddresses();
      }
      notifyListeners();
      return;
    }

    _isLoadingOverall = true;
    notifyListeners();

    await fetchAddresses(); // 加載或刷新地址
    // fetchAddresses 內部會在選中默認地址後嘗試 fetchShippingMethods
    // 所以這裡不需要再次顯式調用 fetchShippingMethods，除非 fetchAddresses 邏輯有變

    _isLoadingOverall = false;
    notifyListeners();
  }


  // --- Getters ---
  double get itemsSubtotal {
    if (checkoutItems.isEmpty) return 0.0; // 使用 getter checkoutItems
    return checkoutItems.fold(
        0.0, (sum, item) => sum + (item.productPrice * item.quantity));
  }

  double get shippingCost {
    if (_discountInfo?.isFreeShipping == true && _selectedShippingOption != null) {
      return 0.0;
    }
    return _selectedShippingOption?.cost ?? 0.0;
  }

  double get discountAmount => _discountInfo?.discountAmount ?? 0.0;
  String? get lastAppliedCouponCode => _discountInfo?.appliedCouponCode;

  double get totalAmount {
    double currentSubtotal = itemsSubtotal;
    double currentShippingCost = shippingCost;
    double currentDiscount = discountAmount;
    double calculatedTotal = currentSubtotal + currentShippingCost - currentDiscount;
    return calculatedTotal > 0 ? calculatedTotal : 0.0;
  }

  // --- Methods ---

  // loadInitialData 現在由 _initializeCheckoutData 和構造函數處理，可以考慮移除或保留用於手動刷新
  Future<void> loadInitialData() async {
    print("CheckoutProvider: Manual loadInitialData called.");
    await _initializeCheckoutData();
  }

  // setCheckoutItems 方法不再需要從外部調用，因為 CheckoutProvider 會監聽 CartProvider
  // 如果確實需要一個從外部強制更新購物車項目觸發邏輯的入口，可以保留並調整
  // 但通常情況下，響應 CartProvider 的變化是更好的模式。
  // void setCheckoutItems(List<CartItem> items) { ... } // 可以考慮移除


  Future<void> fetchAddresses() async {
    if (_currentUserId == null) {
      _checkoutError = "用戶未登錄，無法加載地址。";
      _availableAddresses = [];
      _selectedAddress = null;
      notifyListeners();
      return;
    }

    _isLoadingAddresses = true;
    _checkoutError = null;
    notifyListeners();
    try {
      _availableAddresses = await _addressService.getUserAddresses(_currentUserId!);
      if (_availableAddresses.isNotEmpty) {
        Address? defaultAddr = await _addressService.getDefaultAddress(_currentUserId!);
        Address? newSelectedAddress = null;

        if (defaultAddr != null && _availableAddresses.any((addr) => addr.id == defaultAddr.id)) {
          newSelectedAddress = defaultAddr;
        } else if (_availableAddresses.isNotEmpty) {
          // 如果沒有默認地址，或者默認地址不在列表中，可以考慮選中第一個
          // newSelectedAddress = _availableAddresses.first;
          // 或者讓用戶手動選擇，這裡暫時不自動選擇，除非 _selectedAddress 原本就是 null
        }

        if (newSelectedAddress != null && _selectedAddress?.id != newSelectedAddress.id) {
          _selectedAddress = newSelectedAddress;
          _shippingOptions = [];
          _selectedShippingOption = null;
          _discountInfo = null;
          if (checkoutItems.isNotEmpty) {
            await fetchShippingMethods();
          }
        } else if (_selectedAddress != null && !_availableAddresses.any((addr) => addr.id == _selectedAddress!.id)) {
          // 如果之前選中的地址不在新的地址列表中了，清空它
          _selectedAddress = null;
          _shippingOptions = [];
          _selectedShippingOption = null;
          _discountInfo = null;
        } else if (checkoutItems.isNotEmpty && _selectedAddress != null && _shippingOptions.isEmpty) {
          // 如果地址沒變，但配送方式是空的，嘗試獲取
          await fetchShippingMethods();
        }

      } else {
        _availableAddresses = [];
        _selectedAddress = null;
        _shippingOptions = [];
        _selectedShippingOption = null;
        _checkoutError = "尚無可用地址，請先新增。";
      }
    } catch (e) {
      _checkoutError = "加載地址失敗: $e";
      print(_checkoutError);
      _availableAddresses = []; // 出錯時清空，避免UI顯示舊數據
      _selectedAddress = null;
    } finally {
      _isLoadingAddresses = false;
      notifyListeners();
    }
  }

  void selectAddress(Address address) {
    if (_selectedAddress?.id == address.id) return;

    _selectedAddress = address;
    _shippingOptions = []; // 地址改變，配送選項重置
    _selectedShippingOption = null;
    _discountInfo = null; // 地址改變，優惠券可能失效
    _checkoutError = null;
    notifyListeners();

    if (checkoutItems.isNotEmpty) {
      fetchShippingMethods();
    }
  }

  Future<void> fetchShippingMethods() async {
    if (_selectedAddress == null || checkoutItems.isEmpty) {
      _shippingOptions = [];
      _selectedShippingOption = null;
      // 不在此處設置 checkoutError，除非是明確的 "無地址" 或 "購物車空" 導致的
      notifyListeners();
      return;
    }
    _isLoadingShippingOptions = true;
    _checkoutError = null;
    notifyListeners();
    try {
      _shippingOptions = await _orderService.getAvailableShippingMethods(
          _selectedAddress!, checkoutItems); // 使用 getter checkoutItems
      if (_shippingOptions.isNotEmpty) {
        // 如果之前選擇的配送方式仍然可用，則保持選中，否則可以考慮選中第一個可用的
        if (_selectedShippingOption != null && !_shippingOptions.any((opt) => opt.id == _selectedShippingOption!.id && opt.isEnabled)) {
          _selectedShippingOption = null; // 清除無效的選擇
        }
        if (_selectedShippingOption == null) {
          // 可以默認選中第一個可用的，如果 UI/UX 需要
          // ShippingOption? firstEnabled = _shippingOptions.firstWhere((opt) => opt.isEnabled, orElse: () => null);
          // if (firstEnabled != null) _selectedShippingOption = firstEnabled;
        }
      } else {
        _selectedShippingOption = null;
        _checkoutError = "此地址無可用配送方式。";
      }
    } catch (e) {
      _checkoutError = "加載配送方式失敗: $e";
      print(_checkoutError);
      _shippingOptions = [];
      _selectedShippingOption = null;
    } finally {
      _isLoadingShippingOptions = false;
      notifyListeners();
    }
  }

  void selectShippingOption(ShippingOption option) {
    if (_selectedShippingOption?.id == option.id) return;
    _selectedShippingOption = option;
    _checkoutError = null;
    // 運費變化可能影響總價和優惠券，相關邏輯在 getter 中自動處理
    // 如果優惠券是免運費類型，shippingCost getter 會處理
    notifyListeners();
  }

  // applyCoupon 現在使用 checkoutItems getter
  Future<void> applyCoupon(String code) async { // 不再需要傳入 items
    if (code.isEmpty) {
      _discountInfo = DiscountInfo(
          appliedCouponCode: null, discountAmount: 0, message: "請輸入優惠券代碼。", isFreeShipping: false);
      notifyListeners();
      return;
    }
    if (checkoutItems.isEmpty) {
      _discountInfo = DiscountInfo(
          appliedCouponCode: code, discountAmount: 0, message: "購物車是空的，無法套用優惠券。", isFreeShipping: false);
      notifyListeners();
      return;
    }

    _isApplyingCoupon = true;
    _checkoutError = null;
    _discountInfo = null;
    notifyListeners();

    try {
      // itemsSubtotal 和 shippingCost getter 會提供最新值
      final di = await _orderService.applyCoupon(code, checkoutItems, itemsSubtotal, shippingCost);
      _discountInfo = di;
    } on Exception catch (e) {
      _discountInfo = DiscountInfo(
          appliedCouponCode: code, discountAmount: 0, message: e.toString().replaceFirst("Exception: ", ""), isFreeShipping: false);
    } catch (e) {
      _discountInfo = DiscountInfo(
          appliedCouponCode: code, discountAmount: 0, message: "套用優惠券時發生錯誤。", isFreeShipping: false);
      print("Apply coupon error: $e");
    } finally {
      _isApplyingCoupon = false;
      notifyListeners();
    }
  }

  Future<bool> placeOrder({String paymentMethodId = "default_payment"}) async {
    if (_currentUserId == null) {
      _checkoutError = "用戶未登錄，無法下單。";
      notifyListeners();
      return false;
    }
    if (_selectedAddress == null || _selectedShippingOption == null || checkoutItems.isEmpty) {
      _checkoutError = "請完成所有必填選項：地址、配送方式和商品。";
      notifyListeners();
      return false;
    }

    _isPlacingOrder = true;
    _checkoutError = null;
    _createdOrder = null;
    notifyListeners();

    final orderData = OrderCreationData(
      userId: _currentUserId!, // 【【修改】】使用真實用戶 ID
      items: List<CartItem>.from(checkoutItems), // 使用 getter checkoutItems
      shippingAddress: _selectedAddress!,
      shippingMethodId: _selectedShippingOption!.id,
      paymentMethodId: paymentMethodId,
      subtotal: itemsSubtotal,
      shippingFee: _selectedShippingOption!.cost, // 原始運費
      discountAmount: discountAmount,
      couponCode: lastAppliedCouponCode,
      totalAmount: totalAmount,
    );

    try {
      final order = await _orderService.createOrder(orderData);
      if (order != null) {
        _createdOrder = order;
        // 訂單成功後，可以考慮清空購物車選中項（通過 CartProvider）
        // _cartProvider.clearSelectedItemsAfterOrder(); // 假設 CartProvider 有此方法
        return true;
      } else {
        _checkoutError = "訂單建立失敗，請稍後再試。 (服務返回 null)";
        return false;
      }
    } on Exception catch (e) {
      _checkoutError = "訂單建立失敗: ${e.toString().replaceFirst("Exception: ", "")}";
      return false;
    } catch (e) {
      _checkoutError = "訂單建立時發生未知錯誤。";
      print("Place order error: $e");
      return false;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }

  void resetCheckoutState({bool notify = true}) { // 【【修改】】添加可選參數
    _isLoadingOverall = false;
    _isLoadingAddresses = false;
    _isLoadingShippingOptions = false;
    _isApplyingCoupon = false;
    _isPlacingOrder = false;

    // 地址列表 _availableAddresses 通常不清空，除非用戶登出（由 _handleAuthOrCartChange 處理）
    _selectedAddress = null;
    _shippingOptions = [];
    _selectedShippingOption = null;
    // _checkoutItems 由 CartProvider 管理，這裡不需要重置
    _discountInfo = null;
    _checkoutError = null;
    _createdOrder = null;
    if (notify) {
      notifyListeners();
    }
  }

  // 【【新增】】在 Provider 銷毀時移除監聽器
  @override
  void dispose() {
    _authProvider.removeListener(_handleAuthOrCartChange);
    _cartProvider.removeListener(_handleAuthOrCartChange);
    super.dispose();
  }
}

