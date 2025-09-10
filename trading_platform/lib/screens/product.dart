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
    if (mounted && sellerId > 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
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
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '載入失敗',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      productProvider.detailError!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => productProvider.fetchProductById(widget.productId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('重試'),
                  )
                ],
              ),
            );
          }

          if (productProvider.selectedProduct == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '找不到商品資料',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('返回'),
                  )
                ],
              ),
            );
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

          return Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(product.isSold ? '已售完' : '加入購物車'),
                onPressed: product.isSold ? null : () => _addToCart(product),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  backgroundColor: product.isSold
                      ? Colors.grey[300]
                      : Theme.of(context).primaryColor,
                  foregroundColor: product.isSold
                      ? Colors.grey[600]
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            product.name,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (product.imageUrls.isNotEmpty)
              Image.network(
                product.imageUrls.first,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('圖片載入失敗', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              )
            else
              Container(
                color: Colors.grey[300],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('暫無圖片', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            // 漸層遮罩
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.white,
            size: 28,
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
          // 價格區域
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NT\$ ${product.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    if (product.originalPrice != null && product.originalPrice! > product.price)
                      Text(
                        'NT\$ ${product.originalPrice!.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(product.status),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getStatusText(product.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 賣家資訊
          _buildSellerCard(product),
          const SizedBox(height: 24),

          // 商品資訊
          _buildProductInfo(context, product),
          const SizedBox(height: 24),

          // 商品描述
          _buildDescription(context, product),

          // 底部留白，避免被底部按鈕遮擋
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSellerCard(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          backgroundImage: (product.seller?.avatarUrl?.isNotEmpty == true)
              ? NetworkImage(product.seller!.avatarUrl!)
              : null,
          child: (product.seller?.avatarUrl?.isEmpty != false)
              ? const Icon(Icons.person, size: 24)
              : null,
        ),
        title: Text(
          product.seller?.username ?? '賣家 ID: ${product.sellerId}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('銷售 ${product.salesCount} 件商品'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateToSellerProfile(product.sellerId),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('商品資訊', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildInfoRow('分類', product.category),
              const Divider(height: 16),
              _buildInfoRow('庫存', '${product.stockQuantity} 件'),
              const Divider(height: 16),
              _buildInfoRow('銷售數量', '${product.salesCount} 件'),
              if (product.averageRating != null) ...[
                const Divider(height: 16),
                _buildInfoRow('評價', '${product.averageRating!.toStringAsFixed(1)} ⭐ (${product.reviewCount} 則評價)'),
              ],
              if (product.tags?.isNotEmpty == true) ...[
                const Divider(height: 16),
                _buildTagsRow('標籤', product.tags!),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsRow(String label, List<String> tags) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('商品描述', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            product.description.isNotEmpty ? product.description : '暫無商品描述',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: product.description.isNotEmpty ? null : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'unavailable':
        return Colors.orange;
      case 'sold_out':
        return Colors.red;
      default:
        return Colors.grey;
    }
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