import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 【【新增】】為了演示加入購物車
import '../models/product/product.dart';
import '../models/user/user.dart';
import '../providers/cart_provider.dart'; // 【【新增】】為了演示加入購物車
import '../services/product_service.dart'; // 【【新增】】導入您的 ProductService
import 'user/public_profile.dart';
import 'user/cart.dart'; // 保持對 CartPage 的引用，如果需要

// navigateToSellerProfile 函數保持不變
void navigateToSellerProfile(BuildContext context, User seller) {
  if (seller.id.isNotEmpty) {
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
  final String productId; // 【【修改】】接收 productId 而不是 Product 對象

  const ProductScreen({super.key, required this.productId});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // 【【新增】】狀態變量用於異步加載
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isLiked = false; // "喜歡"的狀態可以保留為本地 UI 狀態

  // 【【新增】】ProductService 實例 (在實際應用中，您可能會通過 Provider 或 get_it 注入)
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedProduct = await _productService.getProductById(widget.productId);
      if (mounted) { // 檢查 widget 是否仍然在 widget 樹中
        setState(() {
          _product = fetchedProduct;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        print("Error fetching product: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加載商品失敗: $e')),
        );
      }
    }
  }

  // 【【新增】】加入購物車的邏輯 (使用 Provider)
  void _addToCart(BuildContext context, Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    // 假設加入購物車的邏輯是添加一個單位
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('正在加載商品...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('加載錯誤')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage ?? '無法加載商品詳細信息。',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchProductDetails, // 提供重試按鈕
                  child: const Text('重試'),
                )
              ],
            ),
          ),
        ),
      );
    }

    // 現在 _product 一定不為 null
    final Product product = _product!;

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
              // TODO: 將 "喜歡" 狀態同步到後端或 Provider
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
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
                    product.imageUrls.first, // 也可以製作一個圖片輪播組件
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 250,
                        color: Colors.grey[200],
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
                        height: 250,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey)),
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
            // 【【注意】】如果您的 Product 模型從後端獲取時包含 seller 信息
            if (product.seller != null)
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  onTap: () => navigateToSellerProfile(context, product.seller!),
                  borderRadius: BorderRadius.circular(8),
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
                              ? const Icon(Icons.person_outline, size: 20)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            product.seller!.username,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              )
            else
              const Padding( // 如果沒有賣家信息
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("暫無賣家資訊", style: TextStyle(color: Colors.grey)),
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
                    Padding( // 庫存信息單獨處理，以便更明顯地顯示顏色
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          const Text(
                            "庫存:",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.stockQuantity > 0 ? product.stockQuantity.toString() : "售罄",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: product.stockQuantity > 0 ? Colors.green.shade700 : Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
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
                onPressed: product.stockQuantity > 0
                    ? () => _addToCart(context, product) // 【【修改】】調用 _addToCart
                    : null, // 如果庫存為0，禁用按鈕
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // 可以根據商品狀態調整按鈕樣式
                  backgroundColor: product.stockQuantity > 0 ? Theme.of(context).primaryColor : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // _buildSimplifiedInfoRow 方法保持不變
  Widget _buildSimplifiedInfoRow(IconData icon, String title, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink(); // 如果值為空或null，不顯示該行
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
              // softWrap: true, // 允許自動換行
            ),
          ),
        ],
      ),
    );
  }
}
