// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // 後端 API 的基本 URL，需要與您的後端開發者協調
  final String baseUrl = 'https://your-api-url.com/api';  // 替換為您實際的 API URL

  // 登入方法
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // 檢查連接可用性
      final testResponse = await http.get(Uri.parse('https://www.google.com'));
      if (testResponse.statusCode != 200) {
        return {
          'success': false,
          'message': '網絡連接有問題，請檢查您的網絡',
        };
      }

      // 可以在這裡使用 debugPrint 來檢查請求細節
      debugPrint('正在發送登入請求到: $baseUrl/login');
      debugPrint('用戶名: $username, 密碼長度: ${password.length}');

      // 發送 POST 請求到登入 API 端點
      final response = await http.post(
        Uri.parse('$baseUrl/login'),  // 確認實際的登入 API 端點
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      // 記錄響應詳情，便於調試
      debugPrint('API 回應狀態碼: ${response.statusCode}');
      debugPrint('API 回應內容: ${response.body}');

      // 先檢查狀態碼
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          // 檢查回應是否為空
          if (response.body.isEmpty) {
            return {
              'success': true,
              'data': {'message': '登入成功但沒有返回數據'},
            };
          }

          // 檢查回應是否為 JSON
          if (response.body.trim().startsWith('{') || response.body.trim().startsWith('[')) {
            final responseData = jsonDecode(response.body);
            return {
              'success': true,
              'data': responseData,
            };
          } else {
            // 非 JSON 回應但狀態碼正確
            return {
              'success': true,
              'data': {'message': '登入可能成功，但返回格式不是 JSON'},
            };
          }
        } catch (e) {
          debugPrint('JSON 解析錯誤: $e');
          // 處理 JSON 解析錯誤，但仍視為成功（因為狀態碼正確）
          return {
            'success': true,
            'data': {'message': '登入可能成功，但無法解析回應'},
          };
        }
      } else {
        // 非成功狀態碼
        try {
          // 嘗試解析錯誤訊息（如果是 JSON 格式）
          if (response.body.trim().startsWith('{') || response.body.trim().startsWith('[')) {
            final errorData = jsonDecode(response.body);
            return {
              'success': false,
              'message': errorData['message'] ?? '登入失敗: 狀態碼 ${response.statusCode}',
            };
          } else {
            // 非 JSON 錯誤回應
            return {
              'success': false,
              'message': '登入失敗: 狀態碼 ${response.statusCode}',
            };
          }
        } catch (e) {
          // 無法解析錯誤訊息
          return {
            'success': false,
            'message': '登入失敗: 狀態碼 ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      // 處理網絡錯誤或其他例外
      debugPrint('網絡或其他錯誤: $e');
      return {
        'success': false,
        'message': '連接伺服器時出現問題: $e',
      };
    }
  }

  // 如果不能連接真實 API，可以使用此模擬方法
  Future<Map<String, dynamic>> mockLogin(String username, String password) async {
    // 模擬網絡延遲
    await Future.delayed(const Duration(seconds: 2));

    // 簡單的模擬驗證
    if (username == 'admin' && password == 'password') {
      return {
        'success': true,
        'data': {
          'userId': '12345',
          'username': 'admin',
          'role': 'administrator',
        },
      };
    } else if (username.isEmpty) {
      return {
        'success': false,
        'message': '使用者帳號不存在',
      };
    } else if (password.isEmpty || password != 'password') {
      return {
        'success': false,
        'message': '密碼錯誤',
      };
    } else {
      return {
        'success': false,
        'message': '登入失敗，請檢查帳號和密碼',
      };
    }
  }
}