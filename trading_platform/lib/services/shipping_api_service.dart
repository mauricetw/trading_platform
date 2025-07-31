import 'dart:convert';
import 'dart:math'; // For random ID generation
// import 'package:http/http.dart' as http; // 可以暫時註釋掉，如果只用模擬數據
import '../models/user/shipping_option.dart'; // 確保路徑正確

class ShippingApiService {
  // --- 模擬數據開關 ---
  static const bool _useMockData = true; // <--- 設置為 true 來使用模擬數據

  // --- 模擬12數據存儲 ---
  // 使用 List<ShippingOption> 來模擬後端數據庫
  // 為了讓新增、更新、刪除在演示期間"持久化"（直到應用重啟），我們把它設為靜態或實例變量
  // 這裡使用實例變量，每次創建 ShippingApiService 時會重置。如果需要跨實例持久，可以設為 static。
  List<ShippingOption> _mockShippingOptionsDb = [];
  int _nextMockId = 1; // 用於生成唯一的模擬 ID

  final String _baseUrl = 'YOUR_ACTUAL_API_BASE_URL'; // 你的真實 API 地址

  // 構造函數中可以初始化一些模擬數據
  ShippingApiService() {
    if (_useMockData) {
      _initializeMockData();
    }
  }

  void _initializeMockData() {
    _mockShippingOptionsDb = [
      ShippingOption(
        id: _generateMockId(),
        name: '模擬-7-11 超商取貨 (C2C)',
        cost: 60.0,
        description: '限重5公斤，尺寸限制45x30x30公分。支援本島所有7-11門市。',
        isEnabled: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ShippingOption(
        id: _generateMockId(),
        name: '模擬-黑貓宅配',
        cost: 120.0,
        description: '台灣本島常溫宅配，今日寄明日到。',
        isEnabled: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      ShippingOption(
        id: _generateMockId(),
        name: '模擬-郵局掛號',
        cost: 80.0,
        description: '約2-3個工作天送達。',
        isEnabled: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  String _generateMockId() {
    // 簡單的 ID 生成器，用於模擬
    return "mock_id_${_nextMockId++}";
  }

  // --- API 方法 ---

  Future<List<ShippingOption>> getShippingOptions(String userId) async {
    if (_useMockData) {
      print("API_MOCK: Getting shipping options for userId: $userId");
      await Future.delayed(const Duration(seconds: 1)); // 模擬網絡延遲
      // 返回模擬數據庫的副本，以防外部修改
      return List<ShippingOption>.from(_mockShippingOptionsDb);
    } else {
      // --- 真實 API 調用邏輯 (保持不變) ---
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/users/$userId/shipping-options'),
      // );
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      //   return data.map((item) => ShippingOption.fromJson(item)).toList();
      // } else {
      //   print('Failed to load shipping options: ${response.statusCode} ${response.body}');
      //   throw Exception('Failed to load shipping options');
      // }
      print("API_REAL: Call to getShippingOptions - NOT IMPLEMENTED (using mock data)");
      throw Exception('Real API for getShippingOptions not implemented in this mock setup');
    }
  }

  Future<ShippingOption> addShippingOption(ShippingOption option, /* String userId */) async {
    // userId 參數在模擬時可能不需要，除非你的模擬邏輯依賴它
    if (_useMockData) {
      print("API_MOCK: Adding shipping option: ${option.name}");
      await Future.delayed(const Duration(milliseconds: 500)); // 模擬網絡延遲

      // 創建一個新的 ShippingOption，賦予它一個模擬 ID 和時間戳
      final newOption = option.copyWith(
        id: _generateMockId(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _mockShippingOptionsDb.add(newOption);
      return newOption;
    } else {
      // --- 真實 API 調用邏輯 (保持不變) ---
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/users/$userId/shipping-options'), // 假設 userId 用於 URL
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(option.toJson()), // toJson 應該處理好 id 為空的情況
      // );
      // if (response.statusCode == 201) {
      //   return ShippingOption.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      // } else {
      //   print('Failed to add shipping option: ${response.statusCode} ${response.body}');
      //   throw Exception('Failed to add shipping option');
      // }
      print("API_REAL: Call to addShippingOption - NOT IMPLEMENTED (using mock data)");
      throw Exception('Real API for addShippingOption not implemented in this mock setup');
    }
  }

  Future<ShippingOption> updateShippingOption(ShippingOption option) async {
    if (_useMockData) {
      print("API_MOCK: Updating shipping option: ${option.id} - ${option.name}");
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _mockShippingOptionsDb.indexWhere((o) => o.id == option.id);
      if (index != -1) {
        final updatedOption = option.copyWith(updatedAt: DateTime.now());
        _mockShippingOptionsDb[index] = updatedOption;
        return updatedOption;
      } else {
        print("API_MOCK_ERROR: Option with id ${option.id} not found for update.");
        throw Exception('Mock Error: Option not found for update');
      }
    } else {
      // --- 真實 API 調用邏輯 (保持不變) ---
      // final response = await http.put(
      //   Uri.parse('$_baseUrl/shipping-options/${option.id}'), // 假設更新 URL 結構
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(option.toJson()),
      // );
      // if (response.statusCode == 200) {
      //   return ShippingOption.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      // } else {
      //   print('Failed to update shipping option: ${response.statusCode} ${response.body}');
      //   throw Exception('Failed to update shipping option');
      // }
      print("API_REAL: Call to updateShippingOption - NOT IMPLEMENTED (using mock data)");
      throw Exception('Real API for updateShippingOption not implemented in this mock setup');
    }
  }

  Future<void> deleteShippingOption(String optionId) async {
    if (_useMockData) {
      print("API_MOCK: Deleting shipping option: $optionId");
      await Future.delayed(const Duration(milliseconds: 500));
      _mockShippingOptionsDb.removeWhere((o) => o.id == optionId);
      return; // 成功
    } else {
      // --- 真實 API 調用邏輯 (保持不變) ---
      // final response = await http.delete(
      //   Uri.parse('$_baseUrl/shipping-options/$optionId'),
      // );
      // if (response.statusCode == 200 || response.statusCode == 204) { // 204 No Content
      //   return;
      // } else {
      //   print('Failed to delete shipping option: ${response.statusCode} ${response.body}');
      //   throw Exception('Failed to delete shipping option');
      // }
      print("API_REAL: Call to deleteShippingOption - NOT IMPLEMENTED (using mock data)");
      throw Exception('Real API for deleteShippingOption not implemented in this mock setup');
    }
  }
}
