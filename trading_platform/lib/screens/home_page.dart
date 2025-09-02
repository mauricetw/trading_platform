// --- FILE: lib/screens/home_page.dart ---
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product/product.dart';
import '../providers/product_provider.dart';
import 'product.dart'; // 確保 ProductScreen 存在

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 Consumer 來監聽 ProductProvider 的變化，並在狀態改變時自動重建 UI
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Scaffold(
          // 使用 RefreshIndicator 讓使用者可以下拉刷新商品列表
          body: RefreshIndicator(
            onRefresh: () => productProvider.fetchProducts(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('商品分類'),
                  const SizedBox(height: 16),
                  // 分類網格現在會從 Provider 獲取狀態
                  const _CategoriesGrid(),
                  const SizedBox(height: 32),
                  _buildSectionTitle(productProvider.selectedCategoryId == null
                      ? '熱門商品'
                      : _getCategoryName(productProvider.selectedCategoryId!)),
                  const SizedBox(height: 16),
                  // 根據 Provider 的狀態（載入中、錯誤、空、有資料）顯示不同的 UI
                  _buildProductContent(context, productProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 根據 Provider 狀態決定顯示內容的輔助函式
  Widget _buildProductContent(BuildContext context, ProductProvider provider) {
    // 修復：檢查 isLoading 屬性是否存在
    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
    }
    // 修復：檢查 error 屬性是否存在
    if (provider.error != null) {
      return Center(child: Text('發生錯誤: ${provider.error}'));
    }
    if (provider.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Text(
            provider.selectedCategoryId == null ? '目前沒有商品' : '此分類下沒有商品',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }
    // 如果有資料，則建立商品網格
    return _ProductsGrid(products: provider.products);
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  // 輔助函式，用於從靜態列表中獲取分類名稱
  String _getCategoryName(int categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId).name;
    } catch (e) {
      return "未知分類";
    }
  }
}

// --- 將分類網格提取為獨立 Widget，使其更清晰 ---
class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid();
  @override
  Widget build(BuildContext context) {
    // 使用 context.read 來觸發方法，因为它不會在 build 方法中改變
    final productProvider = context.read<ProductProvider>();
    // 使用 context.watch 來監聽 selectedCategoryId 的變化，以便 UI 可以更新
    final selectedId = context.watch<ProductProvider>().selectedCategoryId;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.0,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        bool isSelected = selectedId == category.id;
        return _buildCategoryCard(context, category, isSelected, () {
          // 點擊時呼叫 Provider 的方法來篩選商品
          productProvider.filterByCategory(category.id);
        });
      },
    );
  }

  // 修復：使用 withValues() 替代已廢棄的 withOpacity()
  Widget _buildCategoryCard(BuildContext context, Category category, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 1.5) : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
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
                            : [const Color(0xFF1E88E5), const Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight
                    ),
                    borderRadius: BorderRadius.circular(22.5)
                ),
                child: Center(
                    child: Text(category.icon, style: const TextStyle(fontSize: 22))
                )
            ),
            const SizedBox(height: 8),
            Text(
                category.name,
                style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                    color: isSelected ? Theme.of(context).primaryColor : Colors.black87
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis
            ),
            const SizedBox(height: 4),
            Text(
                '${category.count} 件',
                style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.8) : Colors.grey[600]
                )
            ),
          ],
        ),
      ),
    );
  }
}

// --- 將商品網格提取為獨立 Widget ---
class _ProductsGrid extends StatelessWidget {
  final List<Product> products;
  const _ProductsGrid({required this.products});
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(product: product);
      },
    );
  }
}

// --- 商品卡片 Widget ---
class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  String _formatPrice(double price) {
    final formatCurrency = NumberFormat.currency(locale: "zh_TW", symbol: "NT\$", decimalDigits: 0);
    return formatCurrency.format(price);
  }

  @override
  Widget build(BuildContext context) {
    String imageUrlToDisplay = 'https://via.placeholder.com/300x250/E0E0E0/000000?Text=No+Image';
    if (product.imageUrls.isNotEmpty && product.imageUrls.first.isNotEmpty) {
      imageUrlToDisplay = product.imageUrls.first;
    }

    return GestureDetector(
      // 導航到商品詳情頁，並傳遞 productId
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductScreen(productId: product.id))),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))]
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
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12))
                          ),
                          child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                  imageUrlToDisplay,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                          child: Icon(Icons.broken_image, size: 40, color: Colors.grey[400])
                                      )
                                  ),
                                  loadingBuilder: (c, child, p) => p == null ? child : Center(
                                      child: CircularProgressIndicator(
                                          value: p.expectedTotalBytes != null
                                              ? p.cumulativeBytesLoaded / p.expectedTotalBytes!
                                              : null
                                      )
                                  )
                              )
                          )
                      ),
                      if (product.isSold)
                        Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(12)
                                ),
                                child: const Text(
                                    'SOLD',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                                )
                            )
                        ),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                              onTap: () {
                                // 修復：檢查 toggleFavoriteStatus 方法是否存在
                                final productProvider = context.read<ProductProvider>();
                                if (productProvider.toggleFavoriteStatus != null) {
                                  productProvider.toggleFavoriteStatus!(product.id);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(product.isFavorite ? '已取消收藏' : '已加入收藏 ❤️'),
                                        duration: const Duration(seconds: 1)
                                    )
                                );
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      shape: BoxShape.circle
                                  ),
                                  child: Icon(
                                      product.isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: product.isFavorite ? Colors.redAccent : Colors.white,
                                      size: 18
                                  )
                              )
                          )
                      ),
                    ]
                )
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
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis
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
                                        color: Theme.of(context).primaryColor
                                    )
                                ),
                                if (product.originalPrice != null && product.originalPrice! > product.price)
                                  Text(
                                      _formatPrice(product.originalPrice!),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                          decoration: TextDecoration.lineThrough
                                      )
                                  ),
                              ]
                          ),
                        ]
                    )
                )
            ),
          ],
        ),
      ),
    );
  }
}

// --- 靜態的商品分類模型 ---
// 在真實應用中，這個也可能從後端獲取
class Category {
  final int id;
  final String name;
  final String icon;
  final int count;
  Category({required this.id, required this.name, required this.icon, required this.count});
}

final List<Category> _categories = [
  Category(id: 1, name: '書籍文具', icon: '📚', count: 156),
  Category(id: 2, name: '電子產品', icon: '📱', count: 89),
  Category(id: 3, name: '服裝配件', icon: '👕', count: 234),
  Category(id: 4, name: '家居用品', icon: '🏠', count: 178),
  Category(id: 5, name: '美容保健', icon: '💄', count: 67),
  Category(id: 6, name: '運動戶外', icon: '⚽', count: 123),
];