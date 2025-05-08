import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://tradingdatabase-production.up.railway.app";

  Future<Map<String, dynamic>> registerUser(String username, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');
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
      throw Exception("Failed to register");
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
