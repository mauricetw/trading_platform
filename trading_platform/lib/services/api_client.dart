// --- FILE: lib/services/api_client.dart ---
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

// API 異常類別
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseBody;

  ApiException(this.message, [this.statusCode, this.responseBody]);

  @override
  String toString() {
    return message;
  }
}

class ApiClient {
  String? _token;

  String? get token => _token;

  void setAuthToken(String? token) {
    _token = token;
    debugPrint('ApiClient: 設置 Auth Token: ${token != null ? '已設置' : '已清除'}');
  }

  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response, String requestInfo) {
    try {
      debugPrint('===============================');
      debugPrint('ApiClient: HTTP 響應詳情');
      debugPrint('請求: $requestInfo');
      debugPrint('狀態碼: ${response.statusCode}');
      debugPrint('響應頭: ${response.headers}');
      debugPrint('響應體長度: ${response.body.length} 字元');
      debugPrint('響應體前 500 字元: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}');
      debugPrint('===============================');

      if (response.body.isEmpty) {
        debugPrint('ApiClient: 響應體為空');
        if (response.statusCode >= 200 && response.statusCode < 300) {
          debugPrint('ApiClient: 成功響應，返回 null');
          return null;
        } else {
          debugPrint('ApiClient: 錯誤響應且響應體為空');
          throw ApiException('伺服器回應為空', response.statusCode);
        }
      }

      dynamic responseBody;
      try {
        responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint('ApiClient: JSON 解碼成功');
        debugPrint('ApiClient: 響應體類型: ${responseBody.runtimeType}');

        if (responseBody is Map<String, dynamic>) {
          debugPrint('ApiClient: 響應體鍵: ${responseBody.keys.toList()}');
        } else if (responseBody is List) {
          debugPrint('ApiClient: 響應體列表長度: ${responseBody.length}');
          if (responseBody.isNotEmpty) {
            debugPrint('ApiClient: 第一個元素類型: ${responseBody.first.runtimeType}');
            if (responseBody.first is Map<String, dynamic>) {
              debugPrint('ApiClient: 第一個元素鍵: ${(responseBody.first as Map<String, dynamic>).keys.toList()}');
            }
          }
        }
      } catch (e) {
        debugPrint('ApiClient: JSON 解碼失敗: $e');
        debugPrint('ApiClient: 原始響應: ${response.body}');
        throw ApiException('伺服器回應格式錯誤：無法解析 JSON - $e', response.statusCode, response.body);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('ApiClient: 請求成功，返回解析後的資料');
        return responseBody;
      } else {
        debugPrint('ApiClient: 請求失敗，狀態碼: ${response.statusCode}');
        final errorMessage = responseBody is Map<String, dynamic>
            ? (responseBody['detail'] ?? responseBody['message'] ?? 'API 請求失敗')
            : 'API 請求失敗';
        throw ApiException(errorMessage.toString(), response.statusCode, responseBody);
      }
    } catch (e, stackTrace) {
      debugPrint('ApiClient: _handleResponse 處理過程中發生錯誤: $e');
      debugPrint('ApiClient: 堆疊追蹤: $stackTrace');
      rethrow;
    }
  }

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final url = Uri.parse('${APIConfig.baseUrl}$path').replace(queryParameters: queryParams);
    final requestInfo = 'GET $url';

    try {
      debugPrint('===============================');
      debugPrint('ApiClient: 發送 GET 請求');
      debugPrint('URL: $url');
      debugPrint('查詢參數: $queryParams');
      debugPrint('請求頭: ${_getHeaders()}');
      debugPrint('===============================');

      final response = await http.get(url, headers: _getHeaders()).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ApiException('請求超時，請檢查網路連線');
        },
      );

      return _handleResponse(response, requestInfo);
    } on SocketException catch (e) {
      debugPrint('ApiClient: 網路連線錯誤: $e');
      throw ApiException('無法連線到伺服器，請檢查您的網路：$e');
    } on FormatException catch (e) {
      debugPrint('ApiClient: 格式錯誤: $e');
      throw ApiException('資料格式錯誤：$e');
    } catch (e, stackTrace) {
      debugPrint('ApiClient: GET 請求發生未知錯誤: $e');
      debugPrint('ApiClient: 堆疊追蹤: $stackTrace');

      if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException('請求失敗：$e');
      }
    }
  }

  Future<dynamic> post(String path, {required Map<String, dynamic> body}) async {
    final url = Uri.parse('${APIConfig.baseUrl}$path');
    final requestInfo = 'POST $url';

    try {
      debugPrint('===============================');
      debugPrint('ApiClient: 發送 POST 請求');
      debugPrint('URL: $url');
      debugPrint('請求頭: ${_getHeaders()}');
      debugPrint('請求體: $body');
      debugPrint('===============================');

      final response = await http.post(
          url,
          headers: _getHeaders(),
          body: jsonEncode(body)
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ApiException('請求超時，請檢查網路連線');
        },
      );

      return _handleResponse(response, requestInfo);
    } on SocketException catch (e) {
      debugPrint('ApiClient: 網路連線錯誤: $e');
      throw ApiException('無法連線到伺服器，請檢查您的網路：$e');
    } on FormatException catch (e) {
      debugPrint('ApiClient: 格式錯誤: $e');
      throw ApiException('資料格式錯誤：$e');
    } catch (e, stackTrace) {
      debugPrint('ApiClient: POST 請求發生未知錯誤: $e');
      debugPrint('ApiClient: 堆疊追蹤: $stackTrace');

      if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException('請求失敗：$e');
      }
    }
  }

  Future<dynamic> put(String path, {required Map<String, dynamic> body}) async {
    final url = Uri.parse('${APIConfig.baseUrl}$path');
    final requestInfo = 'PUT $url';

    try {
      debugPrint('===============================');
      debugPrint('ApiClient: 發送 PUT 請求');
      debugPrint('URL: $url');
      debugPrint('請求頭: ${_getHeaders()}');
      debugPrint('請求體: $body');
      debugPrint('===============================');

      final response = await http.put(
          url,
          headers: _getHeaders(),
          body: jsonEncode(body)
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ApiException('請求超時，請檢查網路連線');
        },
      );

      return _handleResponse(response, requestInfo);
    } on SocketException catch (e) {
      debugPrint('ApiClient: 網路連線錯誤: $e');
      throw ApiException('無法連線到伺服器，請檢查您的網路：$e');
    } on FormatException catch (e) {
      debugPrint('ApiClient: 格式錯誤: $e');
      throw ApiException('資料格式錯誤：$e');
    } catch (e, stackTrace) {
      debugPrint('ApiClient: PUT 請求發生未知錯誤: $e');
      debugPrint('ApiClient: 堆疊追蹤: $stackTrace');

      if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException('請求失敗：$e');
      }
    }
  }

  Future<dynamic> delete(String path) async {
    final url = Uri.parse('${APIConfig.baseUrl}$path');
    final requestInfo = 'DELETE $url';

    try {
      debugPrint('===============================');
      debugPrint('ApiClient: 發送 DELETE 請求');
      debugPrint('URL: $url');
      debugPrint('請求頭: ${_getHeaders()}');
      debugPrint('===============================');

      final response = await http.delete(url, headers: _getHeaders()).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ApiException('請求超時，請檢查網路連線');
        },
      );

      if (response.statusCode == 204) {
        debugPrint('ApiClient: DELETE 請求成功 (204 No Content)');
        return null;
      }

      return _handleResponse(response, requestInfo);
    } on SocketException catch (e) {
      debugPrint('ApiClient: 網路連線錯誤: $e');
      throw ApiException('無法連線到伺服器，請檢查您的網路：$e');
    } on FormatException catch (e) {
      debugPrint('ApiClient: 格式錯誤: $e');
      throw ApiException('資料格式錯誤：$e');
    } catch (e, stackTrace) {
      debugPrint('ApiClient: DELETE 請求發生未知錯誤: $e');
      debugPrint('ApiClient: 堆疊追蹤: $stackTrace');

      if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException('請求失敗：$e');
      }
    }
  }

  // --- PATCH 方法 ---
  /// 發送 PATCH 請求，通常用於部分更新資源。
  Future<dynamic> patch(String path, {required Map<String, dynamic> body}) async {
    final url = Uri.parse('${APIConfig.baseUrl}$path');
    final requestInfo = 'PATCH $url';

    try {
      debugPrint('===============================');
      debugPrint('ApiClient: 發送 PATCH 請求');
      debugPrint('URL: $url');
      debugPrint('請求頭: ${_getHeaders()}');
      debugPrint('請求體: $body');
      debugPrint('===============================');

      final response = await http.patch(
          url,
          headers: _getHeaders(),
          body: jsonEncode(body)
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ApiException('請求超時，請檢查網路連線');
        },
      );

      return _handleResponse(response, requestInfo);
    } on SocketException catch (e) {
      debugPrint('ApiClient: 網路連線錯誤: $e');
      throw ApiException('無法連線到伺服器，請檢查您的網路：$e');
    } catch (e) {
      debugPrint('ApiClient: PATCH 請求發生未知錯誤: $e');
      if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException('請求失敗：$e');
      }
    }
  }

}