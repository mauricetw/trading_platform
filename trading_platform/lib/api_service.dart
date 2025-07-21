import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:first_flutter_project/models/announcement/announcement.dart'; // 確保這個路徑正確，並且模型已定義
// 如果有 SearchResultItem 或 Product 等模型，也需要導入
// import 'package:first_flutter_project/models/search_result_item.dart';
import 'package:first_flutter_project/models/product/product.dart';
import 'package:first_flutter_project/models/user/user.dart';

import 'models/auth/auth_response.dart';

// --- 最佳實踐：定義一個自訂的 API 異常類別 ---
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    return "API 錯誤: $message (狀態碼: ${statusCode ?? 'N/A'})";
  }
}

class ApiService {
  // --- 修正：基礎 URL 應包含 API 前綴 ---
  // 為了方便管理，我們只定義主機部分
  static const String _authority = "10.0.2.2:8000";
  // API 的 Token，登入後會被設定
  String? _token;

  // 提供一個方法來更新 token
  void setAuthToken(String? token) {
    _token = token;
  }

  // 私有的輔助函式，用於建立帶有認證標頭的 Headers
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // --- 現有的認證相關方法 ---
  // --- 註冊 API (已更新) ---
  Future<AuthResponse> registerUser(String username, String email, String password) async {
    // 修正：加上 /auth 前綴
    final url = Uri.http(_authority, '/auth/register');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201) { // 後端註冊成功是 201 Created
        // 修正：解析新的 AuthResponse 結構
        return AuthResponse.fromJson(responseBody);
      } else {
        throw ApiException(responseBody['detail'] ?? '註冊失敗', response.statusCode);
      }
    } on SocketException {
      throw ApiException('無法連線到伺服器，請檢查您的網路。');
    } catch (e) {
      // 重新拋出，讓呼叫者處理
      rethrow;
    }
  }

  // --- 登入 API (已更新) ---
  Future<AuthResponse> login(String identifier, String password) async {
    // 修正：加上 /auth 前綴
    final url = Uri.http(_authority, '/auth/login');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          "login": identifier,
          "password": password,
        }),
      );

      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // 修正：解析新的 AuthResponse 結構
        return AuthResponse.fromJson(responseBody);
      } else {
        throw ApiException(responseBody['detail'] ?? '登入失敗', response.statusCode);
      }
    } on SocketException {
      throw ApiException('無法連線到伺服器，請檢查您的網路。');
    } catch (e) {
      rethrow;
    }
  }

  // --- 忘記密碼 API (已更新) ---
  Future<String> forgotPassword(String identifier) async {
    // 修正：加上 /auth 前綴
    final url = Uri.http(_authority, '/auth/forgot-password');
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode({'login': identifier}),
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      return responseBody['message'];
    } else {
      throw ApiException(responseBody['detail'] ?? '請求失敗', response.statusCode);
    }
  }

  // --- 驗證碼 API (已更新) ---
  Future<String> verifyCode(String login, String code) async {
    // 修正：加上 /auth 前綴
    final url = Uri.http(_authority, '/auth/verify-code');
    final response = await http.post(
      url,
      headers: _getHeaders(),
      // 修正：請求內容從 user_id 改為 login
      body: jsonEncode({'login': login, 'code': code}),
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      // 修正：回傳 reset_token
      return responseBody['reset_token'];
    } else {
      throw ApiException(responseBody['detail'] ?? '驗證失敗', response.statusCode);
    }
  }

  // --- 重設密碼 API (已更新) ---
  Future<String> resetPassword(String token, String newPassword) async {
    // 修正：加上 /auth 前綴
    final url = Uri.http(_authority, '/auth/reset-password');
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode({
        "token": token,
        "new_password": newPassword,
      }),
    );

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      return responseBody['message'];
    } else {
      throw ApiException(responseBody['detail'] ?? '重設密碼失敗', response.statusCode);
    }
  }

  // --- 獲取使用者公開資料 (無變化，但路徑更正) ---
  Future<User> getUserProfile(int userId) async {
    // 修正：使用 /users 前綴
    final url = Uri.http(_authority, '/users/$userId');
    final response = await http.get(url, headers: _getHeaders());
    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      // 後端回傳的是 {"user": {...}}，所以要從 'user' key 取出資料
      return User.fromJson(responseBody['user']);
    } else {
      throw ApiException(responseBody['detail'] ?? '無法載入使用者資料', response.statusCode);
    }
  }

  // --- 新增：獲取當前登入者資料的 API ---
  Future<User> getMyProfile() async {
    // 這個 API 需要授權
    if (_token == null) throw ApiException('未登入，無法取得個人資料');

    final url = Uri.http(_authority, '/users/me');
    final response = await http.get(url, headers: _getHeaders());
    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      // /users/me 直接回傳使用者物件，沒有 'user' key
      return User.fromJson(responseBody);
    } else {
      throw ApiException(responseBody['detail'] ?? '無法載入個人資料', response.statusCode);
    }
  }

  // --- 新增：更新當前登入者資料的 API ---
  Future<User> updateUserProfile({
    required String username,
    required String bio,
    required String schoolName,
    required String avatarUrl,
  }) async {
    if (_token == null) throw ApiException('未登入，無法更新個人資料');

    final url = Uri.http(_authority, '/users/me'); // 後端 API 路徑
    try {
      final response = await http.put( // 使用 PUT 方法
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'bio': bio,
          'school_name': schoolName, // 注意：後端接收 snake_case
          'avatar_url': avatarUrl,
        }),
      );

      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return User.fromJson(responseBody);
      } else {
        throw ApiException(responseBody['detail'] ?? '更新失敗', response.statusCode);
      }
    } on SocketException {
      throw ApiException('無法連線到伺服器，請檢查您的網路。');
    } catch (e) {
      rethrow;
    }
  }


