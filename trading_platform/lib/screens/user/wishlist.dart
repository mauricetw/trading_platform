// --- FILE: lib/screens/user/wishlist.dart ---
import 'package:first_flutter_project/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../models/product/product.dart';
import '../../models/user/wishlist_item.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';
import '../product.dart'; // 引入商品詳情頁

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    // --- 關鍵修正：簡化 initState 邏輯 ---
    // 確保 build 完成後再獲取資料
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 直接呼叫刷新方法。Provider 內部有防止重複載入的機制。
      _refreshWishlist(context);
    });
  }

  Future<void> _refreshWishlist(BuildContext context) async {
    // 呼叫 Provider 的方法，forceRefresh: true 確保下拉刷新時能強制更新
    await Provider.of<WishlistProvider>(context, listen: false)
        .fetchWishlistItems(forceRefresh: true);
  }

  // 保留組員設計的「撤銷」提示
  void _showUndoSnackBar(BuildContext context, Product product) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} 已從收藏移除'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '撤銷',
          onPressed: () {
            // REFACTORED: 呼叫 Provider 的 addToWishlist，並傳入 product 物件以立即更新 UI
            Provider.of<WishlistProvider>(context, listen: false).addToWishlist(product.id, product: product);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        centerTitle: true,
        shape: const FullBottomConcaveAppBarShape(curveHeight: 25.0),
        backgroundColor: primaryCS.primary,
        foregroundColor: primaryCS.onPrimary,
      ),
      // REFACTORED: 使用 Consumer 來監聽 Provider 的狀態
      body: Consumer<WishlistProvider>(
        builder: (context, provider, child) {
          return _buildContent(context, provider);
        },
      ),
    );
  }

  // REFACTORED: _buildContent 現在直接接收 Provider 實例
  Widget _buildContent(BuildContext context, WishlistProvider provider) {
    switch (provider.status) {
      case WishlistStatus.initial:
      case WishlistStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case WishlistStatus.error:
        return _buildErrorView(context, provider.errorMessage);
      case WishlistStatus.empty:
        return _buildEmptyView(context);
      case WishlistStatus.loaded:
        final wishlistItems = provider.items;
        return RefreshIndicator(
          onRefresh: () => _refreshWishlist(context),
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: wishlistItems.length,
            itemBuilder: (ctx, index) {
              final wishlistItem = wishlistItems[index];
              return _buildWishlistItemCard(context, wishlistItem, provider);
            },
          ),
        );
    }
  }

  // --- 以下 UI Builder Widgets 完整保留組員的設計 ---

  Widget _buildErrorView(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            Text('加載願望清單失敗', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(errorMessage, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('重試'),
              onPressed: () => _refreshWishlist(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text('您的收藏清單是空的', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text('去發現一些您喜歡的商品吧！', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton(
              child: const Text('去逛逛'),
              onPressed: () {
                // 返回主頁
                if (Navigator.canPop(context)) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistItemCard(BuildContext context, WishlistItem wishlistItem, WishlistProvider provider) {
    final product = wishlistItem.product;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      elevation: 2,
      child: ListTile(
        leading: SizedBox(
          width: 70,
          height: 70,
          child: product.imageUrls.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.network(
              product.imageUrls.first,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
            ),
          )
              : Container(
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4.0)),
            child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
          ),
        ),
        title: Text(product.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          'NT\$ ${product.price.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red[400]),
          tooltip: '從願望清單移除',
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext dialogContext) => AlertDialog(
                title: const Text('確認移除'),
                content: Text('您確定要從願望清單中移除 "${product.name}" 嗎？'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('取消'),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('移除'),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ],
              ),
            );
            if (confirmed == true && mounted) {
              try {
                // REFACTORED: 呼叫 Provider 移除商品
                await provider.removeFromWishlist(product.id);
                if (mounted) {
                  // 顯示可撤銷的提示
                  _showUndoSnackBar(context, product);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('移除失敗: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            }
          },
        ),
        onTap: () {
          // 導航到商品詳情頁面
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductScreen(productId: product.id)));
        },
      ),
    );
  }
}
