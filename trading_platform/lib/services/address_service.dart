// --- FILE: lib/services/address_service.dart ---
import 'package:flutter/foundation.dart'; // 為了 debugPrint
import '../models/user/address.dart';
import 'api_client.dart';

class AddressService {
  final ApiClient _apiClient;
  AddressService(this._apiClient);

  /// 獲取當前登入使用者的所有地址
  Future<List<Address>> getMyAddresses() async {
    debugPrint("[AddressService] 正在獲取所有地址...");
    final responseBody = await _apiClient.get('/addresses');
    final List<dynamic> addressListJson = responseBody;
    return addressListJson.map((json) => Address.fromJson(json)).toList();
  }

  // --- [新功能] 新增一筆地址 ---
  /// (addressData 應符合後端 AddressCreate schema)
  Future<Address> addAddress(Map<String, dynamic> addressData) async {
    debugPrint("[AddressService] 正在新增地址...");
    final responseBody = await _apiClient.post('/addresses', body: addressData);
    return Address.fromJson(responseBody);
  }

  // --- [新功能] 更新一筆地址 ---
  /// (addressData 應符合後端 AddressUpdate schema)
  Future<Address> updateAddress(int addressId, Map<String, dynamic> addressData) async {
    debugPrint("[AddressService] 正在更新地址 #$addressId...");
    final responseBody = await _apiClient.put('/addresses/$addressId', body: addressData);
    return Address.fromJson(responseBody);
  }

  // --- [新功能] 刪除一筆地址 ---
  Future<void> deleteAddress(int addressId) async {
    debugPrint("[AddressService] 正在刪除地址 #$addressId...");
    // 後端會回傳 204 No Content，所以這裡不用 return
    await _apiClient.delete('/addresses/$addressId');
  }
}