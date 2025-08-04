import 'package:flutter/material.dart';
import '../models/product/product.dart';
import '../models/user/user.dart';
import 'user/public_profile.dart';
import 'cart.dart';


void navigateToSellerProfile(BuildContext context, User seller) {
  // 確保 seller 對象和 seller.id 是有效的
  if (seller.id.isNotEmpty) { // 通常 id 不會是空的，但檢查一下更安全
    print('Navigating to seller profile: ${seller.id} - ${seller.username}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublicUserProfilePage(userId: seller.id),
      ),
    );
  } else {
    print('Error: Seller ID is empty, cannot navigate.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('無法獲取賣家資訊，請稍後再試')),
    );
  }
}

class ProductScreen extends StatefulWidget {
  final Product product;

  const ProductScreen({super.key, required this.product});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : null,
            ),
            tooltip: '喜歡',
            onPressed: () {
              setState(() {
                _isLiked = !_isLiked;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isLiked ? '${product.name} 已加入喜歡' : '${product.name} 已取消喜歡')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: '購物車',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>CartPage()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('購物車按鈕點擊')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- 商品主圖 ---
            if (product.imageUrls.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    product.imageUrls.first,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // --- 商品名稱 ---
            Text(
              product.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // --- 賣家資訊 ---
            if (product.seller != null)
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  onTap: () => navigateToSellerProfile(context, product.seller!),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: product.seller!.avatarUrl != null && product.seller!.avatarUrl!.isNotEmpty
                              ? NetworkImage(product.seller!.avatarUrl!)
                              : null,
                          child: product.seller!.avatarUrl == null || product.seller!.avatarUrl!.isEmpty
                              ? const Icon(Icons.person, size: 20)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text( // 只顯示賣家名稱
                            product.seller!.username,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        // 移除了顯示評分的 Column
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // --- 商品價格 ---
            Text(
              'NT\$ ${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // --- 商品資訊 (簡化區塊) ---
            Text(
              '商品資訊',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSimplifiedInfoRow(Icons.description_outlined, '描述:', product.description),
                    if (product.category.isNotEmpty)
                      _buildSimplifiedInfoRow(Icons.category_outlined, '分類:', product.category),
                    if (product.status.isNotEmpty)
                      _buildSimplifiedInfoRow(Icons.info_outline, '狀態:', product.status),
                    Text(
                      '庫存: ${product.stockQuantity > 0 ? product.stockQuantity.toString() : "售罄"}',
                      style: TextStyle(
                        fontSize: 14,
                        color: product.stockQuantity > 0 ? Colors.green.shade700 : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- 加入購物車按鈕 ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('加入購物車'),
                onPressed: product.stockQuantity > 0 ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} 已加入購物車')),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSimplifiedInfoRow(IconData icon, String title, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}