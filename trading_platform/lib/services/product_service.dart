import '../models/product/product.dart';
import '../config/api_config.dart';
import 'package:first_flutter_project/mock/mock.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _apiClient;
  ProductService(this._apiClient);

  Future<List<Product>> getProducts({int? categoryId, String? search}) async {
    if (APIConfig.useMock) {
      // 👉 如果開了 mock，直接回傳假資料
      return buildMockProductsForUser("mock_user", count: 6);
    }

    // 👉 否則打 API
    final responseBody = await _apiClient.get(APIConfig.products);
    final List<dynamic> productListJson = responseBody;
    return productListJson.map((json) => Product.fromJson(json)).toList();
  }

  /// 根據 ID 取得商品詳情
  Future<Product> getProductById(int productId) async {
    if (APIConfig.useMock) {
      return buildMockProductsForUser("mock_user", count: 10).firstWhere((p) => p.id == productId);
    }

    final responseBody = await _apiClient.get('/products/$productId');
    return Product.fromJson(responseBody);
  }

  /// 上架新商品
  Future<Product> createProduct(Map<String, dynamic> productData) async {
    if (APIConfig.useMock) {
      return Product.fromJson(productData); // 直接回傳假商品
    }
    final responseBody = await _apiClient.post('/products', body: productData);
    return Product.fromJson(responseBody);
  }

  /// 更新商品
  Future<Product> updateProduct(int productId, Map<String, dynamic> productData) async {
    if (APIConfig.useMock) {
      return Product.fromJson({...productData, 'id': productId});
    }
    final responseBody = await _apiClient.put('/products/$productId', body: productData);
    return Product.fromJson(responseBody);
  }

  /// 刪除商品
  Future<void> deleteProduct(int productId) async {
    if (APIConfig.useMock) {
      return; // 模擬成功
    }
    await _apiClient.delete('/products/$productId');
  }

  /// 切換上下架
  Future<Product> toggleAvailability(int productId, bool available) async {
    if (APIConfig.useMock) {
      return Product(
        id: productId,
        name: "Mock 商品 $productId",
        description: "這是模擬商品，用來測試上下架",
        price: 999,
        originalPrice: 1200,
        categoryId: 1,
        category: "Mock 分類",
        stockQuantity: available ? 10 : 0,
        status: available ? "available" : "unavailable",
        imageUrls: ["https://picsum.photos/seed/mock_$productId/300/200"],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        sellerId: 1,
        salesCount: 0,
        reviewCount: 0,
        tags: ["mock"],
        seller: null,
        shippingInfo: null,
      );
    }

    final responseBody = await _apiClient.patch(
      '/products/$productId/status',
      body: {'status': available ? 'available' : 'unavailable'},
    );
    return Product.fromJson(responseBody);
  }

  /// 取得賣家的商品
  Future<List<Product>> getMyProducts() async {
    if (APIConfig.useMock) {
      return buildMockProductsForUser("seller_user", count: 6);
    }

    final responseBody = await _apiClient.get('/seller/products');
    final List<dynamic> productListJson = responseBody;
    return productListJson.map((json) => Product.fromJson(json)).toList();
  }
}
