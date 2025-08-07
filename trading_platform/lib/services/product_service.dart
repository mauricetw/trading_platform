// services/product_service.dart
import '../models/product/product.dart';
import '../models/user/user.dart'; // 【【確保這個路徑是正確的】】

class ProductService {
  Future<Product> getProductById(String productId) async {
    print('ProductService: Fetching product with ID: $productId');
    await Future.delayed(const Duration(seconds: 1));

    // --- 【【【這是您需要替換為真實 API 調用的地方】】】 ---
    // final response = await http.get(Uri.parse('https://your-api.com/products/$productId'));
    // if (response.statusCode == 200) {
    //   // 假設後端返回的 JSON 包含一個 seller 對象，其結構可以被 User.fromJson 解析
    //   return Product.fromJson(json.decode(response.body));
    // } else {
    //   throw Exception('Failed to load product (Status code: ${response.statusCode})');
    // }
    // --- 【【【模擬數據開始】】】 ---

    // 創建模擬的 Seller User 對象 (使用您提供的 User 模型)
    User mockSeller1 = User(
      id: 'seller001',
      username: 'BrandStoreOfficial', // 內部用戶名
      email: 'seller1@example.com', // 私密
      registeredAt: DateTime.now().subtract(const Duration(days: 180)),
      avatarUrl: 'https://via.placeholder.com/100/007BFF/FFFFFF?Text=BS',
      isSeller: true,
      sellerName: '品牌旗艦官方店', // 公開的店鋪名
      sellerDescription: '官方授權，品質保證，提供優質售後服務。',
      sellerRating: 4.8,
      productCount: 150,
      publicDisplayName: '品牌旗艦店', // 用戶設置的公開顯示名
      publicBio: '我們致力於提供最好的產品和購物體驗！',
      isSchoolPublic: false,
      // 其他 User 字段可以根據需要填充或保持默認/null
      favoriteProductIds: [], // 假設賣家自己沒有收藏商品列表
    );

    User mockSeller2 = User(
      id: 'seller002',
      username: 'FashionTrendSetter',
      email: 'seller2@example.com',
      registeredAt: DateTime.now().subtract(const Duration(days: 365)),
      avatarUrl: 'https://via.placeholder.com/100/FFC107/000000?Text=FT',
      isSeller: true,
      sellerName: '潮流前線精品',
      sellerDescription: '每日上新，緊跟時尚潮流。',
      sellerRating: 4.5,
      productCount: 85,
      publicDisplayName: '潮流前線',
      publicBio: '發現你的時尚風格。新用戶享優惠！',
      schoolName: '城市設計學院', // 假設賣家填寫了學校
      isSchoolPublic: true, // 假設賣家選擇公開學校
      favoriteProductIds: [],
    );

    if (productId == 'product123') {
      return Product(
          id: productId,
          name: '精選商品 (ID: $productId)',
          description: '這是一個從後端加載的優質商品，具有多種特性和優點。',
          price: 199.99,
          imageUrls: [

            'https://via.placeholder.com/400x300/FFA500/000000?Text=Product+Image+1',
            'https://via.placeholder.com/400x300/FFC0CB/000000?Text=Product+Image+2'
          ],
        category: '電子產品',
        status: '有庫存',
        stockQuantity: 25,
        categoryId: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        seller: mockSeller1, // 【【使用您 User 模型的實例】】
      );
    } else if (productId == 'anotherProduct789') {
      return Product(
        id: productId,
        name: '熱銷爆款 (ID: $productId)',
        description: '這是另一個非常受歡迎的商品，評價極高。',
        price: 89.50,
        imageUrls: [
          'https://via.placeholder.com/400x300/28A745/FFFFFF?Text=Hot+Item'
        ],
        category: '服裝飾品',
        status: '即將售罄',
        stockQuantity: 5,
        categoryId: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        seller: mockSeller2, // 【【使用您 User 模型的實例】】
      );
    } else {
      throw Exception('Product with ID $productId not found.');
    }
    // --- 【【【模擬數據結束】】】 ---
  }
}

