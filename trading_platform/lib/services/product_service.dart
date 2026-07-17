// --- FILE: lib/services/product_service.dart ---
import 'package:flutter/foundation.dart' hide Category;
import '../models/product/category.dart';
import '../models/product/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _apiClient;
  ProductService(this._apiClient);

  /// 獲取所有商品分類
  Future<List<Category>> getCategories() async {
    try {
      debugPrint('ProductService: 開始獲取商品分類...');

      final responseBody = await _apiClient.get('/products/categories');
      debugPrint('ProductService: 分類 API 響應: $responseBody');

      final List<dynamic> categoryListJson = responseBody;
      final categories = categoryListJson.map((json) => Category.fromJson(json)).toList();

      debugPrint('ProductService: 成功解析 ${categories.length} 個分類');
      return categories;
    } catch (e, stackTrace) {
      debugPrint('ProductService: 獲取分類失敗: $e');
      debugPrint('ProductService: 堆疊追蹤: $stackTrace');
      rethrow;
    }
  }

  /// 獲取公開的商品列表，支援篩選和分頁
  Future<List<Product>> getProducts({int? categoryId, String? search, int limit = 20, int skip = 0}) async {
    try {
      debugPrint('ProductService: 開始獲取商品列表...');
      debugPrint('ProductService: 參數 - categoryId: $categoryId, search: $search, limit: $limit, skip: $skip');

      final queryParams = <String, String>{
        'limit': limit.toString(),
        'skip': skip.toString(),
      };
      if (categoryId != null) queryParams['category_id'] = categoryId.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      debugPrint('ProductService: 查詢參數: $queryParams');

      final responseBody = await _apiClient.get('/products', queryParams: queryParams);
      debugPrint('ProductService: 商品列表 API 響應類型: ${responseBody.runtimeType}');

      if (responseBody is! List) {
        debugPrint('ProductService: 警告 - 預期 List 但收到: ${responseBody.runtimeType}');
        debugPrint('ProductService: 響應內容: $responseBody');
        throw FormatException('API 返回格式錯誤：預期 List，實際收到 ${responseBody.runtimeType}');
      }

      final List<dynamic> productListJson = responseBody;
      debugPrint('ProductService: 開始解析 ${productListJson.length} 個商品...');

      final products = <Product>[];
      for (int i = 0; i < productListJson.length; i++) {
        try {
          final productJson = productListJson[i];
          debugPrint('ProductService: 解析第 ${i + 1} 個商品...');
          final product = Product.fromJson(productJson);
          products.add(product);
          debugPrint('ProductService: 成功解析商品: ${product.name} (ID: ${product.id})');
        } catch (e) {
          debugPrint('ProductService: 解析第 ${i + 1} 個商品失敗: $e');
          debugPrint('ProductService: 問題商品 JSON: ${productListJson[i]}');
          // 繼續處理其他商品，不讓一個商品的錯誤影響整個列表
        }
      }

      debugPrint('ProductService: 成功解析 ${products.length}/${productListJson.length} 個商品');
      return products;
    } catch (e, stackTrace) {
      debugPrint('ProductService: 獲取商品列表失敗: $e');
      debugPrint('ProductService: 堆疊追蹤: $stackTrace');
      rethrow;
    }
  }

  /// 根據 ID 獲取單一商品詳情
  Future<Product> getProductById(int productId) async {
    try {
      debugPrint('===============================');
      debugPrint('ProductService: 開始獲取商品詳情');
      debugPrint('ProductService: 商品 ID: $productId');
      debugPrint('===============================');

      final responseBody = await _apiClient.get('/products/$productId');

      debugPrint('ProductService: API 響應類型: ${responseBody.runtimeType}');
      debugPrint('ProductService: API 響應內容: $responseBody');

      if (responseBody == null) {
        throw Exception('API 返回空響應');
      }

      if (responseBody is! Map<String, dynamic>) {
        debugPrint('ProductService: 錯誤 - 預期 Map<String, dynamic> 但收到: ${responseBody.runtimeType}');
        throw FormatException('API 返回格式錯誤：預期 Object，實際收到 ${responseBody.runtimeType}');
      }

      debugPrint('ProductService: 開始解析商品 JSON...');
      final product = Product.fromJson(responseBody);

      debugPrint('ProductService: 成功解析商品詳情:');
      debugPrint('- 商品名稱: ${product.name}');
      debugPrint('- 商品 ID: ${product.id}');
      debugPrint('- 賣家 ID: ${product.sellerId}');
      debugPrint('- 賣家資訊: ${product.seller?.username ?? '無'}');
      debugPrint('- 狀態: ${product.status}');
      debugPrint('- 價格: ${product.price}');
      debugPrint('===============================');

      return product;
    } catch (e, stackTrace) {
      debugPrint('===============================');
      debugPrint('ProductService: 獲取商品詳情失敗');
      debugPrint('ProductService: 商品 ID: $productId');
      debugPrint('ProductService: 錯誤類型: ${e.runtimeType}');
      debugPrint('ProductService: 錯誤訊息: $e');
      debugPrint('ProductService: 堆疊追蹤: $stackTrace');
      debugPrint('===============================');
      rethrow;
    }
  }

  /// 獲取當前登入賣家自己的商品列表
  Future<List<Product>> getMyProducts() async {
    try {
      debugPrint('ProductService: 開始獲取賣家商品列表...');

      final responseBody = await _apiClient.get('/seller/products');
      debugPrint('ProductService: 賣家商品 API 響應類型: ${responseBody.runtimeType}');

      if (responseBody is! List) {
        debugPrint('ProductService: 警告 - 預期 List 但收到: ${responseBody.runtimeType}');
        throw FormatException('API 返回格式錯誤：預期 List，實際收到 ${responseBody.runtimeType}');
      }

      final List<dynamic> productListJson = responseBody;
      debugPrint('ProductService: 開始解析 ${productListJson.length} 個賣家商品...');

      final products = productListJson.map<Product>((json) {
        try {
          return Product.fromJson(json);
        } catch (e) {
          debugPrint('ProductService: 解析賣家商品失敗: $e');
          debugPrint('ProductService: 問題商品 JSON: $json');
          rethrow;
        }
      }).toList();

      debugPrint('ProductService: 成功解析 ${products.length} 個賣家商品');
      return products;
    } catch (e, stackTrace) {
      debugPrint('ProductService: 獲取賣家商品失敗: $e');
      debugPrint('ProductService: 堆疊追蹤: $stackTrace');
      rethrow;
    }
  }

  /// 上架一件新商品
  Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      debugPrint('ProductService: 開始創建新商品...');
      debugPrint('ProductService: 商品資料: $productData');

      final responseBody = await _apiClient.post('/seller/products', body: productData);
      debugPrint('ProductService: 創建商品 API 響應: $responseBody');

      final product = Product.fromJson(responseBody);
      debugPrint('ProductService: 成功創建商品: ${product.name} (ID: ${product.id})');

      return product;
    } catch (e, stackTrace) {
      debugPrint('ProductService: 創建商品失敗: $e');
      debugPrint('ProductService: 堆疊追蹤: $stackTrace');
      rethrow;
    }
  }

  /// 更新一件已存在的商品
  Future<Product> updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      debugPrint('ProductService: 開始更新商品...');
      debugPrint('ProductService: 商品 ID: $productId');
      debugPrint('ProductService: 更新資料: $productData');

      final responseBody = await _apiClient.put('/seller/products/$productId', body: productData);
      debugPrint('ProductService: 更新商品 API 響應: $responseBody');

      final product = Product.fromJson(responseBody);
      debugPrint('ProductService: 成功更新商品: ${product.name} (ID: ${product.id})');

      return product;
    } catch (e, stackTrace) {
      debugPrint('ProductService: 更新商品失敗: $e');
      debugPrint('ProductService: 堆疊追蹤: $stackTrace');
      rethrow;
    }
  }

  /// 刪除一件商品
  Future<void> deleteProduct(int productId) async {
    try {
      debugPrint('ProductService: 開始刪除商品...');
      debugPrint('ProductService: 商品 ID: $productId');

      await _apiClient.delete('/seller/products/$productId');
      debugPrint('ProductService: 成功刪除商品 ID: $productId');
    } catch (e, stackTrace) {
      debugPrint('ProductService: 刪除商品失敗: $e');
      debugPrint('ProductService: 堆疊追蹤: $stackTrace');
      rethrow;
    }
  }
}