// --- FILE: lib/services/upload_service.dart ---
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../config/api_config.dart';
import 'api_client.dart';

class UploadService {
  final ApiClient _apiClient;

  UploadService(this._apiClient);

  /// 上傳單張圖片到後端伺服器
  Future<String> uploadImage(XFile imageFile) async {
    final url = Uri.parse('${APIConfig.baseUrl}/uploads/image');
    final request = http.MultipartRequest('POST', url);

    // --- 錯誤已修正：現在可以透過公開的 getter 'token' 來存取 ---
    if (_apiClient.token != null) {
      request.headers['Authorization'] = 'Bearer ${_apiClient.token}';
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // 這個 key 必須與後端 API 的參數名 'file' 一致
        imageFile.path,
      ),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        final imageUrl = responseBody['image_url'];
        if (imageUrl == null) {
          throw ApiException('後端未回傳圖片 URL', response.statusCode);
        }
        return imageUrl;
      } else {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        throw ApiException(responseBody['detail'] ?? '圖片上傳失敗', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('無法上傳圖片，請檢查您的網路連線。');
    }
  }
}
