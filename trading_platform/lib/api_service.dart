import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://tradingdatabase-production.up.railway.app";

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
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "identifier": identifier, // 可以是 email 或 username
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login failed");
    }
  }

  Future<void> forgotPassword(String username) async {
    final url = Uri.parse('$baseUrl/forgot-password');
    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username}),
    );
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
