// --- FILE: lib/screens/home_page.dart ---
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product/product.dart';
import '../models/product/category.dart'; // 1. 引入真實的 Category 模型
import '../providers/product_provider.dart';
import '../providers/wishlist_provider.dart'; // 2. 引入 WishlistProvider
import 'product.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. 使用 Consumer 來同時監聽兩個 Provider
    return Consumer2<ProductProvider, WishlistProvider>(
      builder: (context, productProvider, wishlistProvider, child) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              // 下拉刷新時，同時更新商品和收藏列表
              await productProvider.fetchProducts();
              await wishlistProvider.fetchWishlistItems();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('商品分類'),
                  const SizedBox(height: 16),
                  // 4. 分類網格現在會自動從 Provider 獲取狀態
                  const _CategoriesGrid(),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    // 5. 根據 Provider 的狀態動態獲取分類名稱
                    productProvider.selectedCategoryId == null
                        ? '熱門商品'
                        : _getCategoryName(productProvider),
                  ),
                  const SizedBox(height: 16),
                  _buildProductContent(context, productProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ( _buildProductContent 和 _buildSectionTitle 保持不變 )
  Widget _buildProductContent(BuildContext context, ProductProvider provider) {
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

  // 6. 輔助函式現在從 Provider 中查找分類名稱
  String _getCategoryName(ProductProvider provider) {
    try {
      return provider.categories.firstWhere((c) => c.id == provider.selectedCategoryId).name;
    } catch (e) {
      return "未知分類";
    }
  }
}

// --- 分類網格 (已修正為使用 Provider) ---
class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid();
  @override
  Widget build(BuildContext context) {
    // 7. 直接從 Provider 獲取分類列表和選中狀態
    final productProvider = context.watch<ProductProvider>();
    final categories = productProvider.categories;
    final selectedId = productProvider.selectedCategoryId;

    if (productProvider.areCategoriesLoading && categories.isEmpty) {
      return const Center(child: Text('正在載入分類...'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.0,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        bool isSelected = selectedId == category.id;
        // 8. 傳遞真實的 Category 物件給 UI builder
        return _buildCategoryCard(context, category, isSelected, () {
          context.read<ProductProvider>().filterByCategory(category.id);
        });
      },
    );
  }

  // UI Builder 現在接收真實的 Category 物件
  Widget _buildCategoryCard(BuildContext context, Category category, bool isSelected, VoidCallback onTap) {
    // ... (UI 邏輯保持不變，但現在 count 和 icon 都是模擬的)
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
            Container(width: 45, height: 45, decoration: BoxDecoration(gradient: LinearGradient(colors: isSelected ? [Theme.of(context).primaryColor, Theme.of(context).primaryColorDark] : [const Color(0xFF1E88E5), const Color(0xFF1565C0)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(22.5)), child: Center(child: Text('🛍️', style: const TextStyle(fontSize: 22)))), // 使用通用圖示
            const SizedBox(height: 8),
            Text(category.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 12, color: isSelected ? Theme.of(context).primaryColor : Colors.black87), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            // const SizedBox(height: 4),
            // Text('${category.count} 件', style: TextStyle(fontSize: 10, color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.8) : Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

// --- 商品網格 (保持不變) ---
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

// --- 商品卡片 (已修正為使用 WishlistProvider) ---
class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  String _formatPrice(double price) {
    return NumberFormat.currency(locale: "zh_TW", symbol: "NT\$", decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    // 9. 使用 Consumer 來監聽 WishlistProvider 的狀態
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        // 10. 根據 WishlistProvider 判斷商品是否已被收藏
        final isFavorite = wishlistProvider.isFavorite(product.id);

        String imageUrlToDisplay = product.imageUrls.isNotEmpty ? product.imageUrls.first : 'https://via.placeholder.com/300x250';

        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductScreen(productId: product.id))),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: Stack(alignment: Alignment.topRight, children: [
                  Container(width: double.infinity, height: double.infinity, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.network(imageUrlToDisplay, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey[400])))))),
                  if (product.isSold) Positioned(top: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.9), borderRadius: BorderRadius.circular(12)), child: const Text('SOLD', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                  Padding(padding: const EdgeInsets.all(8.0), child: GestureDetector(
                    // 11. 點擊愛心時，呼叫 WishlistProvider 的方法
                      onTap: () {
                        if (isFavorite) {
                          wishlistProvider.removeFromWishlist(product.id);
                        } else {
                          wishlistProvider.addToWishlist(product.id);
                        }
                      },
                      child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                          // 12. 根據 isFavorite 狀態顯示不同的圖示和顏色
                          child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.redAccent : Colors.white, size: 18)
                      )
                  )),
                ])),
                Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(10.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text(_formatPrice(product.price), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                    if (product.originalPrice != null && product.originalPrice! > product.price) Text(_formatPrice(product.originalPrice!), style: TextStyle(fontSize: 11, color: Colors.grey[600], decoration: TextDecoration.lineThrough)),
                  ]),
                ]))),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- 靜態的商品分類模型 (已被移除) ---
