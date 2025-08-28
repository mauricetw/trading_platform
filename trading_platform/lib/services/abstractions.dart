import '../models/product/product.dart';
import '../models/user/user.dart';
import '../models/user/shipping_option.dart';

abstract class IProductService {
  Future<Product> getProductById(int productId);
  Future<List<Product>> getProductsBySeller(int userId);
  Future<List<Product>> getAllProducts();
}

abstract class IUserService {
  Future<User> getPublicProfile(int userId);
}

abstract class IAuthService {
  Future<User?> getCurrentUser();
  Future<User> signInSilently();
  Future<void> signOut();
}

// ShippingOption.id 在你的實作是 String
abstract class IShippingService {
  Future<List<ShippingOption>> getShippingOptions(String userId);
  Future<ShippingOption> addShippingOption(ShippingOption option /*, String userId */);
  Future<ShippingOption> updateShippingOption(ShippingOption option);
  Future<void> deleteShippingOption(String optionId);
}
