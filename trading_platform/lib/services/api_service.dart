import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:first_flutter_project/models/announcement/announcement.dart'; // 確保這個路徑正確，並且模型已定義
// 如果有 SearchResultItem 或 Product 等模型，也需要導入
// import 'package:first_flutter_project/models/search_result_item.dart';


class ApiService {
  final String baseUrl = "http://10.0.2.2:8000"; // 您現有的基礎 URL

  // --- 現有的認證相關方法 ---
  Future<Map<String, dynamic>> registerUser(String username, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage;
        if (responseData["detail"] is List) {
          errorMessage = responseData["detail"].join(", ");
        } else {
          errorMessage = responseData["detail"] ?? "註冊時發生未知錯誤";
        }
        return {"success": false, "message": errorMessage};
      }
    } catch (e) {
      print("Register user error: $e");
      return {"success": false, "message": "無法連線到伺服器，請檢查您的網路連線。"};
    }
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "login": identifier,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          "success": true,
          "data": responseData,
        };
      } else {
        Map<String, dynamic> errorData;
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
          errorData = {
            "message": "無法解析伺服器錯誤訊息 (狀態碼: ${response.statusCode})",
            "details": response.body,
          };
        }
        return {
          "success": false,
          "error": errorData["detail"] ?? errorData["message"] ?? "登入失敗，請檢查您的帳號或密碼。",
          "statusCode": response.statusCode,
        };
      }
    } catch (e) {
      print("Login error: $e");
      return {
        "success": false,
        "error": "無法連接伺服器。請檢查網路連線。",
        "exception": e.toString(),
      };
    }
  }

  Future<void> forgotPassword(String identifier) async {
    final url = Uri.parse('$baseUrl/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'login': identifier}),
      );

      if (response.statusCode == 200) {
        print('驗證信發送成功');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? '發送驗證信失敗 (狀態碼: ${response.statusCode})');
      }
    } catch (e) {
      print("Forgot password error: $e");
      throw Exception('伺服器連線失敗或請求處理出錯：$e');
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    final url = Uri.parse('$baseUrl/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "new_password": newPassword,
        }),
      );
      if (response.statusCode != 200 && response.statusCode != 204) { // 204 No Content 也可能表示成功
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? '重設密碼失敗 (狀態碼: ${response.statusCode})');
      }
      print('密碼重設成功');
    } catch (e) {
      print("Reset password error: $e");
      throw Exception('伺服器連線失敗或請求處理出錯：$e');
    }
  }

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
}