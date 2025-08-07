import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 用於價格格式化

import '../models/product/product.dart';
import '../models/user/user.dart';
import '../models/product/category.dart';
import '../providers/auth_provider.dart';
import 'product.dart'; // 修改了 ProductScreen 的導入名稱以匹配常見做法

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _filteredProducts = [];
  String? _selectedCategoryId; // <--- 修改: 類型變為 String?

  User? _currentUser;

  // 商品分類數據 (根據新的 Category 模型調整)
  // 注意：由於新的 Category 模型沒有 icon 和 count，這裡需要做相應調整
  // 你可能需要從後端獲取這些數據，或者在 UI 上有不同的呈現方式
  final List<Category> _categories = [
    Category(id: 'cat-001', name: '書籍文具'), // parentId 默認為 null
    Category(id: 'cat-002', name: '電子產品'),
    Category(id: 'cat-003', name: '服裝配件'),
    Category(id: 'cat-004', name: '家居用品'),
    Category(id: 'cat-005', name: '美容保健'),
    Category(id: 'cat-006', name: '運動戶外'),
  ];

  // 初始商品數據列表
  // 【重要】確保 Product 模型中的 categoryId 也更新為 String 類型，如果它與 Category.id 關聯
  final List<Product> _initialProducts = [
    Product(
      id: 'product-001',
      name: '大二下專業必修課本/甜品創作實記',
      description: '這是一本關於大二下學期專業必修課程的課本，以及一本關於甜品創作實踐的指南。適合相關專業學生和甜點愛好者。',
      price: 450.00,
      originalPrice: 580.00,
      imageUrls: ['https://source.unsplash.com/random/400x300?book', 'https://source.unsplash.com/random/400x300?textbook'],
      categoryId: 1, // <--- 【假設】Product.categoryId 也應為 String
      category: '書籍文具', // 這個字段可以保留用於顯示，但篩選應基於 categoryId
      stockQuantity: 15,
      isSold: false,
      status: 'available',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      salesCount: 25,
      averageRating: 4.7,
      reviewCount: 18,
      tags: ['教科書', '甜點', '大學'],
      seller: User(
        id: 'user-001',
        username: '校園二手書店',
        email: 'bookstore@example.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 365)),
        avatarUrl: 'https://source.unsplash.com/random/100x100?store',
        isSeller: true,
        sellerName: '校園二手書店 (認證)',
        sellerDescription: '專營各類二手教科書、參考書及文具用品。',
        sellerRating: 4.8,
        productCount: 50,
        schoolName: '臺灣大學',
        isVerified: true,
        favoriteProductIds: [],
      ),
    ),
    Product(
      id: 'product-002',
      name: '九成新iPad 10 (64GB, Wi-Fi)',
      description: '幾乎全新的 iPad 第十代，64GB Wi-Fi 版本，銀色。螢幕完美無刮痕，電池健康度良好。附原廠充電器和傳輸線。',
      price: 8500.00,
      originalPrice: 12900.00,
      imageUrls: ['https://source.unsplash.com/random/400x300?ipad', 'https://source.unsplash.com/random/400x300?tablet'],
      categoryId: 2, // <--- 【假設】
      category: '電子產品',
      stockQuantity: 0,
      isSold: true,
      status: 'sold',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      salesCount: 1,
      averageRating: 4.0,
      reviewCount: 1,
      tags: ['iPad', '二手平板', 'Apple'],
      seller: User(
        id: 'user-002',
        username: '科技愛好者李四',
        email: 'tech.li@example.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 180)),
        avatarUrl: 'https://source.unsplash.com/random/100x100?person,tech',
        bio: '熱愛分享各種3C產品使用心得。',
        schoolName: '交通大學',
        isSeller: true,
        sellerName: '李四的3C小舖',
        sellerRating: 4.5,
        productCount: 12,
        favoriteProductIds: [],
      ),
    ),
    Product(
      id: 'product-003',
      name: 'iPhone 13 Pro Max (256GB, 藍色)',
      description: 'iPhone 13 Pro Max，256GB儲存空間，天峰藍色。外觀完好，功能一切正常。保固已過期。',
      price: 22000.00,
      originalPrice: 35900.00,
      imageUrls: ['https://source.unsplash.com/random/400x300?iphone', 'https://source.unsplash.com/random/400x300?smartphone'],
      categoryId: 2, // <--- 【假設】
      category: '電子產品',
      stockQuantity: 1,
      isSold: false,
      status: 'available',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      salesCount: 5,
      averageRating: 4.9,
      reviewCount: 3,
      tags: ['iPhone', '二手手機', 'Apple'],
      seller: User(
        id: 'user-003',
        username: '果粉小王',
        email: 'wang.applefan@example.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 500)),
        avatarUrl: 'https://source.unsplash.com/random/100x100?person,apple',
        isSeller: true,
        sellerName: '小王的蘋果二手專賣',
        sellerRating: 4.9,
        productCount: 8,
        isVerified: true,
        favoriteProductIds: [],
      ),
    ),
    Product(
      id: 'product-004',
      name: '韓版寬鬆毛衣 (米白色)',
      description: '冬季新款韓版設計寬鬆毛衣，米白色，非常百搭。材質柔軟舒適，保暖性佳。',
      price: 680.00,
      originalPrice: 980.00,
      imageUrls: ['https://source.unsplash.com/random/400x300?sweater', 'https://source.unsplash.com/random/400x300?clothing'],
      categoryId: 3, // <--- 【假設】
      category: '服裝配件',
      stockQuantity: 8,
      isSold: false,
      status: 'available',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      salesCount: 12,
      tags: ['毛衣', '韓版', '冬季'],
      seller: User(
        id: 'user-004',
        username: '時尚衣櫥小舖',
        email: 'fashion.closet@example.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 90)),
        avatarUrl: 'https://source.unsplash.com/random/100x100?fashion',
        isSeller: true,
        sellerName: '時尚衣櫥小舖',
        sellerDescription: '提供最新潮流服飾，每日上新。',
        sellerRating: 4.6,
        productCount: 35,
        schoolName: '輔仁大學',
        favoriteProductIds: [],
      ),
    ),
  ];

  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
    // 【重要】確保 Product 模型中的 categoryId 與 Category.id 的類型和值匹配
    // 如果 Product.categoryId 還是 int，這裡的過濾邏輯會出錯
    _products = List.from(_initialProducts);
    _filteredProducts = List.from(_products);
  }

  void _loadCurrentUserData() {
    setState(() {
      _currentUser = User(
        id: 'current-user-id-001',
        username: '當前用戶',
        email: 'currentuser@example.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 100)),
        favoriteProductIds: ['product-001', 'product-004'],
      );
    });
  }

  String _formatPrice(double price) {
    final formatCurrency = NumberFormat.currency(locale: "zh_TW", symbol: "NT\$", decimalDigits: 0);
    return formatCurrency.format(price);
  }

  int _getCrossAxisCount(BuildContext context, {required String gridType}) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (gridType == 'category') {
      if (screenWidth < 360) return 2;
      if (screenWidth < 600) return 3;
      if (screenWidth < 900) return 4;
      return 5;
    } else if (gridType == 'product') {
      if (screenWidth < 360) return 1;
      if (screenWidth < 600) return 2;
      if (screenWidth < 900) return 3;
      return 4;
    }
    return 2;
  }

  double _getChildAspectRatio(BuildContext context, {required String gridType}) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (gridType == 'category') {
      // 由於沒有了圖標和計數，可能需要調整卡片比例，使其更適合只顯示文字
      if (screenWidth < 360) return 1.5; // 增加高度以便文字顯示
      if (screenWidth < 600) return 1.6;
      return 1.8;
    } else if (gridType == 'product') {
      if (screenWidth < 360) return 0.8;
      if (screenWidth < 600) return 0.75;
      return 0.8;
    }
    return 1.0;
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = 1.0;
    if (screenWidth < 360) scaleFactor = 0.85;
    else if (screenWidth < 600) scaleFactor = 1.0;
    else if (screenWidth < 900) scaleFactor = 1.1;
    else scaleFactor = 1.2;
    return baseSize * scaleFactor;
  }

  double _getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseSpacing * 0.8;
    if (screenWidth < 600) return baseSpacing;
    if (screenWidth < 900) return baseSpacing * 1.2;
    return baseSpacing * 1.5;
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _getResponsiveSpacing(context, 16.0);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: _getResponsiveSpacing(context, 16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('商品分類', context),
            SizedBox(height: _getResponsiveSpacing(context, 16.0)),
            _buildCategoriesGrid(context),
            SizedBox(height: _getResponsiveSpacing(context, 32.0)),
            _buildSectionTitle(_selectedCategoryId == null
                ? '熱門商品'
                : _getCategoryName(_selectedCategoryId!), // <--- 現在傳遞 String
                context),
            SizedBox(height: _getResponsiveSpacing(context, 16.0)),
            _filteredProducts.isEmpty
                ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: _getResponsiveSpacing(context, 32.0),
                ),
                child: Text(
                  _selectedCategoryId == null ? '目前沒有商品' : '此分類下沒有商品',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 16),
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
                : _buildProductsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: _getResponsiveFontSize(context, 20),
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context, gridType: 'category');
    final childAspectRatio = _getChildAspectRatio(context, gridType: 'category');
    final spacing = _getResponsiveSpacing(context, 12.0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _buildCategoryCard(category, context);
      },
    );
  }

  // 修改 Category Card 的 UI，因為沒有 icon 和 count
  Widget _buildCategoryCard(Category category, BuildContext context) {
    bool isSelected = _selectedCategoryId == category.id;
    final screenWidth = MediaQuery.of(context).size.width;
    // 移除了 iconSize 和 iconFontSize，因為模型不再包含 icon
    // 你可以根據需要調整卡片內元素的樣式

    return GestureDetector(
      onTap: () => _filterByCategory(category.id), // <--- 現在傳遞 String
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
        child: Column( // 只顯示分類名稱
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // 確保文字居中
          children: [
            // 由於沒有 icon，我們可以增大 name 的字體或做其他強調
            // 或者使用一個固定的圖標 placeholder
            Padding( // 給文字一些邊距，避免貼邊
              padding: EdgeInsets.all(_getResponsiveSpacing(context, 8.0)),
              child: Text(
                category.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: _getResponsiveFontSize(context, 14), // 調整字體大小
                  color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // 允許兩行以防名稱過長
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 移除了顯示 count 的 Text Widget
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context, gridType: 'product');
    final childAspectRatio = _getChildAspectRatio(context, gridType: 'product');
    final spacing = _getResponsiveSpacing(context, 12.0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        bool isFavByCurrentUser = _currentUser?.favoriteProductIds.contains(product.id) ?? false;
        return _buildProductCard(product, context, isFavByCurrentUser);
      },
    );
  }

  Widget _buildProductCard(Product product, BuildContext context, bool isCurrentlyFavorite) {
    String imageUrlToDisplay = 'https://via.placeholder.com/300x250/E0E0E0/000000?Text=No+Image';
    if (product.imageUrls.isNotEmpty && product.imageUrls.first.isNotEmpty) {
      imageUrlToDisplay = product.imageUrls.first;
    }

    bool isProductSold = product.isSold;
    final screenWidth = MediaQuery.of(context).size.width;
    double cardPadding = screenWidth < 360 ? 8.0 : 10.0;
    double iconSize = screenWidth < 360 ? 16 : 18;

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
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: screenWidth < 360 ? 30 : 40,
                                color: Colors.grey[400],
                              ),
                            ),
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
                      top: _getResponsiveSpacing(context, 8.0),
                      left: _getResponsiveSpacing(context, 8.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth < 360 ? 6 : 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'SOLD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _getResponsiveFontSize(context, 10),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(_getResponsiveSpacing(context, 6.0)),
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(product),
                      child: Container(
                        padding: EdgeInsets.all(screenWidth < 360 ? 4 : 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCurrentlyFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isCurrentlyFavorite ? Colors.redAccent : Colors.white,
                          size: iconSize,
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
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 14),
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatPrice(product.price),
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (product.originalPrice != null && product.originalPrice! > product.price)
                          Text(
                            _formatPrice(product.originalPrice!),
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 11),
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

  // 修改: categoryId 類型變為 String
  void _filterByCategory(String categoryId) {
    setState(() {
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = null;
        _filteredProducts = List.from(_products);
      } else {
        _selectedCategoryId = categoryId;
        // 【重要】確保 Product.categoryId 也是 String 類型，並且與 Category.id 的值可以匹配
        _filteredProducts = _products.where((product) => product.categoryId == categoryId).toList();
      }
    });
  }

  // 修改: categoryId 類型變為 String
  String _getCategoryName(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId).name;
    } catch (e) {
      return "未知分類"; // 或者返回空字符串，或者處理錯誤
    }
  }

  void _toggleFavorite(Product productToToggle) {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先登錄才能收藏商品')),
      );
      return;
    }

    final bool wasFavoriteBeforeToggle = _currentUser!.favoriteProductIds.contains(productToToggle.id);
    // bool isNowFavorite; // 在 setState 外部声明，以便 SnackBar 可以访问 (这个变量在这里不是必须的，因为我们直接用更新后的currentUser判断)

    setState(() {
      List<String> updatedFavoriteIds = List.from(_currentUser!.favoriteProductIds);

      if (wasFavoriteBeforeToggle) {
        updatedFavoriteIds.remove(productToToggle.id);
        // isNowFavorite = false;
        print('API CALL: Remove ${productToToggle.id} from favorites for user ${_currentUser!.id}');
      } else {
        updatedFavoriteIds.add(productToToggle.id);
        // isNowFavorite = true;
        print('API CALL: Add ${productToToggle.id} to favorites for user ${_currentUser!.id}');
      }
      _currentUser = _currentUser!.copyWith(favoriteProductIds: updatedFavoriteIds);
    });

    final bool currentFavoriteStatus = _currentUser!.favoriteProductIds.contains(productToToggle.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(currentFavoriteStatus ? '已加入收藏 ❤️' : '已取消收藏'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _viewProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductScreen(
          productId: product.id, // 確保 ProductScreen 接受 productId
        ),
      ),
    );
  }
}
