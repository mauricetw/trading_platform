// lib/pages/home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _filteredProducts = [];
  int? _selectedCategoryId;

  // 模擬商品分類數據
  final List<Category> _categories = [
    Category(id: 1, name: '書籍文具', icon: '📚', count: 156),
    Category(id: 2, name: '電子產品', icon: '📱', count: 89),
    Category(id: 3, name: '服裝配件', icon: '👕', count: 234),
    Category(id: 4, name: '家居用品', icon: '🏠', count: 178),
    Category(id: 5, name: '美容保健', icon: '💄', count: 67),
    Category(id: 6, name: '運動戶外', icon: '⚽', count: 123),
  ];

  // 模擬商品數據
  final List<Product> _products = [
    Product(
      id: 1,
      name: '大二下專業必修課本/甜品創作實記',
      price: 450,
      originalPrice: 580,
      imageUrl: 'https://via.placeholder.com/150x120',
      categoryId: 1,
      isFavorite: true,
    ),
    Product(
      id: 2,
      name: '九成新iPad 10',
      price: 8500,
      originalPrice: 12900,
      imageUrl: 'https://via.placeholder.com/150x120',
      categoryId: 2,
      isFavorite: false,
    ),
    Product(
      id: 3,
      name: 'iPhone 13 Pro Max',
      price: 25000,
      originalPrice: 35900,
      imageUrl: 'https://via.placeholder.com/150x120',
      categoryId: 2,
      isFavorite: false,
    ),
    Product(
      id: 4,
      name: '韓版寬鬆毛衣',
      price: 680,
      originalPrice: 980,
      imageUrl: 'https://via.placeholder.com/150x120',
      categoryId: 3,
      isFavorite: true,
    ),
    Product(
      id: 5,
      name: '無線藍牙耳機',
      price: 1200,
      originalPrice: 1800,
      imageUrl: 'https://via.placeholder.com/150x120',
      categoryId: 2,
      isFavorite: false,
    ),
    Product(
      id: 6,
      name: '保溫水杯',
      price: 280,
      originalPrice: 450,
      imageUrl: 'https://via.placeholder.com/150x120',
      categoryId: 4,
      isFavorite: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredProducts = _products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            _buildProductsGrid(),
          ],
        ),
      ),
    );
  }

  // 建構區塊標題
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

  // 建構商品分類網格
  Widget _buildCategoriesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
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

  // 建構分類卡片
  Widget _buildCategoryCard(Category category) {
    return GestureDetector(
      onTap: () => _filterByCategory(category.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${category.count} 件',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 建構商品網格
  Widget _buildProductsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  // 建構商品卡片
  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => _viewProduct(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.image,
                                size: 50, color: Colors.grey[400]),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product.isFavorite
                              ? Colors.red
                              : Colors.grey[600],
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'NT\$ ${_formatPrice(product.price)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                        if (product.originalPrice != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            'NT\$ ${_formatPrice(product.originalPrice!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
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

  // 格式化價格顯示
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  // 按分類篩選
  void _filterByCategory(int categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _filteredProducts = _products
          .where((product) => product.categoryId == categoryId)
          .toList();
    });
  }

  // 取得分類名稱
  String _getCategoryName(int categoryId) {
    return _categories
        .firstWhere((category) => category.id == categoryId)
        .name;
  }

  // 切換收藏狀態
  void _toggleFavorite(Product product) {
    setState(() {
      product.isFavorite = !product.isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(product.isFavorite ? '已加入收藏 ❤️' : '已取消收藏'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // 查看商品詳情
  void _viewProduct(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('商品詳情'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('商品名稱: ${product.name}'),
              const SizedBox(height: 8),
              Text('價格: NT\$ ${_formatPrice(product.price)}'),
              if (product.originalPrice != null)
                Text('原價: NT\$ ${_formatPrice(product.originalPrice!)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('關閉'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已加入購物車 🛒'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('加入購物車'),
            ),
          ],
        );
      },
    );
  }
}

// 商品分類模型
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

// 商品模型
class Product {
  final int id;
  final String name;
  final int price;
  final int? originalPrice;
  final String imageUrl;
  final int categoryId;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.categoryId,
    this.isFavorite = false,
  });
}