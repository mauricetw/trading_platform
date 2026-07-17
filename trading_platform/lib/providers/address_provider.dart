// --- FILE: lib/providers/address_provider.dart ---
import 'package:flutter/foundation.dart';
import '../models/user/address.dart';
import '../services/address_service.dart';
import 'auth_provider.dart'; // 依賴 AuthProvider 來檢查登入狀態

class AddressProvider with ChangeNotifier {
  final AddressService _addressService;
  AuthProvider? _authProvider;

  List<Address> _addresses = [];
  bool _isLoading = false;
  String? _error;

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AddressProvider(this._addressService, this._authProvider) {
    if (_authProvider?.isLoggedIn == true) {
      fetchAddresses();
    }
  }

  // 當 AuthProvider 登入或登出時，更新地址
  void update(AuthProvider newAuthProvider) {
    if (newAuthProvider.isLoggedIn != _authProvider?.isLoggedIn) {
      _authProvider = newAuthProvider;
      if (newAuthProvider.isLoggedIn) {
        fetchAddresses();
      } else {
        _addresses = [];
        notifyListeners();
      }
    }
  }

  Future<void> fetchAddresses() async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _addresses = await _addressService.getMyAddresses();
    } catch (e) {
      _error = "無法載入地址: $e";
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(Map<String, dynamic> addressData) async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;
    // 這裡可以加入 _isLoading 狀態，但為了簡潔先省略
    try {
      final newAddress = await _addressService.addAddress(addressData);
      _addresses.add(newAddress); // 在列表頂端加入新地址
      notifyListeners();
    } catch (e) {
      debugPrint("新增地址失敗: $e");
      rethrow; // 讓 UI 層知道失敗了
    }
  }

  Future<void> updateAddress(int addressId, Map<String, dynamic> addressData) async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;
    try {
      final updatedAddress = await _addressService.updateAddress(addressId, addressData);
      // 尋找並取代列表中的舊地址
      final index = _addresses.indexWhere((a) => a.id == addressId);
      if (index != -1) {
        _addresses[index] = updatedAddress;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("更新地址失敗: $e");
      rethrow;
    }
  }

  Future<void> deleteAddress(int addressId) async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;
    try {
      await _addressService.deleteAddress(addressId);
      // 從列表中移除
      _addresses.removeWhere((a) => a.id == addressId);
      notifyListeners();
    } catch (e) {
      debugPrint("刪除地址失敗: $e");
      rethrow;
    }
  }
}