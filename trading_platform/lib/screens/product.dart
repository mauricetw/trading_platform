// --- FILE: lib/screens/product.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- 核心依賴 ---
import '../models/product/product.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

// --- 頁面導航 ---
import 'user/public_profile.dart';
import 'user/cart.dart';

class ProductScreen extends StatefulWidget {
  final int productId;
  const ProductScreen({super.key, required this.productId});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ProductProvider>(context, listen: false).fetchProductById(widget.productId);
      }
    });
  }

  /// 處理加入購物車的邏輯
  void _addToCart(Product product) async {
    try {
      final cartProvider = context.read<CartProvider>();
      await cartProvider.addItem(product, 1);

      if (mounted) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('${product.name} 已加入購物車'),
            action: SnackBarAction(
              label: '查看購物車',
              onPressed: () {
                navigator.push(MaterialPageRoute(builder: (context) => const CartPage()));
              },
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加入失敗: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 處理收藏/取消收藏的邏輯
  void _toggleFavorite(Product product) async {
    try {
      final wishlistProvider = context.read<WishlistProvider>();
      final isCurrentlyInWishlist = wishlistProvider.isProductInWishlist(product);

      if (isCurrentlyInWishlist) {
        await wishlistProvider.removeFromWishlist(product.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.name} 已從收藏移除')),
          );
        }
      } else {
        await wishlistProvider.addToWishlist(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.name} 已加入收藏')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('操作失敗: $error'),
              backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  void _navigateToSellerProfile(int sellerId) {
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          // 修正：將 int 轉換為 String
          builder: (context) => PublicUserProfilePage(userId: sellerId.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<ProductProvider, WishlistProvider>(
        builder: (context, productProvider, wishlistProvider, child) {

          if (productProvider.isDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (productProvider.detailError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('發生錯誤: ${productProvider.detailError}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => productProvider.fetchProductById(widget.productId),
                    child: const Text('重試'),
                  )
                ],
              ),
            );
          }
          if (productProvider.selectedProduct == null) {
            return const Center(child: Text('找不到商品資料'));
          }

          final product = productProvider.selectedProduct!;
          final isFavorite = wishlistProvider.isProductInWishlist(product);

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(product, isFavorite),
              SliverToBoxAdapter(
                child: _buildProductDetails(context, product),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          final product = provider.selectedProduct;
          if (product == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('加入購物車'),
              onPressed: product.isSold ? null : () => _addToCart(product),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                backgroundColor: product.isSold ? Colors.grey : Theme.of(context).primaryColor,
              ),
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(Product product, bool isFavorite) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      floating: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
            product.name,
            style: const TextStyle(fontSize: 16.0, color: Colors.white, shadows: [Shadow(blurRadius: 2.0)])
        ),
        background: product.imageUrls.isNotEmpty
            ? Image.network(
          product.imageUrls.first,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(color: Colors.grey, child: const Icon(Icons.image_not_supported, size: 50)),
        )
            : Container(color: Colors.grey),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: () => _toggleFavorite(product),
        ),
      ],
    );
  }

  Widget _buildProductDetails(BuildContext context, Product product) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'NT\$ ${product.price.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),

          // 修正：根據 Product 模型顯示賣家資訊
          if (product.seller != null)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: product.seller!.avatarUrl != null && product.seller!.avatarUrl!.isNotEmpty
                      ? NetworkImage(product.seller!.avatarUrl!)
                      : null,
                  child: product.seller!.avatarUrl == null || product.seller!.avatarUrl!.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(product.seller!.username),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToSellerProfile(product.seller!.id),
              ),
            )
          else
          // 如果沒有 seller 資訊，顯示 sellerId
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text('賣家 ID: ${product.sellerId}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToSellerProfile(product.sellerId),
              ),
            ),
          const SizedBox(height: 20),

          Text('商品描述', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          // --- 關鍵修正：加入空值處理 ---
          // 使用 '??' 運算符，如果 description 是 null，就提供一個預設的空字串
          Text(product.description ?? '暫無商品描述', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),

          Text('庫存: ${product.stockQuantity}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text('狀態: ${_getStatusText(product.status)}', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available':
        return '販售中';
      case 'unavailable':
        return '已下架';
      case 'sold_out':
        return '已售罄';
      default:
        return '未知狀態';
    }
  }
}
