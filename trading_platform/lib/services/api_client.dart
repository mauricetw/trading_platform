// --- FILE: lib/services/api_client.dart ---
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart'; // 1. 引入 APIConfig

// API 異常類別
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

// ApiClient 專門負責底層的 HTTP 通訊
class ApiClient {
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
      throw ApiException(
        responseBody['detail'] ?? 'API 請求失敗',
        response.statusCode,
      );
    }
  }

  // --- GET ---
  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final url = Uri.parse('${APIConfig.baseUrl}$path')
        .replace(queryParameters: queryParams);
    try {
      final response = await http.get(url, headers: _getHeaders());
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('無法連線到伺服器，請檢查您的網路。');
    }
  }

  // --- POST ---
  Future<dynamic> post(String path, {required Map<String, dynamic> body}) async {
    final url = Uri.parse('${APIConfig.baseUrl}$path');
    try {
      final response =
      await http.post(url, headers: _getHeaders(), body: jsonEncode(body));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('無法連線到伺服器，請檢查您的網路。');
    }
  }

  // --- PUT ---
  Future<dynamic> put(String path, {required Map<String, dynamic> body}) async {
    final url = Uri.parse('${APIConfig.baseUrl}$path');
    try {
      final response =
      await http.put(url, headers: _getHeaders(), body: jsonEncode(body));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('無法連線到伺服器，請檢查您的網路。');
    }
  }

  // --- DELETE ---
  Future<dynamic> delete(String path) async {
    final url = Uri.parse('${APIConfig.baseUrl}$path');
    try {
      final response = await http.delete(url, headers: _getHeaders());
      if (response.statusCode == 204) return null;
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('無法連線到伺服器，請檢查您的網路。');
    }
  }

  // --- PATCH (新增的) ---
  Future<dynamic> patch(String path, {required Map<String, dynamic> body}) async {
    final url = Uri.parse('${APIConfig.baseUrl}$path');
    try {
      final response =
      await http.patch(url, headers: _getHeaders(), body: jsonEncode(body));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('無法連線到伺服器，請檢查您的網路。');
    }
  }
}
