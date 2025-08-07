import 'package:flutter/material.dart';
import '../models/user/address.dart';
import '../models/user/cart_item.dart';
import '../models/user/shipping_option.dart';
import '../models/order/order.dart'; // 包含 OrderModel
import '../models/order/order_creation_data.dart';
import '../models/order/discount_info.dart';
import '../services/interfaces/order_service_interface.dart';
import '../services/interfaces/address_service_interface.dart';

class CheckoutProvider with ChangeNotifier {
  final IOrderService _orderService;
  final IAddressService _addressService;

  CheckoutProvider(this._orderService, this._addressService);

  // --- 狀態變量 ---
  bool _isLoadingOverall = false; // 通用加載狀態，可以用於初始加載等
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

  List<CartItem> _checkoutItems = [];
  List<CartItem> get checkoutItems => List.unmodifiable(_checkoutItems);

  DiscountInfo? _discountInfo;
  DiscountInfo? get discountInfo => _discountInfo;

  String? _checkoutError;
  String? get checkoutError => _checkoutError;

  OrderModel? _createdOrder;
  OrderModel? get createdOrder => _createdOrder;


  // --- Getters ---
  double get itemsSubtotal { // 改名以匹配 CheckoutScreen
    if (_checkoutItems.isEmpty) return 0.0;
    return _checkoutItems.fold(
        0.0, (sum, item) => sum + (item.productPrice * item.quantity));
  }

  double get shippingCost {
    if (_discountInfo?.isFreeShipping == true && _selectedShippingOption != null) {
      return 0.0; // 如果是免運費優惠券，運費為0
    }
    return _selectedShippingOption?.cost ?? 0.0;
  }

  // discountAmount 現在從 _discountInfo 獲取
  double get discountAmount => _discountInfo?.discountAmount ?? 0.0;

  // lastAppliedCouponCode 現在從 _discountInfo 獲取
  String? get lastAppliedCouponCode => _discountInfo?.appliedCouponCode;


  double get totalAmount {
    double currentSubtotal = itemsSubtotal;
    double currentShippingCost = shippingCost; // 使用 getter
    double currentDiscount = discountAmount; // 使用 getter

    double calculatedTotal = currentSubtotal + currentShippingCost - currentDiscount;
    return calculatedTotal > 0 ? calculatedTotal : 0.0;
  }

  // --- Methods ---

  Future<void> loadInitialData() async {
    _isLoadingOverall = true;
    notifyListeners();
    // 這裡可以決定初始加載哪些數據，例如地址
    // 購物車項目通常由 CartScreen 或類似頁面傳遞過來
    await fetchAddresses(); // 示例：初始加載地址
    _isLoadingOverall = false;
    notifyListeners();
  }

  // 用於從外部（例如 CartScreen 導航過來時）設置購物車項目
  void setCheckoutItems(List<CartItem> items) {
    _checkoutItems = List.from(items);
    _discountInfo = null; // 清除舊的優惠券信息，因為商品變化了
    _checkoutError = null;
    if (_selectedAddress != null) {
      fetchShippingMethods();
    } else {
      notifyListeners();
    }
  }

