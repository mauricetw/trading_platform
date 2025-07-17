// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 用於價格格式化 (可選，但推薦)

// 假設您的 model 檔案路徑如下，請根據您的專案結構修改
import '../models/product/product.dart'; // Ensure this is the renewed Product model
import '../models/user/user.dart';    // Ensure this is your detailed User model
// import '../models/shipping_info.dart'; // 如果 Product model 需要

// 假設您的 ProductScreen 路徑如下
import 'product.dart'; // Assuming this is your Product Detail Screen

import 'package:first_flutter_project/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _filteredProducts = [];
  int? _selectedCategoryId;

  // 商品分類模型 (保持不變)
  final List<Category> _categories = [
    Category(id: 1, name: '書籍文具', icon: '📚', count: 156), // counts could be dynamic later
    Category(id: 2, name: '電子產品', icon: '📱', count: 89),
    Category(id: 3, name: '服裝配件', icon: '👕', count: 234),
    Category(id: 4, name: '家居用品', icon: '🏠', count: 178),
    Category(id: 5, name: '美容保健', icon: '💄', count: 67),
    Category(id: 6, name: '運動戶外', icon: '⚽', count: 123),
  ];

  // 更新的模擬商品數據，使用新的 Product Model 和詳細的 User Model
  List<Product> _products = []; // 真實資料會在 initState 中從後端載入
  /*final List<Product> _products = [
    Product(
      id: 'product-001',
      name: '大二下專業必修課本/甜品創作實記',
      description: '這是一本關於大二下學期專業必修課程的課本，以及一本關於甜品創作實踐的指南。適合相關專業學生和甜點愛好者。',
      price: 450.00,
      originalPrice: 580.00,
      imageUrls: ['https://source.unsplash.com/random/400x300?book', 'https://source.unsplash.com/random/400x300?textbook'],
      categoryId: 1,
      category: '書籍文具',
      stockQuantity: 15,
      isFavorite: true, // Example state
      isSold: false,    // Example state
      status: 'available',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      salesCount: 25,
      averageRating: 4.7,
      reviewCount: 18,
      tags: ['教科書', '甜點', '大學'],
      seller: User( // <--- CORRECTED User instantiation
        id: 'user-001',
        username: '校園二手書店',
        email: 'bookstore@example.com', // Required
        registeredAt: DateTime.now().subtract(const Duration(days: 365)), // Required
        avatarUrl: 'https://source.unsplash.com/random/100x100?store',
        isSeller: true,
        sellerName: '校園二手書店 (認證)',
        sellerDescription: '專營各類二手教科書、參考書及文具用品。',
        sellerRating: 4.8,
        productCount: 50, // Example count
        schoolName: '臺灣大學',
        isVerified: true,
      ),
      // shippingInfo: ShippingInformation(cost: 60.0, provider: "CampusDelivery"), // Example
    ),
    Product(
      id: 'product-002',
      name: '九成新iPad 10 (64GB, Wi-Fi)',
      description: '幾乎全新的 iPad 第十代，64GB Wi-Fi 版本，銀色。螢幕完美無刮痕，電池健康度良好。附原廠充電器和傳輸線。',
      price: 8500.00,
      originalPrice: 12900.00,
      imageUrls: ['https://source.unsplash.com/random/400x300?ipad', 'https://source.unsplash.com/random/400x300?tablet'],
      categoryId: 2,
      category: '電子產品',
      stockQuantity: 0,
      isFavorite: false,
      isSold: true, // Based on stockQuantity or status
      status: 'sold',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      salesCount: 1,
      averageRating: 4.0,
      reviewCount: 1,
      tags: ['iPad', '二手平板', 'Apple'],
      seller: User( // <--- CORRECTED User instantiation
        id: 'user-002',
        username: '科技愛好者李四',
        email: 'tech.li@example.com', // Required
        registeredAt: DateTime.now().subtract(const Duration(days: 180)), // Required
        avatarUrl: 'https://source.unsplash.com/random/100x100?person,tech',
        bio: '熱愛分享各種3C產品使用心得。',
        schoolName: '交通大學',
        isSeller: true,
        sellerName: '李四的3C小舖',
        sellerRating: 4.5,
        productCount: 12,
      ),
    ),
    Product(
      id: 'product-003',
      name: 'iPhone 13 Pro Max (256GB, 藍色)',
      description: 'iPhone 13 Pro Max，256GB儲存空間，天峰藍色。外觀完好，功能一切正常。保固已過期。',
      price: 22000.00,
      originalPrice: 35900.00,
      imageUrls: ['https://source.unsplash.com/random/400x300?iphone', 'https://source.unsplash.com/random/400x300?smartphone'],
      categoryId: 2,
      category: '電子產品',
      stockQuantity: 1,
      isFavorite: false,
      isSold: false,
      status: 'available',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      salesCount: 5,
      averageRating: 4.9,
      reviewCount: 3,
      tags: ['iPhone', '二手手機', 'Apple'],
      seller: User( // <--- CORRECTED User instantiation
        id: 'user-003',
        username: '果粉小王',
        email: 'wang.applefan@example.com', // Required
        registeredAt: DateTime.now().subtract(const Duration(days: 500)), // Required
        avatarUrl: 'https://source.unsplash.com/random/100x100?person,apple',
        isSeller: true,
        sellerName: '小王的蘋果二手專賣',
        sellerRating: 4.9,
        productCount: 8,
        isVerified: true,
      ),
    ),
    Product(
      id: 'product-004',
      name: '韓版寬鬆毛衣 (米白色)',
      description: '冬季新款韓版設計寬鬆毛衣，米白色，非常百搭。材質柔軟舒適，保暖性佳。',
      price: 680.00,
      originalPrice: 980.00,
      imageUrls: ['https://source.unsplash.com/random/400x300?sweater', 'https://source.unsplash.com/random/400x300?clothing'],
      categoryId: 3,
      category: '服裝配件',
      stockQuantity: 8,
      isFavorite: true,
      isSold: false,
      status: 'available',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      salesCount: 12,
      tags: ['毛衣', '韓版', '冬季'],
      seller: User( // <--- CORRECTED User instantiation
        id: 'user-004',
        username: '時尚衣櫥小舖',
        email: 'fashion.closet@example.com', // Required
        registeredAt: DateTime.now().subtract(const Duration(days: 90)), // Required
        avatarUrl: 'https://source.unsplash.com/random/100x100?fashion',
        isSeller: true,
        sellerName: '時尚衣櫥小舖',
        sellerDescription: '提供最新潮流服飾，每日上新。',
        sellerRating: 4.6,
        productCount: 35,
        schoolName: '輔仁大學',
      ),
    ),
    // ... 可以添加更多商品，確保每個 Product 的 seller 都符合 User model
  ];
  */

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // 修正錯誤：呼叫函式不是 List
  }

  void _fetchProducts() async {
    try {
      List<Product> products = await ApiService().getProducts(); //從 FastAPI 拿資料
      setState(() {
        _products = products;
        _filteredProducts = List.from(products);
      });
    } catch (e) {
      print("取得商品資訊失敗: $e");
      // 可顯示錯誤訊息或重試按鈕
    }
  }

  // 價格格式化 (使用 intl 套件)
  String _formatPrice(double price) {
    // 確保 price 不是 null，雖然在 Product model 中 price 是 non-nullable
    final formatCurrency = NumberFormat.currency(locale: "zh_TW", symbol: "NT\$", decimalDigits: 0);
    return formatCurrency.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('校園市集')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('商品分類'),
            const SizedBox(height: 16),
            _buildCategoriesGrid(),
            const SizedBox(height: 32),
            _buildSectionTitle(_selectedCategoryId == null
                ? '熱門商品'
                : _getCategoryName(_selectedCategoryId!)),
            const SizedBox(height: 16),
            _filteredProducts.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Text(
                  _selectedCategoryId == null ? '目前沒有商品' : '此分類下沒有商品',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            )
                : _buildProductsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Adjust for different screen sizes if needed
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(Category category) {
    bool isSelected = _selectedCategoryId == category.id;
    return GestureDetector(
      onTap: () => _filterByCategory(category.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [Theme.of(context).primaryColor, Theme.of(context).primaryColorDark]
                      : [const Color(0xFF1E88E5), const Color(0xFF1565C0)], // Example default gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22.5),
              ),
              child: Center(
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
                color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${category.count} 件',
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.8) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Adjust for different screen sizes if needed
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75, // Adjust for card content
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    String imageUrlToDisplay = 'https://via.placeholder.com/300x250/E0E0E0/000000?Text=No+Image';
    if (product.imageUrls.isNotEmpty && product.imageUrls.first.isNotEmpty) {
      imageUrlToDisplay = product.imageUrls.first;
    }

    // These are now directly from the Product model
    bool isProductSold = product.isSold;
    bool isProductFavorite = false;

    return GestureDetector(
      onTap: () => _viewProduct(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        imageUrlToDisplay,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey[400])),
                          );
                        },
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (isProductSold)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'SOLD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isProductFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isProductFavorite ? Colors.redAccent : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatPrice(product.price),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (product.originalPrice != null && product.originalPrice! > product.price)
                          Text(
                            _formatPrice(product.originalPrice!),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterByCategory(int categoryId) {
    setState(() {
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = null;
        _filteredProducts = List.from(_products);
      } else {
        _selectedCategoryId = categoryId;
        _filteredProducts = _products.where((product) => product.categoryId == categoryId).toList();
      }
    });
  }

  String _getCategoryName(int categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId).name;
    } catch (e) {
      return "未知分類"; // Fallback name
    }
  }

  void _toggleFavorite(Product productToToggle) {
    setState(() {
      // Find the index of the product in the original _products list
      final productIndex = _products.indexWhere((p) => p.id == productToToggle.id);
      if (productIndex != -1) {
        // Create a new Product instance with the toggled favorite state
        // This assumes your Product model has a copyWith method
        final updatedProduct = _products[productIndex].copyWith(
          //isFavorite: !_products[productIndex].isFavorite,
          isFavorite: false,
        );
        // Replace the old product with the updated one in the _products list
        _products[productIndex] = updatedProduct;

        // Also update the product in _filteredProducts if it exists there
        final filteredProductIndex = _filteredProducts.indexWhere((p) => p.id == productToToggle.id);
        if (filteredProductIndex != -1) {
          _filteredProducts[filteredProductIndex] = updatedProduct;
        } else {
          // If for some reason it wasn't in filtered list (e.g. category changed),
          // re-filter. This is a safe fallback.
          _filteredProducts = _products.where((p) {
            return _selectedCategoryId == null || p.categoryId == _selectedCategoryId;
          }).toList();
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        //content: Text(productToToggle.isFavorite ? '已取消收藏' : '已加入收藏 ❤️'), // Logic inverted due to reading state before update
        content: Text(false ? '已取消收藏' : '已加入收藏 ❤️'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _viewProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductScreen(product: product),
      ),
    );
  }
}

// 商品分類模型 (通常會放在單獨的 model 檔案中)
class Category {
  final int id;
  final String name;
  final String icon;
  final int count;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.count,
  });
}
