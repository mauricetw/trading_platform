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
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Scaffold(
          body: RefreshIndicator(
            // --- 修正：現在篩選也透過 fetchProducts ---
            onRefresh: () => productProvider.fetchProducts(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('商品分類'),
                  const SizedBox(height: 16),
                  const _CategoriesGrid(),
                  const SizedBox(height: 32),
                  _buildSectionTitle(productProvider.selectedCategoryId == null
                      ? '熱門商品'
                      : _getCategoryName(productProvider.selectedCategoryId!)),
                  const SizedBox(height: 16),
                  _buildProductContent(productProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductContent(ProductProvider provider) {
    if (provider.isListLoading && provider.products.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
    }
    if (provider.listError != null) {
      return Center(child: Text('發生錯誤: ${provider.listError}'));
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
    return _ProductsGrid(products: provider.products);
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  String _getCategoryName(int categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId).name;
    } catch (e) {
      return "未知分類";
    }
  }
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid();
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
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
          productProvider.filterByCategory(category.id);
        });
      },
    );
  }
  // _buildCategoryCard 保持不變...
  Widget _buildCategoryCard(BuildContext context, Category category, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 1.5) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 45, height: 45, decoration: BoxDecoration(gradient: LinearGradient(colors: isSelected ? [Theme.of(context).primaryColor, Theme.of(context).primaryColorDark] : [const Color(0xFF1E88E5), const Color(0xFF1565C0)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(22.5)), child: Center(child: Text(category.icon, style: const TextStyle(fontSize: 22)))),
            const SizedBox(height: 8),
            Text(category.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 12, color: isSelected ? Theme.of(context).primaryColor : Colors.black87), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('${category.count} 件', style: TextStyle(fontSize: 10, color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.8) : Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

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
      // --- 關鍵修正 ---
      // 舊的寫法: Navigator.push(context, MaterialPageRoute(builder: (context) => ProductScreen(product: product))),
      // 新的寫法: 我們只傳遞 product.id，讓 ProductScreen 自己去獲取最新的、完整的商品資料。
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductScreen(productId: product.id),
        ),
      ),
      child: Container(
        // ... 你的商品卡片 UI 佈局 (完全保持不變) ...
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: Stack(alignment: Alignment.topRight, children: [
              Container(width: double.infinity, height: double.infinity, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.network(imageUrlToDisplay, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey[400]))), loadingBuilder: (c, child, p) => p == null ? child : Center(child: CircularProgressIndicator(value: p.expectedTotalBytes != null ? p.cumulativeBytesLoaded / p.expectedTotalBytes! : null))))),
              if (product.isSold) Positioned(top: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.9), borderRadius: BorderRadius.circular(12)), child: const Text('SOLD', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
              Padding(padding: const EdgeInsets.all(8.0), child: GestureDetector(onTap: () {
                Provider.of<ProductProvider>(context, listen: false).toggleFavoriteStatus(product.id);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(product.isFavorite ? '已取消收藏' : '已加入收藏 ❤️'), duration: const Duration(seconds: 1)));
              }, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle), child: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border, color: product.isFavorite ? Colors.redAccent : Colors.white, size: 18)))),
            ])),
            Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(10.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(NumberFormat.currency(locale: "zh_TW", symbol: "NT\$", decimalDigits: 0).format(product.price), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                if (product.originalPrice != null && product.originalPrice! > product.price) Text(NumberFormat.currency(locale: "zh_TW", symbol: "NT\$", decimalDigits: 0).format(product.originalPrice!), style: TextStyle(fontSize: 11, color: Colors.grey[600], decoration: TextDecoration.lineThrough)),
              ]),
            ]))),
          ],
        ),
      ),
    );
  }
}

class Category {
  final int id; final String name; final String icon; final int count;
  Category({required this.id, required this.name, required this.icon, required this.count});
}
final List<Category> _categories = [
  Category(id: 1, name: '書籍文具', icon: '📚', count: 156), Category(id: 2, name: '電子產品', icon: '📱', count: 89), Category(id: 3, name: '服裝配件', icon: '👕', count: 234), Category(id: 4, name: '家居用品', icon: '🏠', count: 178), Category(id: 5, name: '美容保健', icon: '💄', count: 67), Category(id: 6, name: '運動戶外', icon: '⚽', count: 123),
];