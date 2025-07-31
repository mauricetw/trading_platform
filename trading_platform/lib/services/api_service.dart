import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // 後端 API 的基本 URL - 修改為你的後端地址
  // final String baseUrl = 'http://localhost:8000';  // 電腦運行
  final String baseUrl = 'http://10.0.2.2:8080';  // Android 模擬器用這個
  // final String baseUrl = 'http://你的電腦IP:8000';  // 真機用這個，需要替換實際IP

  // 登入方法
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      debugPrint('正在發送登入請求到: $baseUrl/auth/login');
      debugPrint('用戶名: $identifier, 密碼長度: ${password.length}');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'login': identifier,     // 後端期望的是 'login' 欄位
          'password': password,
        }),
      );

      debugPrint('API 回應狀態碼: ${response.statusCode}');
      debugPrint('API 回應內容: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          if (response.body.isEmpty) {
            return {
              'success': true,
              'data': {'message': '登入成功但沒有返回數據'},
            };
          }
          final responseData = jsonDecode(response.body);
          return {
            'success': true,
            'data': responseData,
          };
        } catch (e) {
          debugPrint('JSON 解析錯誤: $e');
          return {
            'success': false,
            'error': 'JSON 解析錯誤: $e',
          };
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'error': errorData['detail'] ?? '登入失敗: 狀態碼 ${response.statusCode}',
          };
        } catch (e) {
          return {
            'success': false,
            'error': '登入失敗: 狀態碼 ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      debugPrint('網絡或其他錯誤: $e');
      return {
        'success': false,
        'error': '連接伺服器時出現問題: $e',
      };
    }
  }

  // 註冊方法
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['detail'] ?? '註冊失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '註冊時發生錯誤: $e',
      };
    }
  }

  // 註冊使用者方法（更詳細版本）
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    String? phone,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
        }),
      );

      debugPrint('註冊使用者 API 回應狀態碼: ${response.statusCode}');
      debugPrint('註冊使用者 API 回應內容: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['detail'] ?? '註冊失敗',
        };
      }
    } catch (e) {
      debugPrint('註冊使用者錯誤: $e');
      return {
        'success': false,
        'error': '註冊時發生錯誤: $e',
      };
    }
  }

  // 忘記密碼方法
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      debugPrint('忘記密碼 API 回應狀態碼: ${response.statusCode}');
      debugPrint('忘記密碼 API 回應內容: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['detail'] ?? '忘記密碼請求失敗',
        };
      }
    } catch (e) {
      debugPrint('忘記密碼錯誤: $e');
      return {
        'success': false,
        'error': '忘記密碼請求時發生錯誤: $e',
      };
    }
  }

  // 驗證碼方法
  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-code'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['detail'] ?? '驗證碼驗證失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '驗證碼驗證時發生錯誤: $e',
      };
    }
  }

  // 重設密碼方法
  Future<Map<String, dynamic>> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'code': code,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['detail'] ?? '重設密碼失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '重設密碼時發生錯誤: $e',
      };
    }
  }

  // 搜尋商品方法（支援篩選參數）
  Future<List<dynamic>> searchItems(
      String query, {
        String? sortBy,
        List<String>? categories,
        int? minPrice,
        int? maxPrice,
        String? brand,
      }) async {
    try {
      // 建構查詢參數
      Map<String, String> queryParams = {};

      if (query.isNotEmpty) {
        queryParams['q'] = query;
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }

      if (categories != null && categories.isNotEmpty) {
        queryParams['categories'] = categories.join(',');
      }

      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }

      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }

      if (brand != null && brand.isNotEmpty) {
        queryParams['brand'] = brand;
      }

      // 建構 URI
      Uri uri = Uri.parse('$baseUrl/products/search').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('搜尋商品 API 回應狀態碼: ${response.statusCode}');
      debugPrint('搜尋商品 API 回應內容: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);

        // 根據實際 API 回應結構調整
        if (responseData is List) {
          return responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          return responseData['data'] ?? [];
        } else if (responseData is Map && responseData.containsKey('results')) {
          return responseData['results'] ?? [];
        } else {
          return [responseData];
        }
      } else {
        debugPrint('搜尋商品失敗: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('搜尋商品錯誤: $e');
      return [];
    }
  }

  // 取得商品列表方法
  Future<Map<String, dynamic>> getProducts({int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['detail'] ?? '取得商品列表失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '取得商品列表時發生錯誤: $e',
      };
    }
  }

  // 取得使用者資訊方法
  Future<Map<String, dynamic>> getUserInfo(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['detail'] ?? '取得使用者資訊失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '取得使用者資訊時發生錯誤: $e',
      };
    }
  }
}