// --- FILE: lib/services/api_client.dart ---
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart'; // 1. 引入我們修正後的設定檔

// API 異常類別 (保持不變)
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    return message;
  }
}

// ApiClient 專門負責底層的 HTTP 通訊
class ApiClient {
  // --- 2. 移除寫死的網址 ---
  // static const String _authority = "10.0.2.2:8000"; // <-- 已移除

  String? _token;

  void setAuthToken(String? token) {
    _token = token;
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      throw ApiException(responseBody['detail'] ?? 'API 請求失敗', response.statusCode);
    }
  }

  // --- 3. 修改所有 HTTP 方法以使用 APIConfig ---

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    // 使用 APIConfig.baseUrl 來建立完整的 URL
    final url = Uri.parse('${APIConfig.baseUrl}$path').replace(queryParameters: queryParams);
    try {
      final response = await http.get(url, headers: _getHeaders());
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('無法連線到伺服器，請檢查您的網路。');
    }
  }

  Future<dynamic> post(String path, {required Map<String, dynamic> body}) async {
    final url = Uri.parse('${APIConfig.baseUrl}$path');
    try {
      final response = await http.post(url, headers: _getHeaders(), body: jsonEncode(body));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('無法連線到伺服器，請檢查您的網路。');
    }
  }

  Future<dynamic> put(String path, {required Map<String, dynamic> body}) async {
    final url = Uri.parse('${APIConfig.baseUrl}$path');
    try {
      final response = await http.put(url, headers: _getHeaders(), body: jsonEncode(body));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('無法連線到伺服器，請檢查您的網路。');
    }
  }

  Future<dynamic> delete(String path) async {
    final url = Uri.parse('${APIConfig.baseUrl}$path');
    try {
      final response = await http.delete(url, headers: _getHeaders());
      if (response.statusCode == 204) {
        return null;
      }
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('無法連線到伺服器，請檢查您的網路。');
    }
  }
}
