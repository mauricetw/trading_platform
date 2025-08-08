// --- FILE: lib/screens/product.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product/product.dart';
import '../providers/product_provider.dart';

class ProductScreen extends StatefulWidget {
  // 接收 productId 而不是整個 Product 物件
  final int productId;
  const ProductScreen({super.key, required this.productId});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    // 讓頁面自己負責獲取最新的、完整的商品資料
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProductById(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          // 根據 Provider 的狀態顯示 UI
          if (provider.isDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.detailError != null) {
            return Center(child: Text('發生錯誤: ${provider.detailError}'));
          }
          if (provider.selectedProduct == null) {
            return const Center(child: Text('找不到商品資料'));
          }

          // 如果成功獲取資料，則建立商品詳情 UI
          final product = provider.selectedProduct!;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(product),
              SliverToBoxAdapter(
                child: _buildProductDetails(context, product),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // 抽離出 SliverAppBar
  SliverAppBar _buildSliverAppBar(Product product) {
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
          icon: const Icon(Icons.favorite_border),
          onPressed: () { /* TODO: 收藏邏輯 */ },
        ),
      ],
    );
  }

  // 抽離出商品詳情內容
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

          // --- 賣家資訊卡片 (使用 SellerInfo) ---
          if (product.seller != null)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: product.seller!.avatarUrl != null
                      ? NetworkImage(product.seller!.avatarUrl!)
                      : null,
                  child: product.seller!.avatarUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(product.seller!.username),
                // --- 修正：SellerInfo 中沒有 schoolName，所以不再顯示 ---
                // subtitle: Text(product.seller!.schoolName ?? '學校未提供'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () { /* TODO: 導航到賣家頁面 */ },
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

  // 抽離出底部按鈕
  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('加入購物車'),
        onPressed: () { /* TODO: 加入購物車邏輯 */ },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}