import 'package:flutter/material.dart';
import 'package:first_flutter_project/models/user/user.dart';
import 'package:first_flutter_project/models/product/product.dart';
import 'package:first_flutter_project/theme/app_theme.dart';

class ProductManagementScreen extends StatefulWidget {
  final User currentUser;

  const ProductManagementScreen({super.key, required this.currentUser});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Product> _allProducts = [];
  List<Product> _activeProducts = [];
  List<Product> _soldProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    // 模擬加載商品數據
    await Future.delayed(const Duration(milliseconds: 800));

    // 創建模擬商品數據
    final List<Product> mockProducts = [];
    final sellerId = widget.currentUser.id;

    final sellerInfo = SellerInfo(
      id: sellerId,
      username: widget.currentUser.username,
      avatarUrl: widget.currentUser.avatarUrl,
    );

    for (int i = 0; i < 12; i++) {
      final now = DateTime.now();
      final isActive = i % 3 != 0; // 約2/3為活躍商品

      final product = Product(
        id: sellerId * 1000 + i,
        name: _getProductName(i),
        description: _getProductDescription(i),
        price: (200 + i * 50 + (i % 3) * 100).toDouble(),
        originalPrice: (250 + i * 60 + (i % 3) * 120).toDouble(),
        categoryId: (i % 5) + 1,
        category: _getCategoryName(i % 5),
        stockQuantity: isActive ? (i % 20 + 5) : 0,
        status: isActive ? "available" : "sold",
        imageUrls: [
          'https://picsum.photos/seed/product_${sellerId}_${i}/400/300',
          'https://picsum.photos/seed/product_${sellerId}_${i}_2/400/300',
        ],
        createdAt: now.subtract(Duration(days: i + 1, hours: i * 2)),
        updatedAt: now.subtract(Duration(hours: i)),
        salesCount: isActive ? 0 : (i * 2 + 3),
        averageRating: isActive ? null : ((i % 40 + 30) / 10.0).clamp(3.0, 5.0),
        reviewCount: isActive ? 0 : (i + 2),
        tags: _getProductTags(i),
        sellerId: sellerId,
        seller: sellerInfo,
        shippingInfo: null,
        isFavorite: false,
      );

      mockProducts.add(product);
    }

    if (mounted) {
      setState(() {
        _allProducts = mockProducts;
        _activeProducts = mockProducts.where((p) => p.status == "available").toList();
        _soldProducts = mockProducts.where((p) => p.status == "sold").toList();
        _isLoading = false;
      });
    }
  }

  String _getProductName(int index) {
    final names = [
      '精品無線藍牙耳機',
      '智能手機支架',
      '便攜式充電寶',
      '多功能筆記本',
      '創意桌面收納盒',
      '時尚手機殼',
      '高品質數據線',
      '迷你藍牙音響',
      '實用鍵盤保護膜',
      '舒適滑鼠墊',
      '創新手機配件',
      '精美文具套裝',
    ];
    return names[index % names.length];
  }

  String _getProductDescription(int index) {
    final descriptions = [
      '高品質音響效果，舒適佩戴體驗，適合日常使用和運動時佩戴。',
      '多角度調節，穩固支撐，適用於各種尺寸的手機和平板。',
      '大容量電池，快速充電，輕巧便攜，是您出行的最佳伙伴。',
      '優質紙張，精美裝幀，適合學習、工作和記錄生活點滴。',
      '多格設計，整潔收納，讓您的桌面保持井然有序。',
      '時尚設計，全面保護，精準開孔，不影響使用體驗。',
      '優質材料，傳輸穩定，耐用性強，充電快速安全。',
      '音質清晰，連接穩定，小巧便攜，隨時享受音樂。',
      '透明材質，完美貼合，有效防塵防水，延長鍵盤使用壽命。',
      '舒適手感，防滑底部，精美圖案，提升使用體驗。',
      '創新設計，實用功能，讓您的數位生活更加便利。',
      '精美包裝，品質優良，是學習和工作的好幫手。',
    ];
    return descriptions[index % descriptions.length];
  }

  String _getCategoryName(int index) {
    final categories = ['數位配件', '文具用品', '生活用品', '手機配件', '辦公用品'];
    return categories[index];
  }

  List<String> _getProductTags(int index) {
    final allTags = [
      ['熱銷', '推薦'],
      ['新品', '限時優惠'],
      ['精品', '高品質'],
      ['實用', '創新'],
      ['時尚', '潮流'],
    ];
    return allTags[index % allTags.length];
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: primaryCS.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text('商品管理'),
        backgroundColor: primaryCS.primary,
        foregroundColor: primaryCS.onPrimary,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryCS.onPrimary,
          unselectedLabelColor: primaryCS.onPrimary.withValues(alpha: 0.7),
          indicatorColor: primaryCS.secondary,
          tabs: [
            Tab(text: '全部 (${_allProducts.length})'),
            Tab(text: '上架中 (${_activeProducts.length})'),
            Tab(text: '已售出 (${_soldProducts.length})'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('新增商品功能開發中')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildProductList(_allProducts),
          _buildProductList(_activeProducts),
          _buildProductList(_soldProducts),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '暫無商品',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final isActive = product.status == "available";

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showProductOptions(product);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 商品圖片
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: product.imageUrls.isNotEmpty
                      ? Image.network(
                    product.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.image_not_supported,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                  )
                      : Icon(
                    Icons.image,
                    size: 32,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 商品信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green : Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isActive ? '上架中' : '已售完',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (product.description?.isNotEmpty == true)
                      Text(
                        product.description!,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'NT\$ ${product.price.toStringAsFixed(0)}',
                          style: textTheme.titleSmall?.copyWith(
                            color: primaryCS.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product.originalPrice != null &&
                            product.originalPrice! > product.price)
                          Text(
                            'NT\$ ${product.originalPrice!.toStringAsFixed(0)}',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        const Spacer(),
                        if (isActive)
                          Text(
                            '庫存: ${product.stockQuantity}',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          )
                        else
                          Text(
                            '已售: ${product.salesCount}',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (product.tags != null && product.tags!.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: product.tags!.take(2).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryCS.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: primaryCS.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductOptions(Product product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildOptionTile(
                icon: Icons.edit,
                title: '編輯商品',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('編輯功能開發中')),
                  );
                },
              ),
              _buildOptionTile(
                icon: Icons.visibility,
                title: '查看商品頁面',
                onTap: () {
                  Navigator.pop(context);
                  // 這裡可以導航到商品詳情頁
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('查看商品: ${product.name}')),
                  );
                },
              ),
              _buildOptionTile(
                icon: product.status == "available" ? Icons.pause : Icons.play_arrow,
                title: product.status == "available" ? '下架商品' : '重新上架',
                onTap: () {
                  Navigator.pop(context);
                  _toggleProductStatus(product);
                },
              ),
              _buildOptionTile(
                icon: Icons.delete,
                title: '刪除商品',
                textColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(product);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _toggleProductStatus(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          product.status == "available"
              ? '${product.name} 已下架'
              : '${product.name} 已重新上架',
        ),
      ),
    );
    // 這裡實際應該調用 API 更新商品狀態
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: Text('確定要刪除商品「${product.name}」嗎？\n此操作無法撤銷。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} 已刪除')),
                );
                // 這裡實際應該調用 API 刪除商品
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('刪除'),
            ),
          ],
        );
      },
    );
  }
}