// --- 商品頁面相關方法 ---

  // --- 新增：獲取商品列表 API ---
  Future<List<Product>> getProducts({int? categoryId, String? search, int limit = 20, int skip = 0}) async {
    // 建立查詢參數
    final Map<String, String> queryParameters = {
      'limit': limit.toString(),
      'skip': skip.toString(),
    };
    if (categoryId != null) {
      queryParameters['category_id'] = categoryId.toString();
    }
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    final url = Uri.http(_authority, '/products', queryParameters);
    try {
      final response = await http.get(url, headers: _getHeaders());
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // 後端回傳的是一個 JSON 陣列
        final List<dynamic> productListJson = responseBody;
        // 將陣列中的每個 JSON 物件轉換成 Product 物件
        return productListJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException(responseBody['detail'] ?? '獲取商品失敗', response.statusCode);
      }
    } on SocketException {
      throw ApiException('無法連線到伺服器，請檢查您的網路。');
    } catch (e) {
      rethrow;
    }
  }

  // --- 新增：根據 ID 獲取單一商品詳情 ---
  Future<Product> getProductById(int productId) async {
    final url = Uri.http(_authority, '/products/$productId');
    try {
      final response = await http.get(url, headers: _getHeaders());
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // 後端直接回傳單一商品物件的 JSON
        return Product.fromJson(responseBody);
      } else {
        throw ApiException(responseBody['detail'] ?? '獲取商品詳情失敗', response.statusCode);
      }
    } on SocketException {
      throw ApiException('無法連線到伺服器，請檢查您的網路。');
    } catch (e) {
      rethrow;
    }
  }
