// --- FILE: lib/screens/product.dart ---
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product/product.dart';
import '../providers/product_provider.dart';

class ProductScreen extends StatefulWidget {
  // --- 修正：接收 productId 而不是整個 Product 物件 ---
  final int productId;
  const ProductScreen({super.key, required this.productId});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    // --- 最佳實踐：讓頁面自己負責獲取資料 ---
    // 使用 addPostFrameCallback 確保 Provider 已經準備好
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProductById(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 使用 Consumer 來根據 Provider 狀態建立 UI ---
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
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
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(product.name, style: const TextStyle(fontSize: 16.0)),
                  background: product.imageUrls.isNotEmpty
                      ? Image.network(
                    product.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 50),
                  )
                      : Container(color: Colors.grey),
                ),
                actions: [
                  // TODO: 收藏和購物車按鈕
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
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
                      // ... 這裡放入你原本設計的商品資訊 UI ...
                      // 例如：賣家資訊、商品描述、庫存狀態等
                      if (product.seller != null)
                        Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: product.seller!.avatarUrl != null ? NetworkImage(product.seller!.avatarUrl!) : null,
                              child: product.seller!.avatarUrl == null ? const Icon(Icons.person) : null,
                            ),
                            title: Text(product.seller!.username),
                            subtitle: Text(product.seller!.schoolName ?? '學校未提供'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () { /* TODO: 導航到賣家頁面 */ },
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text('商品描述', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(product.description, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('加入購物車'),
          onPressed: () { /* TODO: 加入購物車邏輯 */ },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
