import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/product/product.dart';
import '../providers/cart_provider.dart';
import 'user/public_profile.dart';
import 'user/cart.dart';
import '../widgets/FullBottomConcaveAppBarShape.dart';
import '../theme/app_theme.dart';

void _navigateToSellerProfile(BuildContext context, SellerInfo seller) {
  final sellerId = seller.id;
  if (sellerId != 0) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublicUserProfilePage(userId: sellerId.toString()),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('無法獲取賣家資訊，請稍後再試')),
    );
  }
}

class ProductScreen extends StatefulWidget {
  /// ✅ 改為 int，與全站一致
  final int productId;

  /// 可帶初始 Product，提升體驗
  final Product? initialProduct;

  const ProductScreen({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isLiked = false;

  String _fmt(double v) => NumberFormat.currency(locale: 'zh_TW', symbol: 'NT\$', decimalDigits: 0).format(v);

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      _product = widget.initialProduct!;
      _isLoading = false;
    } else {
      _isLoading = false;
      _errorMessage = '尚未串接單品 API；請從列表帶 initialProduct 進頁。';
    }
  }

  void _addToCart(BuildContext context, Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(product, 1);

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
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // 沒有資料時顯示錯誤頁
    if (_product == null && _errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('商品'),
          centerTitle: true,
          shape: FullBottomConcaveAppBarShape(curveHeight: 25.0),
          backgroundColor: primaryCS.primary,
          foregroundColor: primaryCS.onPrimary,
          elevation: 6,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: scheme.error),
                const SizedBox(height: 12),
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('知道了'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final product = _product!;
    final imageUrl = (product.imageUrls.isNotEmpty && product.imageUrls.first.isNotEmpty)
        ? product.imageUrls.first
        : 'https://via.placeholder.com/800x600/E0E0E0/000000?Text=No+Image';

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        centerTitle: true,
        shape: FullBottomConcaveAppBarShape(curveHeight: 25.0),
        backgroundColor: primaryCS.primary,
        foregroundColor: primaryCS.onPrimary,
        elevation: 6,
        actions: [
          IconButton(
            icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? Colors.redAccent : null),
            tooltip: '喜歡',
            onPressed: () {
              setState(() => _isLiked = !_isLiked);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isLiked ? '已加入喜歡' : '已取消喜歡')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: '購物車',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      body: Column(
        children: [
          if (_errorMessage != null)
            MaterialBanner(
              content: Text(_errorMessage!, style: const TextStyle(fontSize: 13)),
              backgroundColor: Colors.orange.withOpacity(0.12),
              actions: [
                TextButton(onPressed: () => setState(() => _errorMessage = null), child: const Text('知道了')),
              ],
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 圖片
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey),
                          ),
                        ),
                        loadingBuilder: (c, child, p) {
                          if (p == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: p.expectedTotalBytes != null
                                  ? p.cumulativeBytesLoaded / p.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 名稱 + 價格
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _fmt(product.price),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      if (product.originalPrice != null && product.originalPrice! > product.price)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            _fmt(product.originalPrice!),
                            style: TextStyle(
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 賣家卡片
                  if (product.seller != null)
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () => _navigateToSellerProfile(context, product.seller!),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: (product.seller!.avatarUrl != null &&
                                    product.seller!.avatarUrl!.isNotEmpty)
                                    ? NetworkImage(product.seller!.avatarUrl!)
                                    : null,
                                child: (product.seller!.avatarUrl == null ||
                                    product.seller!.avatarUrl!.isEmpty)
                                    ? const Icon(Icons.person_outline, size: 20)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  product.seller!.username,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    const Text('暫無賣家資訊', style: TextStyle(color: Colors.grey)),

                  const SizedBox(height: 16),

                  // 資訊卡
                  Text('商品資訊',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(Icons.description_outlined, '描述:', product.description),
                          if (product.category.isNotEmpty)
                            _buildInfoRow(Icons.category_outlined, '分類:', product.category),
                          if (product.status.isNotEmpty)
                            _buildInfoRow(Icons.info_outline, '狀態:', product.status),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey[700]),
                                const SizedBox(width: 8),
                                const Text('庫存:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                const SizedBox(width: 4),
                                Text(
                                  product.stockQuantity > 0 ? product.stockQuantity.toString() : '售罄',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: product.stockQuantity > 0 ? Colors.green[700] : scheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 標籤
                  if (product.tags != null && product.tags!.isNotEmpty) ...[
                    Text('標籤',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: product.tags!
                          .map((t) => Chip(
                        label: Text(t),
                        visualDensity: VisualDensity.compact,
                      ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 加入購物車
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('加入購物車'),
                      onPressed: product.stockQuantity > 0 ? () => _addToCart(context, product) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: product.stockQuantity > 0 ? primaryCS.primary : Colors.grey,
                        foregroundColor: primaryCS.onPrimary,
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
