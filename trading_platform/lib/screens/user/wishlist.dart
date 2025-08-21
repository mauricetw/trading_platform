import 'package:first_flutter_project/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../models/product/product.dart';
import '../../models/user/wishlist_item.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';

class WishlistScreen extends StatefulWidget {
  static const routeName = '/wishlist';

  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    // 進入頁面時，如果狀態是 initial 或 error，嘗試獲取最新的願望清單
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
      // 只有在用戶已登錄且數據尚未加載或加載出錯時才主動獲取
      if (wishlistProvider.status == WishlistStatus.initial ||
          (wishlistProvider.status == WishlistStatus.error && wishlistProvider.items.isEmpty)) {
        wishlistProvider.fetchWishlistItems();
      }
    });
  }

  Future<void> _refreshWishlist(BuildContext context) async {
    await Provider.of<WishlistProvider>(context, listen: false)
        .fetchWishlistItems(forceRefresh: true);
  }

  void _showUndoSnackBar(BuildContext context, Product product, WishlistItem removedItem) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} 已從願望清單移除'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '撤銷',
          onPressed: () {
            // 重新添加到願望清單
            Provider.of<WishlistProvider>(context, listen: false).addToWishlist(product);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    Widget content;

    switch (wishlistProvider.status) {
      case WishlistStatus.initial:
      case WishlistStatus.loading:
        content = const Center(child: CircularProgressIndicator());
        break;
      case WishlistStatus.error:
        content = Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 16),
                Text(
                  '加載願望清單失敗',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (wishlistProvider.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      wishlistProvider.errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('重試'),
                  onPressed: () => wishlistProvider.fetchWishlistItems(forceRefresh: true),
                ),
              ],
            ),
          ),
        );
        break;
      case WishlistStatus.empty:
        content = Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 24),
                Text(
                  '您的願望清單是空的',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  '去發現一些您喜歡的商品吧！',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  child: const Text('去逛逛'),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
        break;
      case WishlistStatus.loaded:
        final wishlistData = wishlistProvider.items;
        if (wishlistData.isEmpty) {
          content = Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  Text(
                    '您的願望清單是空的',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '去發現一些您喜歡的商品吧！',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    child: const Text('去逛逛'),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
          break;
        }
        content = RefreshIndicator(
          onRefresh: () => _refreshWishlist(context),
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: wishlistData.length,
            itemBuilder: (ctx, index) {
              final wishlistItem = wishlistData[index];
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
                    )
                        : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                      if (confirmed == true) {
                        // 保留快照以便撤銷
                        final removedItemSnapshot = wishlistItem;
                        final productSnapshot = product;

                        try {
                          // 使用 productId 移除
                          await wishlistProvider.removeFromWishlist(product.id);

                          if (mounted) {
                            _showUndoSnackBar(context, productSnapshot, removedItemSnapshot);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('移除 "${productSnapshot.name}" 失敗: ${wishlistProvider.errorMessage}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                  onTap: () {
                    // TODO: 導航到商品詳情頁面
                    debugPrint('Tapped on product: ${product.name}');
                  },
                ),
              );
            },
          ),
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        centerTitle: true,
        shape: FullBottomConcaveAppBarShape(curveHeight: 25.0),
        backgroundColor: primaryCS.primary,
        foregroundColor: primaryCS.onPrimary,
      ),
      body: content,
    );
  }
}