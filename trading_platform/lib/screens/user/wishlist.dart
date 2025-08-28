import 'package:first_flutter_project/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
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
    // 初始化時拉一次資料
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WishlistProvider>(context, listen: false).fetchWishlistItems();
    });
  }

  Future<void> _refreshWishlist(BuildContext context) async {
    await Provider.of<WishlistProvider>(context, listen: false)
        .fetchWishlistItems(forceRefresh: true);
  }

  void _showUndoSnackBar(BuildContext context, int productId, String productName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$productName 已從願望清單移除'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '撤銷',
          onPressed: () {
            Provider.of<WishlistProvider>(context, listen: false)
                .addToWishlist(productId);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final items = wishlistProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        centerTitle: true,
        shape: FullBottomConcaveAppBarShape(curveHeight: 25.0),
        backgroundColor: primaryCS.primary,
        foregroundColor: primaryCS.onPrimary,
      ),
      body: Builder(
        builder: (_) {
          if (wishlistProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (wishlistProvider.status == WishlistStatus.error) {
            return Center(
              child: Text(
                '載入失敗: ${wishlistProvider.errorMessage}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('您的願望清單是空的', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => _refreshWishlist(context),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: items.length,
              itemBuilder: (ctx, index) {
                final wishlistItem = items[index];
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
                        ),
                      )
                          : const Icon(Icons.image_not_supported,
                          size: 40, color: Colors.grey),
                    ),
                    title: Text(product.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      'NT\$ ${product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        wishlistProvider.removeFromWishlist(product.id);
                        _showUndoSnackBar(context, product.id, product.name);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
