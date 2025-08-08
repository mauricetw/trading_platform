// --- FILE: lib/screens/seller/product_management.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product/product.dart';
import '../../providers/product_provider.dart';
import 'upload.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchSellerProducts();
    });
  }

  Future<void> _navigateAndUpsertProduct({Product? productToEdit}) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductUploadPage(productToEdit: productToEdit),
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context, Product product) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('您確定要刪除 "${product.name}" 嗎？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('刪除', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await Provider.of<ProductProvider>(context, listen: false).deleteProduct(product.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('商品 "${product.name}" 已刪除'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('刪除失敗: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的商品管理')),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isSellerListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.sellerListError != null) {
            return Center(child: Text('錯誤: ${provider.sellerListError}'));
          }
          if (provider.sellerProducts.isEmpty) {
            return const Center(child: Text('您還沒有上架任何商品'));
          }
          return ListView.builder(
            itemCount: provider.sellerProducts.length,
            itemBuilder: (context, index) {
              final product = provider.sellerProducts[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.image), // 佔位圖示
                  title: Text(product.name),
                  subtitle: Text('庫存: ${product.stockQuantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _navigateAndUpsertProduct(productToEdit: product)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteProduct(context, product)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndUpsertProduct(),
        label: const Text('上架商品'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
