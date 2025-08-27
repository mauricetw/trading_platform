import 'api_client.dart';

class SearchService {
  final ApiClient _apiClient;

  SearchService(this._apiClient);

  /// 搜索項目
  /// [query] 是搜索關鍵詞
  /// [categories] (可選) 用於按分類篩選
  /// [sortBy] (可選) 用於排序
  /// 返回 List<dynamic>，因為搜索結果的類型可能多樣
  Future<List<dynamic>> searchItems(
      String query, {
        List<String>? categories,
        String? sortBy,
      }) async {
    // 構建查詢參數
    Map<String, String> queryParams = {'q': query};

    if (categories != null && categories.isNotEmpty) {
      queryParams['categories'] = categories.join(',');
    }

    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy;
    }

    try {
      final responseBody = await _apiClient.get('/search', queryParams: queryParams);

      if (responseBody is List) {
        return responseBody;
      } else {
        throw Exception('搜索失敗：回應格式不正確');
      }
    } catch (e) {
      throw Exception('搜索時發生錯誤：$e');
    }
  }
}