/*
  Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),  // 確保 `toJson()` 有對應欄位
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('上架商品失敗：${response.statusCode}');
    }
  }
*/
/*
  // --- 新增的公告相關方法 ---

  /// 獲取所有公告列表
  Future<List<Announcement>> getAnnouncements() async {
    // 假設公告的端點是 /announcements (相對於 baseUrl)
    final url = Uri.parse('$baseUrl/announcements');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          // 'Authorization': 'Bearer YOUR_AUTH_TOKEN', // 如果需要認證
        },
      );

      if (response.statusCode == 200) {
        // 使用 utf8.decode 處理中文字符
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        List<Announcement> announcements = body
            .map((dynamic item) => Announcement.fromJson(item as Map<String, dynamic>))
            .toList();
        return announcements;
      } else {
        print('Failed to load announcements: ${response.statusCode} ${response.body}');
        // 可以根據狀態碼返回更具體的錯誤或拋出特定異常
        throw Exception('獲取公告列表失敗 (狀態碼: ${response.statusCode})');
      }
    } catch (e) {
      print("Get announcements error: $e");
      throw Exception('無法獲取公告：$e');
    }
  }

  /// 根據ID獲取單個公告的詳情
  Future<Announcement?> getAnnouncementById(String id) async {
    final url = Uri.parse('$baseUrl/announcements/$id'); // 假設端點結構
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          // 'Authorization': 'Bearer YOUR_AUTH_TOKEN', // 如果需要認證
        },
      );

      if (response.statusCode == 200) {
        return Announcement.fromJson(jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        print('Announcement with id $id not found.');
        return null; // 或者拋出 NotFoundException
      } else {
        print('Failed to load announcement $id: ${response.statusCode} ${response.body}');
        throw Exception('獲取公告詳情失敗 (狀態碼: ${response.statusCode})');
      }
    } catch (e) {
      print("Get announcement by ID error: $e");
      throw Exception('無法獲取公告詳情：$e');
    }
  }

  /// 標記公告為已讀 ( userId 通常是當前登入用戶的ID )
  Future<bool> markAnnouncementAsRead(String announcementId, String userId) async {
    // 實際的 API 端點和請求體取決於您的後端設計
    final url = Uri.parse('$baseUrl/announcements/$announcementId/read-status'); // 假設端點
    try {
      final response = await http.post( // 或者 PUT，根據您的 API 設計
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          // 'Authorization': 'Bearer YOUR_AUTH_TOKEN', // 通常需要認證
        },
        body: jsonEncode({'userId': userId, 'read': true}), // 假設 API 需要用戶ID和已讀狀態
      );
      // 200 OK 或 204 No Content 都可能表示成功
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Announcement $announcementId marked as read for user $userId');
        return true;
      } else {
        print('Failed to mark announcement $announcementId as read: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print("Mark announcement as read error: $e");
      return false; // 或者拋出異常
    }
  }

  // --- 新增的搜索相關方法 ---

  /// 搜索項目
  /// [query] 是搜索關鍵詞
  /// [categories] (可選) 用於按分類篩選
  /// [sortBy] (可選) 用於排序
  /// 返回 List<dynamic>，因為搜索結果的類型可能多樣，需要在調用處進行模型轉換
  Future<List<dynamic>> searchItems(String query, {List<String>? categories, String? sortBy}) async {
    // 構建查詢參數
    Map<String, String> queryParams = {
      'q': query, // 'q' 通常用作搜索關鍵詞的參數名
    };
    if (categories != null && categories.isNotEmpty) {
      queryParams['categories'] = categories.join(','); // 示例：categories=cat1,cat2
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy; // 示例：sortBy=relevance
    }

    // 假設搜索端點是 /search (相對於 baseUrl)
    final uri = Uri.parse('$baseUrl/search').replace(queryParameters: queryParams);
    print("Searching with URI: $uri"); // 打印請求的URI，方便調試

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          // 'Authorization': 'Bearer YOUR_AUTH_TOKEN', // 如果搜索需要認證
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        // 這裡的 body 結構取決於您的 API 如何返回搜索結果
        // 您可能需要根據結果的類型將其映射到不同的模型
        // 例如：
        // return body.map((itemJson) {
        //   if (itemJson['type'] == 'product') {
        //     return Product.fromJson(itemJson as Map<String, dynamic>);
        //   } else if (itemJson['type'] == 'article') {
        //     return Article.fromJson(itemJson as Map<String, dynamic>);
        //   }
        //   return SearchResultItem.fromJson(itemJson as Map<String, dynamic>); // 通用模型
        // }).toList();
        return body; // 暫時直接返回動態列表
      } else {
        print('Failed to search items: ${response.statusCode} ${response.body}');
        throw Exception('搜索失敗 (狀態碼: ${response.statusCode})');
      }
    } catch (e) {
      print("Search items error: $e");
      throw Exception('搜索時發生錯誤：$e');
    }
  }

 */
}
