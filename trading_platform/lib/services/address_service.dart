import 'dart:math';
import '../config/api_config.dart';
import '../models/user/address.dart';
import 'api_client.dart';
import 'interfaces/address_service_interface.dart';
import '../mock/data/mock_addresses.dart';

class AddressService implements IAddressService {
  final ApiClient _apiClient;
  AddressService([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: Random().nextInt(500) + 150));
  }

  @override
  Future<List<Address>> getMyAddresses() async {
    if (APIConfig.useMock) {
      await _simulateNetworkDelay();
      return List<Address>.from(mockAddresses); // ✅ 全是 Address
    }
    final json = await _apiClient.get('/addresses/me');
    final List<dynamic> arr = json;
    return arr.map((e) => Address.fromJson(e)).toList();
  }

  @override
  Future<List<Address>> getUserAddresses(String userId) async {
    if (APIConfig.useMock) {
      await _simulateNetworkDelay();
      return mockAddresses.where((a) => a.userId == userId).toList();
    }
    final json = await _apiClient.get('/addresses', queryParams: {'user_id': userId});
    final List<dynamic> arr = json;
    return arr.map((e) => Address.fromJson(e)).toList();
  }

  @override
  Future<Address?> getDefaultAddress(String userId) async {
    final list = await getUserAddresses(userId);
    try {
      return list.firstWhere((a) => a.isDefault == true);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Address?> addAddress(String userId, Address addressData) async {
    if (APIConfig.useMock) {
      await _simulateNetworkDelay();
      final newAddr = addressData.copyWith(
        id: 'addr_new_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
      );
      mockAddresses.add(newAddr);
      return newAddr;
    }
    final json = await _apiClient.post('/addresses', body: addressData.toJson());
    return Address.fromJson(json);
  }

  @override
  Future<Address?> updateAddress(String userId, Address addressData) async {
    if (APIConfig.useMock) {
      await _simulateNetworkDelay();
      final i = mockAddresses.indexWhere((a) => a.id == addressData.id && a.userId == userId);
      if (i != -1) {
        // 若設為預設，把其他的取消預設
        if (addressData.isDefault) {
          for (int k = 0; k < mockAddresses.length; k++) {
            if (mockAddresses[k].userId == userId && mockAddresses[k].id != addressData.id) {
              mockAddresses[k] = mockAddresses[k].copyWith(isDefault: false);
            }
          }
        }
        mockAddresses[i] = addressData.copyWith(userId: userId);
        return mockAddresses[i];
      }
      return null;
    }
    final json = await _apiClient.put('/addresses/${addressData.id}', body: addressData.toJson());
    return Address.fromJson(json);
  }

  @override
  Future<bool> deleteAddress(String userId, String addressId) async {
    if (APIConfig.useMock) {
      await _simulateNetworkDelay();
      final before = mockAddresses.length;
      mockAddresses.removeWhere((a) => a.id == addressId && a.userId == userId);
      return mockAddresses.length < before;
    }
    await _apiClient.delete('/addresses/$addressId');
    return true;
  }

  @override
  Future<bool> setDefaultAddress(String userId, String addressId) async {
    if (APIConfig.useMock) {
      await _simulateNetworkDelay();
      bool found = false;
      for (int i = 0; i < mockAddresses.length; i++) {
        if (mockAddresses[i].userId == userId) {
          final isTarget = mockAddresses[i].id == addressId;
          mockAddresses[i] = mockAddresses[i].copyWith(isDefault: isTarget);
          if (isTarget) found = true;
        }
      }
      return found;
    }
    await _apiClient.post('/addresses/$addressId/set_default', body: {});
    return true;
  }
}
