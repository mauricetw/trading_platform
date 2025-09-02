// --- FILE: lib/services/product_service.dart ---
import '../models/product/category.dart'; // 1. 引入 Category 模型
import '../models/product/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _apiClient;
  ProductService(this._apiClient);

  // --- 2. 關鍵修正：補上缺失的 getCategories 方法 ---
  /// 獲取所有商品分類
  Future<List<Category>> getCategories() async {
    // 呼叫後端的 /categories API
    final responseBody = await _apiClient.get('/categories');
    // 將回傳的 JSON 列表轉換為 Category 物件列表
    final List<dynamic> categoryListJson = responseBody;
    return categoryListJson.map((json) => Category.fromJson(json)).toList();
  }

  /// 獲取公開的商品列表，支援篩選和分頁
  Future<List<Product>> getProducts({int? categoryId, String? search, int limit = 20, int skip = 0}) async {
    final queryParams = {
      'limit': limit.toString(),
      'skip': skip.toString(),
    };
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final responseBody = await _apiClient.get('/products', queryParams: queryParams);
    final List<dynamic> productListJson = responseBody;
    return productListJson.map((json) => Product.fromJson(json)).toList();
  }

  /// 根據 ID 獲取單一商品詳情
  Future<Product> getProductById(int productId) async {
    final responseBody = await _apiClient.get('/products/$productId');
    return Product.fromJson(responseBody);
  }

  /// 獲取當前登入賣家自己的商品列表
  Future<List<Product>> getMyProducts() async {
    final responseBody = await _apiClient.get('/seller/products');
    final List<dynamic> productListJson = responseBody;
    return productListJson.map((json) => Product.fromJson(json)).toList();
  }

  /// 上架一件新商品
  Future<Product> createProduct(Map<String, dynamic> productData) async {
    final responseBody = await _apiClient.post('/seller/products', body: productData);
    return Product.fromJson(responseBody);
  }

  /// 更新一件已存在的商品
  Future<Product> updateProduct(int productId, Map<String, dynamic> productData) async {
    final responseBody = await _apiClient.put('/seller/products/$productId', body: productData);
    return Product.fromJson(responseBody);
  }

  /// 刪除一件商品
  Future<void> deleteProduct(int productId) async {
    await _apiClient.delete('/seller/products/$productId');
  }
}
