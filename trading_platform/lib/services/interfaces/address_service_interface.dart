import '../../models/user/address.dart'; // 使用您正確的 Address 類名

abstract class IAddressService {
  Future<List<Address>> getUserAddresses(String userId);
  Future<Address?> addAddress(String userId, Address address);
  Future<Address?> updateAddress(String userId, Address address);
  Future<bool> deleteAddress(String userId, String addressId);
  Future<Address?> getDefaultAddress(String userId);
}