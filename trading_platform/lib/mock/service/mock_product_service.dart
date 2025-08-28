import 'package:first_flutter_project/mock/mock.dart';
import '../../models/product/product.dart';
import '../../services/abstractions.dart';

class MockProductService implements IProductService {
  @override
  Future<Product> getProductById(int productId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return findMockProductById(productId);
  }

  @override
  Future<List<Product>> getProductsBySeller(int userId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return generateProductsForSeller(userId, count: 8);
  }

  @override
  Future<List<Product>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return mockAllProducts();
  }
}
