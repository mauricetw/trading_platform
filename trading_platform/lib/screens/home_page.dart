// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 用於價格格式化

// 假設您的 model 檔案路徑如下，請根據您的專案結構修改
import '../models/product/product.dart'; // Ensure this is the renewed Product model
import '../models/user/user.dart';    // Ensure this is your detailed User model and contains favoriteProductIds
// import '../models/shipping_info.dart'; // 如果 Product model 需要

// 假設您的 ProductScreen 路徑如下
import 'product.dart'; // Assuming this is your Product Detail Screen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _filteredProducts = [];
  int? _selectedCategoryId;

  // 新增：模擬當前用戶
  // 在真實應用中，這個用戶對象應該從您的認證/狀態管理器獲取
  User? _currentUser;

  // 商品分類模型 (保持不變)
  final List<Category> _categories = [
    Category(id: 1, name: '書籍文具', icon: '📚', count: 156),
    Category(id: 2, name: '電子產品', icon: '📱', count: 89),
    Category(id: 3, name: '服裝配件', icon: '👕', count: 234),
    Category(id: 4, name: '家居用品', icon: '🏠', count: 178),
    Category(id: 5, name: '美容保健', icon: '💄', count: 67),
    Category(id: 6, name: '運動戶外', icon: '⚽', count: 123),
  ];

  // 初始商品數據列表 (isFavorite 不再直接在此處設置)
  final List<Product> _initialProducts = [
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
      // isFavorite: true, // 移除或忽略，由 currentUser.favoriteProductIds 決定
      isSold: false,
      status: 'available',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      salesCount: 25,
      averageRating: 4.7,
      reviewCount: 18,
      tags: ['教科書', '甜點', '大學'],
      seller: User( // 賣家 User 對象
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
        favoriteProductIds: [], // 賣家本身通常不需要收藏列表
      ),
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
      // isFavorite: false, // 移除或忽略
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
      categoryId: 2,
      category: '電子產品',
      stockQuantity: 1,
      // isFavorite: false, // 移除或忽略
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
      categoryId: 3,
      category: '服裝配件',
      stockQuantity: 8,
      // isFavorite: true, // 移除或忽略
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

  List<Product> _products = []; // 用於界面顯示的商品列表

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData(); // 模擬加載用戶數據
    _products = List.from(_initialProducts); // 使用 _initialProducts 初始化
    _filteredProducts = List.from(_products); // 初始化過濾後的商品列表
  }

  // 模擬加載用戶數據
  void _loadCurrentUserData() {
    // 在真實應用中，您會異步獲取用戶數據，例如從 Provider 或 API
    setState(() {
      _currentUser = User(
        id: 'current-user-id-001', // 模擬用戶ID
        username: '當前用戶',
        email: 'currentuser@example.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 100)),
        favoriteProductIds: ['product-001', 'product-004'], // 示例：該用戶收藏了這兩個商品
        // 其他 User 屬性可以根據需要添加
      );
    });
  }

  // 價格格式化 (使用 intl 套件)
  String _formatPrice(double price) {
    final formatCurrency = NumberFormat.currency(locale: "zh_TW", symbol: "NT\$", decimalDigits: 0);
    return formatCurrency.format(price);
  }

  // 獲取響應式數值的輔助方法 (保持不變)
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
      if (screenWidth < 360) return 0.9;
      if (screenWidth < 600) return 1.0;
      return 1.1;
    } else if (gridType == 'product') {
      if (screenWidth < 360) return 0.8; // 針對單列商品調整比例
      if (screenWidth < 600) return 0.75; // 默認手機
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
                : _getCategoryName(_selectedCategoryId!), context),
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

  Widget _buildCategoryCard(Category category, BuildContext context) {
    bool isSelected = _selectedCategoryId == category.id;
    final screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth < 360 ? 35 : screenWidth < 600 ? 45 : 50;
    double iconFontSize = screenWidth < 360 ? 18 : screenWidth < 600 ? 22 : 24;

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
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [Theme.of(context).primaryColor, Theme.of(context).primaryColorDark]
                      : [const Color(0xFF1E88E5), const Color(0xFF1565C0)], // 默認漸變色
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(iconSize / 2),
              ),
              child: Center(
                child: Text(
                  category.icon,
                  style: TextStyle(fontSize: iconFontSize, color: Colors.white), // 確保圖示可見
                ),
              ),
            ),
            SizedBox(height: _getResponsiveSpacing(context, 8.0)),
            Flexible(
              child: Text(
                category.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: _getResponsiveFontSize(context, 12),
                  color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: _getResponsiveSpacing(context, 4.0)),
            Text(
              '${category.count} 件',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 10),
                color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.8) : Colors.grey[600],
              ),
            ),
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
        // 判斷商品是否被當前用戶收藏
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
                    padding: EdgeInsets.all(_getResponsiveSpacing(context, 6.0)), // 調整圖標外邊距
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

  void _filterByCategory(int categoryId) {
    setState(() {
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = null;
        _filteredProducts = List.from(_products); // 恢復到所有商品 (或基於當前 _products)
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
      return "未知分類";
    }
  }

  void _toggleFavorite(Product productToToggle) {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先登錄才能收藏商品')),
      );
      return;
    }

    // 先记录下操作前的收藏状态，用于后续判断是添加还是移除
    final bool wasFavoriteBeforeToggle = _currentUser!.favoriteProductIds.contains(productToToggle.id);
    bool isNowFavorite; // 在 setState 外部声明，以便 SnackBar 可以访问

    setState(() {
      List<String> updatedFavoriteIds = List.from(_currentUser!.favoriteProductIds);

      if (wasFavoriteBeforeToggle) { // 如果之前已收藏，则现在是移除
        updatedFavoriteIds.remove(productToToggle.id);
        isNowFavorite = false; // 更新状态
        // TODO: 調用 API 將商品從後端收藏中移除
        print('API CALL: Remove ${productToToggle.id} from favorites for user ${_currentUser!.id}');
      } else { // 如果之前未收藏，则现在是添加
        updatedFavoriteIds.add(productToToggle.id);
        isNowFavorite = true; // 更新状态
        // TODO: 調用 API 將商品添加到後端收藏中
        print('API CALL: Add ${productToToggle.id} to favorites for user ${_currentUser!.id}');
      }

      // 更新本地用戶對象的收藏列表
      _currentUser = _currentUser!.copyWith(favoriteProductIds: updatedFavoriteIds);
    });

    // setState 完成后，_currentUser 的状态已经更新
    // 我们可以直接从更新后的 _currentUser 判断当前的收藏状态来显示 SnackBar
    // 或者使用在 setState 中更新的 isNowFavorite 变量
    // 为了更清晰，我们使用 isNowFavorite (它在 setState 之后的值是正确的)

    // 在这里，isNowFavorite 应该已经被正确赋值
    // 但为了确保，我们重新从 _currentUser 获取最新的状态来决定提示信息
    // 这是一个更保险的做法，确保提示信息与实际状态一致
    final bool currentFavoriteStatus = _currentUser!.favoriteProductIds.contains(productToToggle.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(currentFavoriteStatus ? '已加入收藏 ❤️' : '已取消收藏'),
        duration: const Duration(seconds: 1),
      ),
    );
  }


  void _viewProduct(Product product) {
    // 傳遞商品到詳情頁
    // 如果 ProductScreen 也需要知道收藏狀態，您可能需要傳遞 _currentUser 或 isCurrentlyFavorite
    bool isCurrentlyFavorite = _currentUser?.favoriteProductIds.contains(product.id) ?? false;

    Navigator.push(
      context,
      MaterialPageRoute(
        // 假設 ProductScreen 可以接收 product 和 isFavorite 狀態
        // 您可能需要修改 ProductScreen 的構造函數
        builder: (context) => ProductScreen(
          product: product,
          // initialIsFavorite: isCurrentlyFavorite, // 示例：如果ProductScreen需要初始收藏狀態
          // currentUser: _currentUser, // 或者直接傳遞用戶對象，讓 ProductScreen 自己處理
        ),
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
