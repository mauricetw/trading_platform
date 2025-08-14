// --- FILE: lib/screens/product.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- 核心依賴 ---
import '../models/product/product.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart'; // 【【新增】】為了加入購物車功能
import '../providers/wishlist_provider.dart'; // 【【新增】】為了收藏功能

// --- 頁面導航 ---
import 'user/public_profile.dart'; // 賣家個人資料頁
import 'user/cart.dart';           // 購物車頁面

class ProductScreen extends StatefulWidget {
  // --- 來自你的版本：接收 productId，確保資料永遠是最新 ---
  final int productId;
  const ProductScreen({super.key, required this.productId});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {

  @override
  void initState() {
    super.initState();
    // --- 來自你的版本：讓頁面自己負責獲取資料 ---
    // 使用 addPostFrameCallback 確保 Provider 已經準備好
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 透過 Provider 從後端獲取最新的、完整的商品資料
      Provider.of<ProductProvider>(context, listen: false).fetchProductById(widget.productId);
    });
  }

  // --- 來自組員版本的功能，並與 Provider 整合 ---
  /// 處理加入購物車的邏輯
  void _addToCart(BuildContext context, Product product) {
    // 透過 context.read<T>() 取得 Provider 實例並呼叫其方法
    final cartProvider = context.read<CartProvider>();
    // 假設一次只加入一個
    cartProvider.addItem(product, 1).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} 已加入購物車'),
          action: SnackBarAction(
            label: '查看購物車',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
            },
          ),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加入失敗: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  /// 處理收藏/取消收藏的邏輯
  void _toggleFavorite(BuildContext context, Product product) {
    final wishlistProvider = context.read<WishlistProvider>();
    final isCurrentlyInWishlist = wishlistProvider.isProductInWishlist(product);

    if (isCurrentlyInWishlist) {
      wishlistProvider.removeFromWishlist(product.id).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} 已從收藏移除')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('移除失敗: $error'), backgroundColor: Colors.red),
        );
      });
    } else {
      wishlistProvider.addToWishlist(product).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} 已加入收藏')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('收藏失敗: $error'), backgroundColor: Colors.red),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 使用 Consumer 來根據 Provider 狀態建立 UI ---
      body: Consumer2<ProductProvider, WishlistProvider>( // 同時監聽兩個 Provider
        builder: (context, productProvider, wishlistProvider, child) {

          // --- 來自組員版本的狀態處理 UI ---
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

          // 如果成功獲取資料，則建立商品詳情 UI
          final product = productProvider.selectedProduct!;
          // 檢查當前商品是否在收藏清單中
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
      // --- 來自組員版本的底部按鈕邏輯 ---
      bottomNavigationBar: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          final product = provider.selectedProduct;
          if (product == null) return const SizedBox.shrink(); // 如果沒有商品，不顯示按鈕

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('加入購物車'),
              // 如果商品已售罄 (isSold getter)，禁用按鈕
              onPressed: product.isSold ? null : () => _addToCart(context, product),
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

  // --- UI 元件 (主要採用組員版本的美化設計) ---

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
          onPressed: () => _toggleFavorite(context, product),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PublicUserProfilePage(userId: product.seller!.id),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),

          Text('商品描述', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(product.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),

          Text('庫存: ${product.stockQuantity}', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
