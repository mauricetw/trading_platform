import 'dart:math';
import '../models/user/address.dart';
import '../models/user/user.dart';
import 'interfaces/address_service_interface.dart';

class AddressService implements IAddressService {
  final List<Address> _mockAddresses = [
    Address(
        id: 'addr1',
        userId: 'mock_user_id',
        recipientName: '張三',
        phoneNumber: '0912345678',
        country: '台灣',
        province: '台北市',
        city: '大安區',
        district: '', // Some addresses might not have district
        streetAddress1: '復興南路一段390號',
        postalCode: '106',
        isDefault: false),
    Address(
        id: 'addr2',
        userId: 'mock_user_id',
        recipientName: '李四',
        phoneNumber: '0987654321',
        country: '台灣',
        province: '新北市',
        city: '板橋區',
        district: '',
        streetAddress1: '文化路一段100號',
        postalCode: '220',
        isDefault: true),
    Address(
        id: 'addr3',
        userId: 'another_user_id', // For testing different users
        recipientName: '王五',
        phoneNumber: '0922222222',
        country: '台灣',
        province: '高雄市',
        city: '苓雅區',
        streetAddress1: '三多四路21號',
        postalCode: '802',
        isDefault: true),
  ];

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: Random().nextInt(800) + 200));
  }

  @override
  Future<List<Address>> getUserAddresses(String userId) async {
    await _simulateNetworkDelay();
    print('[AddressService] Mock: Getting addresses for user: $userId');
    return _mockAddresses.where((addr) => addr.userId == userId).toList();
  }

  @override
  Future<Address?> getDefaultAddress(String userId) async {
    await _simulateNetworkDelay();
    try {
      return _mockAddresses.firstWhere(
              (addr) => addr.userId == userId && addr.isDefault == true);
    } catch (e) {
      return null; // No default address found
    }
  }

  @override
  Future<Address?> addAddress(String userId, Address addressData) async {
    await _simulateNetworkDelay();
    final newAddress = addressData.copyWith(
      id: 'addr_new_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId, // Ensure userId is set
    );
    _mockAddresses.add(newAddress);
    print('[AddressService] Mock: Added address: ${newAddress.id} for user $userId');
    return newAddress;
  }

  @override
  Future<Address?> updateAddress(String userId, Address addressData) async {
    await _simulateNetworkDelay();
    final index = _mockAddresses
        .indexWhere((a) => a.id == addressData.id && a.userId == userId);
    if (index != -1) {
      // If updating the default status, ensure other addresses for this user are not default
      if (addressData.isDefault) {
        for (int i = 0; i < _mockAddresses.length; i++) {
          if (_mockAddresses[i].userId == userId && _mockAddresses[i].id != addressData.id) {
            _mockAddresses[i] = _mockAddresses[i].copyWith(isDefault: false);
          }
        }
      }
      _mockAddresses[index] = addressData.copyWith(userId: userId); // Ensure userId is maintained
      print('[AddressService] Mock: Updated address: ${addressData.id}');
      return _mockAddresses[index];
    }
    print('[AddressService] Mock: Update failed, address not found: ${addressData.id}');
    return null;
  }

  @override
  Future<bool> deleteAddress(String userId, String addressId) async {
    await _simulateNetworkDelay();
    final initialLength = _mockAddresses.length;
    _mockAddresses.removeWhere((a) => a.id == addressId && a.userId == userId);
    final success = _mockAddresses.length < initialLength;
    if (success) {
      print('[AddressService] Mock: Deleted address: $addressId');
    } else {
      print('[AddressService] Mock: Delete failed, address not found or wrong user: $addressId');
    }
    return success;
  }

  @override
  Future<bool> setDefaultAddress(String userId, String addressId) async {
    await _simulateNetworkDelay();
    int targetIndex = -1;
    for(int i=0; i < _mockAddresses.length; i++){
      if(_mockAddresses[i].userId == userId){
        bool isTarget = _mockAddresses[i].id == addressId;
        _mockAddresses[i] = _mockAddresses[i].copyWith(isDefault: isTarget);
        if(isTarget) targetIndex = i;
      }
    }
    if (targetIndex != -1) {
      print('[AddressService] Mock: Set address $addressId as default for user $userId.');
      return true;
    }
    print('[AddressService] Mock: Failed to set $addressId as default (not found or wrong user).');
    return false;
  }
}
