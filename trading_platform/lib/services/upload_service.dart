// --- FILE: lib/services/upload_service.dart ---
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // 用於 XFile 類型

import '../config/api_config.dart';
import 'api_client.dart'; // 用於 ApiException 和獲取 token

class UploadService {
  final ApiClient _apiClient;

  // UploadService 依賴 ApiClient 來獲取 API 的基本路徑和認證 Token
  UploadService(this._apiClient);

  /// 上傳單張圖片到後端伺服器
  ///
  /// [imageFile]: 從 image_picker 獲取的圖片檔案。
  /// 返回值: 成功上傳後，由後端提供的公開圖片 URL。
  Future<String> uploadImage(XFile imageFile) async {
    // 1. 組合出完整的 API URL
    final url = Uri.parse('${APIConfig.baseUrl}/uploads/image');

    // 2. 建立一個 multipart 請求，這是上傳檔案的標準格式
    final request = http.MultipartRequest('POST', url);

    // 3. 從 ApiClient 獲取認證 token，並加入到請求的 header 中
    //    注意：這需要我們在 ApiClient 中提供一個獲取 token 的方式
    if (_apiClient.token != null) {
      request.headers['Authorization'] = 'Bearer ${_apiClient.token}';
    }

    // 4. 將圖片檔案附加到請求中
    //    'file' 這個 key 必須與後端 FastAPI 端點中 `UploadFile = File(...)` 的參數名一致
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ),
    );

    try {
      // 5. 發送請求並等待回應
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 6. 處理後端的回應
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        // 後端應回傳 {"image_url": "..."} 格式的 JSON
        final imageUrl = responseBody['image_url'];
        if (imageUrl == null) {
          throw ApiException('後端未回傳圖片 URL', response.statusCode);
        }
        return imageUrl;
      } else {
        // 如果上傳失敗，解析錯誤訊息並拋出例外
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        throw ApiException(responseBody['detail'] ?? '圖片上傳失敗', response.statusCode);
      }
    } catch (e) {
      // 處理網路錯誤或其他未預期的問題
      if (e is ApiException) rethrow; // 如果是已知的 API 錯誤，直接拋出
      throw ApiException('無法上傳圖片，請檢查您的網路連線。');
    }
  }
}
