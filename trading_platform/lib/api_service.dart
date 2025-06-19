import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000";

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

        /// 如果 `detail` 是列表，則將其轉換為字串
        if (responseData["detail"] is List) {
          errorMessage = responseData["detail"].join(", ");
        } else {
          errorMessage = responseData["detail"];
        }

        return {"success": false, "message": errorMessage};
        // 返回後端的錯誤訊息
        //final responseData = jsonDecode(response.body);
        //return {"success": false, "message": errorResponse["detail"] ?? "註冊失敗"};
      }
    } catch (e) {
      return {"success": false, "message": "無法連線到伺服器"};
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
        // 成功登入
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          "success": true,
          "data": responseData,
        };
      } else {
        // 處理 HTTP 狀態碼
        Map<String, dynamic> errorData;
        try {
          errorData = jsonDecode(response.body);
        } catch (e) {
          errorData = {
            "message": "無法解析錯誤訊息",
            "details": response.body,
          };
        }

        return {
          "success": false,
          "error": errorData["message"] ?? "未知錯誤",
          "statusCode": response.statusCode,
        };
      }
    } catch (e) {
      // 捕獲網路錯誤或其他異常
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
        throw Exception(errorData['detail'] ?? '發送驗證信失敗');
      }
    } catch (e) {
      throw Exception('伺服器連線失敗：$e');
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    final url = Uri.parse('$baseUrl/reset-password');
    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "token": token,
        "new_password": newPassword,
      }),
    );
  }
}