// --- FILE: lib/services/product_service.dart ---
import '../models/product/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _apiClient;
  ProductService(this._apiClient);

  /// 獲取公開的商品列表，支援篩選和分頁
  Future<List<Product>> getProducts({int? categoryId, String? search, int limit = 20, int skip = 0}) async {
    final queryParams = {
      'limit': limit.toString(),
      'skip': skip.toString(),
    };
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    // 這個路徑是正確的，用於公開瀏覽
    final responseBody = await _apiClient.get('/products', queryParams: queryParams);
    final List<dynamic> productListJson = responseBody;
    return productListJson.map((json) => Product.fromJson(json)).toList();
  }

  /// 根據 ID 獲取單一商品詳情
  Future<Product> getProductById(int productId) async {
    // 這個路徑是正確的，用於公開瀏覽
    final responseBody = await _apiClient.get('/products/$productId');
    return Product.fromJson(responseBody);
  }

  /// 獲取當前登入賣家自己的商品列表
  Future<List<Product>> getMyProducts() async {
    // --- 這個路徑是正確的，用於賣家管理 ---
    final responseBody = await _apiClient.get('/seller/products');
    final List<dynamic> productListJson = responseBody;
    return productListJson.map((json) => Product.fromJson(json)).toList();
  }

  /// 上架一件新商品
  Future<Product> createProduct(Map<String, dynamic> productData) async {
    // --- 關鍵修正：API 路徑改為 /seller/products ---
    final responseBody = await _apiClient.post('/seller/products', body: productData);
    return Product.fromJson(responseBody);
  }

  /// 更新一件已存在的商品
  Future<Product> updateProduct(int productId, Map<String, dynamic> productData) async {
    // --- 關鍵修正：API 路徑改為 /seller/products/{id} ---
    final responseBody = await _apiClient.put('/seller/products/$productId', body: productData);
    return Product.fromJson(responseBody);
  }

  /// 刪除一件商品
  Future<void> deleteProduct(int productId) async {
    // --- 關鍵修正：API 路徑改為 /seller/products/{id} ---
    await _apiClient.delete('/seller/products/$productId');
  }
}
