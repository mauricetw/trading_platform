// --- FILE: lib/screens/user/cart.dart ---
// 完整替換本檔

import 'package:first_flutter_project/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../models/user/cart_item.dart';
import '../../models/product/product.dart';
import 'checkout.dart';
import '../product.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    // 首次進入頁面時，如果購物車是空的，嘗試載入（由 Provider 負責：可連真實 API 或 mock）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      if (cartProvider.items.isEmpty && !cartProvider.isLoading) {
        debugPrint("CartPage: empty on init -> fetchUserCart()");
        cartProvider.fetchUserCart().catchError((error) {
          debugPrint("CartPage: fetchUserCart error (silently): $error");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final List<CartItem> cartItemsList = cartProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('購物車'),
        backgroundColor: primaryCS.primary,
        foregroundColor: primaryCS.onPrimary,
        actions: [
          if (cartItemsList.isNotEmpty && !cartProvider.isLoading)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: '清空購物車',
              onPressed: () => _confirmClearCart(context, cartProvider),
            ),
        ],
      ),
      body: _buildBody(context, cartProvider, cartItemsList),
      bottomNavigationBar: cartItemsList.isNotEmpty && !cartProvider.isLoading
          ? _buildBottomAppBar(context, cartProvider)
          : null,
    );
  }

  void _confirmClearCart(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('確認操作'),
        content: const Text('您確定要清空購物車所有商品嗎？'),
        actions: <Widget>[
          TextButton(
            child: const Text('取消'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('確定清空', style: TextStyle(color: Colors.red)),
            onPressed: () {
              cartProvider.clearCart();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('購物車已清空')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, CartProvider cartProvider, List<CartItem> cartItemsList) {
    if (cartProvider.isLoading && cartItemsList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cartProvider.error != null && cartItemsList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('載入購物車失敗: ${cartProvider.error}', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('重試'),
                onPressed: () {
                  cartProvider.fetchUserCart();
                },
              )
            ],
          ),
        ),
      );
    }

    if (cartItemsList.isEmpty && !cartProvider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('您的購物車是空的！', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('去逛逛'),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('正在前往商品頁... (請替換為實際導航)')),
                );
              },
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => cartProvider.fetchUserCart(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: cartItemsList.length,
        itemBuilder: (context, index) {
          final item = cartItemsList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                // 導向最新 Product 詳情（用 id int）
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductScreen(productId: item.productId),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: item.isSelected,
                      onChanged: (bool? value) {
                        if (value != null) {
                          cartProvider.toggleItemSelected(item.productId, value);
                        }
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    // 商品圖片
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: (item.product.imageUrls.isNotEmpty &&
                            item.product.imageUrls.first.isNotEmpty)
                            ? Image.network(
                          item.product.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
                          ),
                        )
                            : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 商品文字與操作
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '價格: NT\$${item.product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 數量控制
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              _buildQuantityButton(
                                context,
                                icon: Icons.remove_circle_outline,
                                onPressed: item.quantity > 1
                                    ? () => cartProvider.decrementQuantity(item.productId)
                                    : () => _confirmRemoveItem(
                                  context,
                                  cartProvider,
                                  item,
                                  "確認移除",
                                  "數量減至 0 將移除商品，確定嗎？",
                                ),
                                tooltip: item.quantity > 1 ? '減少數量' : '移除商品',
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              _buildQuantityButton(
                                context,
                                icon: Icons.add_circle_outline,
                                onPressed: () => cartProvider.incrementQuantity(item.productId),
                                tooltip: '增加數量',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 獨立的移除按鈕
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.redAccent[400], size: 24),
                      tooltip: '移除商品',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _confirmRemoveItem(context, cartProvider, item),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuantityButton(
      BuildContext context, {
        required IconData icon,
        required VoidCallback onPressed,
        required String tooltip,
      }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  void _confirmRemoveItem(
      BuildContext context,
      CartProvider cartProvider,
      CartItem item, [
        String title = '移除商品',
        String? content,
      ]) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content ?? '您確定要從購物車移除「${item.product.name}」嗎？'),
        actions: <Widget>[
          TextButton(
            child: const Text('取消'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('確定移除', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(ctx).pop();
              cartProvider.removeItem(item.productId);

              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已移除「${item.product.name}」'),
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: '撤銷',
                    textColor: Theme.of(context).colorScheme.surface,
                    onPressed: () {
                      final int originalQuantity = item.quantity;
                      final bool originalIsSelected = item.isSelected;

                      // 依照最新 Product 模型重建一個 Product（避免參照被移除後出錯）
                      final restored = Product(
                        id: item.product.id,
                        name: item.product.name,
                        description: item.product.description,
                        price: item.product.price,
                        originalPrice: item.product.originalPrice,
                        categoryId: item.product.categoryId,
                        category: item.product.category,
                        stockQuantity: item.product.stockQuantity,
                        status: item.product.status,
                        imageUrls: List<String>.from(item.product.imageUrls),
                        createdAt: item.product.createdAt,
                        updatedAt: item.product.updatedAt,
                        salesCount: item.product.salesCount,
                        averageRating: item.product.averageRating,
                        reviewCount: item.product.reviewCount,
                        tags: item.product.tags == null
                            ? null
                            : List<String>.from(item.product.tags!),
                        sellerId: item.product.sellerId,
                        seller: item.product.seller, // SellerInfo? 可直接帶回
                        shippingInfo: item.product.shippingInfo,
                        isFavorite: item.product.isFavorite,
                      );

                      // 重新加入購物車
                      cartProvider.addItem(restored, originalQuantity);

                      // 回復選取狀態
                      if (originalIsSelected) {
                        cartProvider.toggleItemSelected(item.productId, true);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已撤銷移除「${item.product.name}」')),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAppBar(BuildContext context, CartProvider cartProvider) {
    final themeColors = Theme.of(context).colorScheme;

    return BottomAppBar(
      elevation: 8,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // 全選
            InkWell(
              onTap: () {
                final newValue = !cartProvider.isAllSelected;
                cartProvider.toggleSelectAll(newValue);
              },
              child: Row(
                children: [
                  Checkbox(
                    value: cartProvider.isAllSelected,
                    onChanged: (bool? value) {
                      if (value != null) {
                        cartProvider.toggleSelectAll(value);
                      }
                    },
                    activeColor: themeColors.primary,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                  const Text('全選', style: TextStyle(fontSize: 15)),
                ],
              ),
            ),

            // 合計
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '合計 (已選 ${cartProvider.selectedItemCount} 件):',
                      style: TextStyle(fontSize: 12, color: themeColors.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'NT\$${cartProvider.totalSelectedAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: themeColors.primary,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 結算
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cartProvider.selectedItemCount > 0 ? themeColors.primary : Colors.grey[400],
                foregroundColor: cartProvider.selectedItemCount > 0 ? themeColors.onPrimary : Colors.grey[700],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: cartProvider.selectedItemCount > 0
                  ? () {
                final selectedItemsToCheckout =
                cartProvider.items.where((item) => item.isSelected).toList();
                if (selectedItemsToCheckout.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('請至少選擇一件商品進行結算')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckoutScreen(),
                  ),
                );
              }
                  : null,
              child: Text('結算 (${cartProvider.selectedItemCount})'),
            ),
          ],
        ),
      ),
    );
  }
}
