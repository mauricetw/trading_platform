import 'package:flutter/material.dart';
import '../../models/product/product.dart';
import '../../models/user/user.dart';
import './upload.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';

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
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    // 根據你的 Product 模型創建模擬資料
    _sellerProducts = List.generate(
      5,
          (index) => Product(
        id: index + 1,
        name: '我的商品 ${index + 1}',
        description: '這是商品 ${index + 1} 的詳細描述。它非常棒，值得擁有！',
        price: (index + 1) * 199.99 + 50,
        originalPrice: (index + 1) * 299.99 + 100,
        categoryId: index + 1,
        category: index % 2 == 0 ? '電子產品' : '家居用品',
        stockQuantity: 10 + index * 5,
        status: index == 3 ? 'sold_out' : (index % 2 == 0 ? 'available' : 'unavailable'),
        imageUrls: [
          'https://picsum.photos/seed/${index + 1}/200/200',
          'https://picsum.photos/seed/a${index + 1}/200/200'
        ],
        createdAt: DateTime.now().subtract(Duration(days: index)),
        updatedAt: DateTime.now().subtract(Duration(hours: index)),
        sellerId: widget.currentUser.id,
        salesCount: index * 5,
        averageRating: index % 2 == 0 ? 4.5 - index * 0.1 : null,
        reviewCount: index * 3,
        tags: [
          index % 3 == 0 ? '全新' : (index % 3 == 1 ? '近全新' : '良好'),
          index % 2 == 0 ? '一般商品' : '限時特價',
        ],
        // 可選參數設為預設值
        seller: null,
        shippingInfo: null,
      ),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: Text('您確定要刪除商品 "${product.name}" 嗎？此操作無法撤銷。'),
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
        );
      },
    );

    if (confirmDelete == true) {
      debugPrint('API CALL: Deleting product ${product.id}');
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _sellerProducts.removeWhere((p) => p.id == product.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('商品 "${product.name}" 已刪除'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _toggleProductAvailability(BuildContext context, Product product) async {
    if (product.status == 'sold_out') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('商品 "${product.name}" 已售罄，無法直接操作上下架。請先補貨。'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final bool isCurrentlyAvailable = product.status == 'available';
    final String actionText = isCurrentlyAvailable ? '下架' : '重新上架';
    final String newStatus = isCurrentlyAvailable ? 'unavailable' : 'available';

    final bool? confirmToggle = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('確認$actionText'),
          content: Text('您確定要將商品 "${product.name}" $actionText嗎？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: isCurrentlyAvailable ? Colors.orange : Colors.green),
              child: Text(actionText),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmToggle == true) {
      debugPrint('API CALL: Setting product ${product.id} status to $newStatus');
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          final index = _sellerProducts.indexWhere((p) => p.id == product.id);
          if (index != -1) {
            _sellerProducts[index] = _sellerProducts[index].copyWith(status: newStatus);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('商品 "${product.name}" 已$actionText'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        shape: FullBottomConcaveAppBarShape(curveHeight: 20.0),
        title: const Text(''),
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
            Text(
              '您還沒有上架任何商品',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('上架第一個商品'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                _navigateAndUpsertProduct();
              },
            )
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _sellerProducts.length,
        itemBuilder: (context, index) {
          final product = _sellerProducts[index];
          bool isAvailable = product.status == 'available';
          bool isSoldOut = product.status == 'sold_out';
          bool isDelisted = product.status == 'unavailable';

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
                    ? Icon(Icons.inventory_2_outlined, color: Colors.grey[400], size: 30,)
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
                    style: TextStyle(
                        color: statusColor,
                        fontStyle: FontStyle.italic),
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
                      onPressed: () {
                        _toggleProductAvailability(context, product);
                      },
                    ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: colorScheme.secondary),
                    tooltip: '編輯商品',
                    onPressed: () {
                      _navigateAndUpsertProduct(productToEdit: product);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.redAccent[700]),
                    tooltip: '刪除商品',
                    onPressed: () {
                      _deleteProduct(context, product);
                    },
                  ),
                ],
              ),
              onTap: () {
                if (!isDelisted) {
                  _navigateAndUpsertProduct(productToEdit: product);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('商品 "${product.name}" 已下架，如需編輯請先重新上架。'),
                        backgroundColor: Colors.blueGrey,
                      ),
                    );
                  }
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigateAndUpsertProduct();
        },
        tooltip: '上架新商品',
        icon: const Icon(Icons.add_shopping_cart_outlined),
        label: const Text('上架商品'),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
    );
  }
}