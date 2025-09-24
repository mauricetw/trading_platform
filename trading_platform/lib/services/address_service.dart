// --- FILE: lib/services/address_service.dart ---
import '../models/user/address.dart';
import 'api_client.dart';
// 移除 IAddressService 引用，因為我們直接實作
// import 'interfaces/address_service_interface.dart';

class AddressService {
  final ApiClient _apiClient;
  AddressService(this._apiClient);

  /// 獲取當前登入使用者的所有地址
  Future<List<Address>> getMyAddresses() async {
    final responseBody = await _apiClient.get('/addresses');
    final List<dynamic> addressListJson = responseBody;
    return addressListJson.map((json) => Address.fromJson(json)).toList();
  }

// TODO: 未來可在此處擴充新增、更新、刪除地址的 API 呼叫
// 例如：
/*
  Future<Address> addAddress(Map<String, dynamic> addressData) async {
    final responseBody = await _apiClient.post('/addresses', body: addressData);
    return Address.fromJson(responseBody);
  }

  Future<Address> updateAddress(int addressId, Map<String, dynamic> addressData) async {
    final responseBody = await _apiClient.put('/addresses/$addressId', body: addressData);
    return Address.fromJson(responseBody);
  }

  Future<void> deleteAddress(int addressId) async {
    await _apiClient.delete('/addresses/$addressId');
  }
  */
}
