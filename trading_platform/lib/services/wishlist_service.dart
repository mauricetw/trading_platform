import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user/wishlist_item.dart';
import '../models/product/product.dart'; // 如果 API 返回嵌入的 Product
// 假設 ApiException 和 token 獲取邏輯與 FavoriteService 類似
// 您可以將它們提取到一個共享的 api_client.dart 或 base_service.dart 中

// 假設您的 API 異常類
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errorBody;
  ApiException(this.message, {this.statusCode, this.errorBody});
  @override
  String toString() => "ApiException: $message (Status Code: ${statusCode ?? 'N/A'})";
}

// 假設的 Base URL 和 token 獲取
const String _apiBaseUrl = "https://your-fastapi-domain.com/api"; // 替換為您的 API Base URL
Future<String?> _getUserAuthToken() async {
  // 替換為您的實際 token 獲取邏輯
  return "YOUR_JWT_TOKEN_HERE";
}

class WishlistService {
  final http.Client _httpClient;

  WishlistService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Future<Map<String, String>> _getHeaders({bool needsContentTypeJson = false}) async {
    final token = await _getUserAuthToken();
    final headers = <String, String>{};
    if (needsContentTypeJson) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// 獲取當前用戶的願望清單項目
  /// 假設後端 API 端點是 /users/me/wishlist 或 /wishlist?userId={userId}
  Future<List<WishlistItem>> getMyWishlistItems() async { // 通常 userId 會從 token 中解析，或作為路徑參數
    // final uri = Uri.parse('$_apiBaseUrl/users/me/wishlist'); // 或者適合您後端的端點
    final uri = Uri.parse('$_apiBaseUrl/wishlist'); // 假設這個端點需要認證頭來識別用戶

    try {
      final response = await _httpClient.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return responseData.map((json) => WishlistItem.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        dynamic errorBody;
        try { errorBody = jsonDecode(utf8.decode(response.bodyBytes)); } catch (_) { errorBody = utf8.decode(response.bodyBytes); }
        throw ApiException('無法獲取願望清單 (Code: ${response.statusCode})', statusCode: response.statusCode, errorBody: errorBody);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('獲取願望清單失敗: $e');
    }
  }

  /// 將商品添加到願望清單
  /// 後端可能期望 body: {'product_id': '...' }
  /// 並返回創建的 WishlistItem
  Future<WishlistItem> addItemToWishlist(String productId) async {
    // final uri = Uri.parse('$_apiBaseUrl/users/me/wishlist');
    final uri = Uri.parse('$_apiBaseUrl/wishlist'); // POST 到這個路徑
    try {
      final response = await _httpClient.post(
        uri,
        headers: await _getHeaders(needsContentTypeJson: true),
        body: jsonEncode({'product_id': productId}), // 根據您後端 API 的要求調整 body
      );

      if (response.statusCode == 201 || response.statusCode == 200) { // 201 Created or 200 OK
        return WishlistItem.fromJson(jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
      } else if (response.statusCode == 409) { // Conflict - Item already exists
        dynamic errorBody;
        try {
          errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          // 嘗試將 errorBody (假設它現在是已存在的 WishlistItem JSON) 解析為 WishlistItem
          // 如果您的後端在 409 時確實返回了 WishlistItem 的 JSON
          if (errorBody is Map<String, dynamic>) { // 確保是 Map
            print('商品已在願望清單中 (從服務端返回的 409 數據): $errorBody');
            return WishlistItem.fromJson(errorBody); // <--- 直接返回解析後的 WishlistItem
          } else {
            // 如果 409 的 body 不是預期的 WishlistItem JSON，則按原樣拋出錯誤
            throw ApiException('商品已在願望清單中，但服務端未返回項目數據。', statusCode: response.statusCode, errorBody: errorBody);
          }
        } catch (parseError) {
          // 如果解析 409 的 body 失敗，或者 body 不是 JSON
          throw ApiException('商品已在願望清單中 (無法解析服務端返回的項目數據)。 Code: ${response.statusCode})', statusCode: response.statusCode, errorBody: utf8.decode(response.bodyBytes));
        }
      } else {
        dynamic errorBody;
        try { errorBody = jsonDecode(utf8.decode(response.bodyBytes)); } catch (_) { errorBody = utf8.decode(response.bodyBytes); }
        throw ApiException('無法將商品添加到願望清單 (Code: ${response.statusCode})', statusCode: response.statusCode, errorBody: errorBody);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('添加到願望清單失敗: $e');
    }
  }

  /// 從願望清單中移除商品 (通過 WishlistItem ID)
  Future<void> removeItemFromWishlist(String wishlistItemId) async {
    // final uri = Uri.parse('$_apiBaseUrl/users/me/wishlist/$wishlistItemId');
    final uri = Uri.parse('$_apiBaseUrl/wishlist/$wishlistItemId'); // DELETE 到這個路徑

    try {
      final response = await _httpClient.delete(uri, headers: await _getHeaders());

      if (response.statusCode == 200 || response.statusCode == 204) { // 204 No Content
        return; // 成功
      } else {
        dynamic errorBody;
        try { errorBody = jsonDecode(utf8.decode(response.bodyBytes)); } catch (_) { errorBody = utf8.decode(response.bodyBytes); }
        throw ApiException('無法從願望清單移除商品 (Code: ${response.statusCode})', statusCode: response.statusCode, errorBody: errorBody);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('從願望清單移除失敗: $e');
    }
  }

  /// (可選) 從願望清單中移除商品 (通過 Product ID)
  /// 這需要後端支持 DELETE /wishlist/product/{productId} 或類似端點
  Future<void> removeItemFromWishlistByProductId(String productId) async {
    // 假設端點是 /wishlist/product/{productId}
    final uri = Uri.parse('$_apiBaseUrl/wishlist/product/$productId');
    try {
      final response = await _httpClient.delete(uri, headers: await _getHeaders());
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        dynamic errorBody;
        try { errorBody = jsonDecode(utf8.decode(response.bodyBytes)); } catch (_) { errorBody = utf8.decode(response.bodyBytes); }
        throw ApiException('無法通過產品ID從願望清單移除 (Code: ${response.statusCode})', statusCode: response.statusCode, errorBody: errorBody);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('通過產品ID從願望清單移除失敗: $e');
    }
  }
}
