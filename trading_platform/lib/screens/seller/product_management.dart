// --- FILE: lib/screens/user/product_management.dart ---
import 'package:flutter/material.dart';

import '../../models/product/product.dart';
import '../../models/user/user.dart';
import './upload.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';

import 'package:first_flutter_project/mock/mock.dart';

class ProductManagementScreen extends StatefulWidget {
  final User currentUser;

  const ProductManagementScreen({super.key, required this.currentUser});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  List<Product> _sellerProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSellerProducts();
  }

  Future<void> _fetchSellerProducts() async {
    setState(() => _isLoading = true);

    try {
      // ✅ 改用統一的 mock 產生器（無延遲）
      _sellerProducts = buildMockProductsForUser(
        widget.currentUser.id.toString(),
        count: 8,
      );
    } catch (e) {
      debugPrint('載入模擬商品錯誤: $e');
      _sellerProducts = [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateAndUpsertProduct({Product? productToEdit}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductUploadPage(
          sellerId: widget.currentUser.id,
          productToEdit: productToEdit,
        ),
      ),
    );
    if (result == true) {
      _fetchSellerProducts();
    }
  }

  Future<void> _deleteProduct(BuildContext context, Product product) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('您確定要刪除商品「${product.name}」嗎？此操作無法撤銷。'),
        actions: <Widget>[
          TextButton(
            child: const Text('取消'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('刪除'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (confirmDelete == true && mounted) {
      setState(() {
        _sellerProducts.removeWhere((p) => p.id == product.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('商品「${product.name}」已刪除'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _toggleProductAvailability(BuildContext context, Product product) async {
    // sold_out 視為不可直接上下架
    if (product.status == 'sold_out') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('商品「${product.name}」已售罄，無法直接操作上下架，請先補貨。'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final bool isCurrentlyAvailable = product.status == 'available';
    final String actionText = isCurrentlyAvailable ? '下架' : '重新上架';
    final String newStatus = isCurrentlyAvailable ? 'unavailable' : 'available';

    if (!mounted) return;
    setState(() {
      final index = _sellerProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _sellerProducts[index] = _sellerProducts[index].copyWith(status: newStatus);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('商品「${product.name}」已$actionText'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        shape: FullBottomConcaveAppBarShape(curveHeight: 20.0),
        title: const Text('商品管理'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2.0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sellerProducts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('您還沒有上架任何商品', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('上架第一個商品'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => _navigateAndUpsertProduct(),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _sellerProducts.length,
        itemBuilder: (context, index) {
          final product = _sellerProducts[index];
          final isAvailable = product.status == 'available';
          final isSoldOut = product.status == 'sold_out';
          final isDelisted = product.status == 'unavailable';

          String displayStatus;
          Color statusColor;

          if (isSoldOut) {
            displayStatus = '已售罄';
            statusColor = Colors.redAccent;
          } else if (product.isSold) {
            displayStatus = '已售出';
            statusColor = Colors.orange[700]!;
          } else if (isAvailable) {
            displayStatus = '銷售中';
            statusColor = Colors.green;
          } else if (isDelisted) {
            displayStatus = '已下架';
            statusColor = Colors.grey[600]!;
          } else {
            displayStatus = product.status.isNotEmpty ? product.status : '未知狀態';
            statusColor = Colors.black54;
          }

          return Card(
            elevation: 3.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: ListTile(
              leading: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: product.imageUrls.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(product.imageUrls.first),
                    fit: BoxFit.cover,
                  )
                      : null,
                  color: product.imageUrls.isEmpty ? Colors.grey[200] : null,
                ),
                child: product.imageUrls.isEmpty
                    ? const Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 30)
                    : null,
              ),
              title: Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '價格: NT\$${product.price.toStringAsFixed(0)}',
                    style: TextStyle(color: theme.primaryColorDark, fontWeight: FontWeight.w500),
                  ),
                  Text('庫存: ${product.stockQuantity}'),
                  Text(
                    displayStatus,
                    style: TextStyle(color: statusColor, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isSoldOut)
                    IconButton(
                      icon: Icon(
                        isAvailable ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: isAvailable ? Colors.orangeAccent[700] : Colors.green[700],
                      ),
                      tooltip: isAvailable ? '下架商品' : '重新上架',
                      onPressed: () => _toggleProductAvailability(context, product),
                    ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: colorScheme.secondary),
                    tooltip: '編輯商品',
                    onPressed: () => _navigateAndUpsertProduct(productToEdit: product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: '刪除商品',
                    onPressed: () => _deleteProduct(context, product),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndUpsertProduct(),
        tooltip: '上架新商品',
        icon: const Icon(Icons.add_shopping_cart_outlined),
        label: const Text('上架商品'),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
    );
  }
}
