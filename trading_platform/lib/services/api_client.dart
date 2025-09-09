// --- FILE: lib/services/api_client.dart ---
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

// API 異常類別
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    return message;
  }
}

class ApiClient {
  String? _token;

  // --- 關鍵修正：新增一個公開的 getter 來讓其他 service 讀取 token ---
  String? get token => _token;

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

  // --- 強化 _handleResponse 以解析 FastAPI 的驗證錯誤 ---
  dynamic _handleResponse(http.Response response) {
    // 檢查 body 是否為空，避免解碼錯誤
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null; // 對於 204 No Content 這類的回應，回傳 null
      } else {
        throw ApiException('伺服器回應為空', response.statusCode);
      }
    }

    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      // --- 錯誤處理邏輯 ---
      String errorMessage = 'API 請求失敗';
      final detail = responseBody['detail'];

      if (detail is String) {
        // 如果 'detail' 是字串，直接使用
        errorMessage = detail;
      } else if (detail is List && detail.isNotEmpty) {
        // 如果 'detail' 是列表 (FastAPI 驗證錯誤)，提取第一條錯誤訊息
        final firstError = detail[0] as Map<String, dynamic>;
        final field = (firstError['loc'] as List).last; // 獲取欄位名
        final msg = firstError['msg']; // 獲取錯誤訊息
        errorMessage = '欄位 "$field": $msg';
      }

      throw ApiException(errorMessage, response.statusCode);
    }
  }

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
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
      // 修正：delete 成功時 statusCode 為 204，body 為空
      if (response.statusCode == 204) {
        return null;
      }
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('無法連線到伺服器，請檢查您的網路。');
    }
  }
}
