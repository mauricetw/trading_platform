// --- FILE: lib/screens/seller/product_management.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product/product.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import './upload.dart'; // 引入上架頁面

class ProductManagementScreen extends StatefulWidget {
  // REFACTORED: 不再需要傳入 currentUser，因為 Provider 會處理使用者狀態
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // REFACTORED: 確保 build 完成後再獲取資料，避免錯誤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 頁面初始化時，立即從後端獲取賣家的商品列表
      _refreshProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // REFACTORED: 抽離出刷新邏輯，方便下拉刷新和操作後刷新
  Future<void> _refreshProducts() async {
    // 使用 context.read 是因為我們只需要觸發一次，不需要監聽
    // 加上 try-catch 可以在獲取失敗時顯示錯誤訊息
    try {
      await context.read<ProductProvider>().fetchSellerProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('無法載入商品: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // REFACTORED: 導航邏輯現在會等待返回結果，並在需要時觸發刷新
  Future<void> _navigateAndUpsertProduct({Product? productToEdit}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductUploadPage(
          productToEdit: productToEdit,
        ),
      ),
    );
    // 如果從上傳/編輯頁面返回的結果是 true，表示有變更，需要刷新列表
    if (result == true && mounted) {
      _refreshProducts();
    }
  }

  // REFACTORED: 刪除邏輯現在呼叫 Provider
  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: Text('確定要刪除商品「${product.name}」嗎？\n此操作無法撤銷。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // 先關閉對話框
                try {
                  await context.read<ProductProvider>().deleteProduct(product.id);
                  if(mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name} 已刪除'), backgroundColor: Colors.green),
                    );
                  }
                } catch(e) {
                  if(mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('刪除失敗: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('刪除'),
            ),
          ],
        );
      },
    );
  }

  // REFACTORED: 切換狀態的邏輯也應透過 Provider 處理 (待新增)
  void _toggleProductStatus(Product product) {
    // TODO: 在 ProductProvider 中新增一個 updateProductStatus 的方法，
    // 並在這裡呼叫它，以更新後端資料庫中的商品狀態。
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          product.status == "available"
              ? '${product.name} 已下架 (功能待實現)'
              : '${product.name} 已重新上架 (功能待實現)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        // REFACTORED: 動態計算不同狀態的商品列表
        final allProducts = provider.sellerProducts;
        final activeProducts = allProducts.where((p) => p.status == "available").toList();
        final soldProducts = allProducts.where((p) => p.status != "available").toList(); // 假設非 available 即為已售出/下架

        // --- 關鍵修正：已移除 `_tabController.index = DefaultTabController.of(context).index;` ---

        return Scaffold(
          backgroundColor: primaryCS.surfaceContainerHighest,
          appBar: AppBar(
            title: const Text('商品管理'),
            backgroundColor: primaryCS.primary,
            foregroundColor: primaryCS.onPrimary,
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              labelColor: primaryCS.onPrimary,
              unselectedLabelColor: primaryCS.onPrimary.withOpacity(0.7),
              indicatorColor: primaryCS.secondary,
              tabs: [
                Tab(text: '全部 (${allProducts.length})'),
                Tab(text: '上架中 (${activeProducts.length})'),
                Tab(text: '已售出/下架 (${soldProducts.length})'),
              ],
            ),
            actions: [
              // REFACTORED: AppBar 上的 "+" 按鈕現在可以正常導航
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: "上架新商品",
                onPressed: () => _navigateAndUpsertProduct(),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: "重新整理",
                onPressed: _refreshProducts,
              ),
            ],
          ),
          body: provider.isSellerListLoading && allProducts.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
            controller: _tabController,
            children: [
              _buildProductList(allProducts),
              _buildProductList(activeProducts),
              _buildProductList(soldProducts),
            ],
          ),
        );
      },
    );
  }

  // --- 以下 UI Builder Widgets 保持您組員的設計 ---

  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暫無商品', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final isActive = product.status == "available";

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showProductOptions(product),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80, height: 80, color: Colors.grey[200],
                  child: product.imageUrls.isNotEmpty
                      ? Image.network(
                    product.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 32, color: Colors.grey[400]),
                  )
                      : Icon(Icons.image, size: 32, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: isActive ? Colors.green : Colors.grey, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            isActive ? '上架中' : '已售完/下架',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (product.description.isNotEmpty)
                      Text(
                        product.description,
                        style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'NT\$ ${product.price.toStringAsFixed(0)}',
                          style: textTheme.titleSmall?.copyWith(color: primaryCS.primary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        if (product.originalPrice != null && product.originalPrice! > product.price)
                          Text(
                            'NT\$ ${product.originalPrice!.toStringAsFixed(0)}',
                            style: textTheme.bodySmall?.copyWith(color: Colors.grey, decoration: TextDecoration.lineThrough),
                          ),
                        const Spacer(),
                        if (isActive)
                          Text('庫存: ${product.stockQuantity}', style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]))
                        else
                          Text('已售: ${product.salesCount}', style: textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductOptions(Product product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildOptionTile(
                icon: Icons.edit,
                title: '編輯商品',
                onTap: () {
                  Navigator.pop(context);
                  _navigateAndUpsertProduct(productToEdit: product);
                },
              ),
              _buildOptionTile(
                icon: product.status == "available" ? Icons.pause_circle_outline : Icons.play_circle_outline,
                title: product.status == "available" ? '下架商品' : '重新上架',
                onTap: () {
                  Navigator.pop(context);
                  _toggleProductStatus(product);
                },
              ),
              _buildOptionTile(
                icon: Icons.delete_outline,
                title: '刪除商品',
                textColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(product);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({ required IconData icon, required String title, required VoidCallback onTap, Color? textColor }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Theme.of(context).colorScheme.primary),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