  Future<void> fetchAddresses() async {
    _isLoadingAddresses = true;
    _checkoutError = null;
    notifyListeners();
    try {
      // TODO: 替換 "mock_user_id" 為真實的用戶 ID
      _availableAddresses = await _addressService.getUserAddresses("mock_user_id");
      if (_availableAddresses.isNotEmpty) {
        Address? defaultAddr = await _addressService.getDefaultAddress("mock_user_id");
        if (defaultAddr != null && _availableAddresses.any((addr) => addr.id == defaultAddr.id)) {
          // 不直接調用 selectAddress 以避免重複的 notifyListeners
          _selectedAddress = defaultAddr;
          _shippingOptions = [];
          _selectedShippingOption = null;
          _discountInfo = null; // 地址變化，優惠券可能失效
          if (_checkoutItems.isNotEmpty) {
            await fetchShippingMethods(); // 確保配送方式被獲取
          }
        } else {
          // 或者選擇第一個，或者讓用戶手動選
        }
      }
    } catch (e) {
      _checkoutError = "加載地址失敗: $e";
      print(_checkoutError);
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
    _discountInfo = null;
    _checkoutError = null; // 清除可能因舊地址產生的配送錯誤
    notifyListeners(); // 先更新UI顯示已選地址

    if (_checkoutItems.isNotEmpty) {
      fetchShippingMethods();
    }
  }

  Future<void> fetchShippingMethods() async {
    if (_selectedAddress == null || _checkoutItems.isEmpty) {
      _shippingOptions = [];
      _selectedShippingOption = null;
      notifyListeners();
      return;
    }
    _isLoadingShippingOptions = true;
    _checkoutError = null; // 清除之前的錯誤
    notifyListeners();
    try {
      _shippingOptions = await _orderService.getAvailableShippingMethods(
          _selectedAddress!, _checkoutItems);
      if (_shippingOptions.isNotEmpty) {
        // 可以考慮默認選中第一個可用的，如果之前沒有選中任何配送方式
        if(_selectedShippingOption == null || !_shippingOptions.any((opt) => opt.id == _selectedShippingOption!.id)){
          // selectShippingOption(_shippingOptions.firstWhere((opt) => opt.isEnabled, orElse: () => _shippingOptions.first));
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
    // 運費變化可能影響優惠券的有效性（例如“滿X免運費”），如果優惠券已應用，可能需要重新驗證
    // 這裡為了簡化，如果優惠券是 FREESHIP，且選了新的運費，我們可能需要重新評估
    if (_discountInfo != null && _discountInfo!.appliedCouponCode == 'FREESHIP') {
      // 如果 OrderService 的 applyCoupon 夠智能，可以重新調用它
      // 或者，如果只是簡單的免運費，則 totalAmount 會自動處理
    }
    _checkoutError = null; // 清除可能因舊配送方式產生的錯誤
    notifyListeners();
  }

  // 【重要】修改 applyCoupon 方法簽名和內部邏輯
  Future<void> applyCoupon(String code, List<CartItem> items) async { // 假設 items 會從 CheckoutScreen 傳入
    if (code.isEmpty) {
      _discountInfo = DiscountInfo(
          appliedCouponCode: null,
          discountAmount: 0,
          message: "請輸入優惠券代碼。",
          isFreeShipping: false);
      notifyListeners();
      return;
    }
    if (items.isEmpty) {
      _discountInfo = DiscountInfo(
          appliedCouponCode: code, // 即使購物車為空，也記錄嘗試的代碼
          discountAmount: 0,
          message: "購物車是空的，無法套用優惠券。",
          isFreeShipping: false);
      notifyListeners();
      return;
    }

    _isApplyingCoupon = true;
    _checkoutError = null; // 清除之前的錯誤
    _discountInfo = null; // 清除舊的優惠信息
    notifyListeners();

    try {
      // 計算當前小計和運費傳給 OrderService
      double currentSubtotal = items.fold(0.0, (sum, item) => sum + (item.productPrice * item.quantity));
      double currentShippingCost = _selectedShippingOption?.cost ?? 0.0;

      final di = await _orderService.applyCoupon(code, items, currentSubtotal, currentShippingCost);
      _discountInfo = di; // 保存完整的 DiscountInfo

      // 基於 DiscountInfo 的 isFreeShipping 來調整運費顯示（在 shippingCost getter 中處理）

    } on Exception catch (e) { // 捕獲 OrderService 拋出的特定異常
      _discountInfo = DiscountInfo(
          appliedCouponCode: code, // 記錄嘗試的代碼
          discountAmount: 0,
          message: e.toString().replaceFirst("Exception: ", ""),
          isFreeShipping: false);
    } catch (e) {
      _discountInfo = DiscountInfo(
          appliedCouponCode: code, // 記錄嘗試的代碼
          discountAmount: 0,
          message: "套用優惠券時發生錯誤。",
          isFreeShipping: false);
      print("Apply coupon error: $e");
    } finally {
      _isApplyingCoupon = false;
      notifyListeners();
    }
  }

  Future<bool> placeOrder({String paymentMethodId = "default_payment"}) async { // CheckoutScreen 會傳 paymentMethodId
    if (_selectedAddress == null ||
        _selectedShippingOption == null ||
        _checkoutItems.isEmpty) {
      _checkoutError = "請完成所有必填選項：地址、配送方式和商品。";
      notifyListeners();
      return false;
    }

    _isPlacingOrder = true;
    _checkoutError = null;
    _createdOrder = null; // 清除之前的訂單
    notifyListeners();

    final orderData = OrderCreationData(
      userId: "mock_user_id", // TODO: 替換為真實用戶 ID
      items: List<CartItem>.from(_checkoutItems),
      shippingAddress: _selectedAddress!,
      shippingMethodId: _selectedShippingOption!.id,
      paymentMethodId: paymentMethodId,
      subtotal: itemsSubtotal,
      shippingFee: _selectedShippingOption!.cost, // 原始運費
      discountAmount: discountAmount,
      couponCode: lastAppliedCouponCode,
      totalAmount: totalAmount,
      // customerNotes: "一些顧客備註", // 如果需要
    );

    try {
      final order = await _orderService.createOrder(orderData);
      if (order != null) {
        _createdOrder = order; // 保存創建的訂單
        // resetCheckoutState(); // 應該在訂單成功後，由 UI 層決定是否以及何時重置
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

  void resetCheckoutState() {
    _isLoadingOverall = false;
    _isLoadingAddresses = false;
    _isLoadingShippingOptions = false;
    _isApplyingCoupon = false;
    _isPlacingOrder = false;

    // 通常不重置地址列表 _availableAddresses，除非用戶登出或有特定邏輯
    _selectedAddress = null;
    _shippingOptions = [];
    _selectedShippingOption = null;
    _checkoutItems = [];
    _discountInfo = null;
    _checkoutError = null;
    _createdOrder = null;
    notifyListeners();
  }
}
