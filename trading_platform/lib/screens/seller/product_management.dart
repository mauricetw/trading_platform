// lib/screens/seller/product_management_screen.dart
import 'package:flutter/material.dart';
import 'upload.dart';
import 'order_page.dart'; // 導入我們剛剛創建的訂單管理頁面

// --- 色彩定義 (可以根據您的主題調整) ---
const Color primaryBlue = Color(0xFF004E98);
const Color lightBackground = Color(0xFFF0F4F8);
const Color darkTextColor = Color(0xFF333333);
const Color lightTextColor = Colors.white;
const Color cardBackgroundColor = Colors.white;
const Color iconColor = primaryBlue;

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

class ProductManagementScreen extends StatefulWidget {
  final User currentUser; // 假設需要當前用戶來獲取其商品

  const ProductManagementScreen({super.key, required this.currentUser});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  List<Product> _sellerProducts = []; // 用於存儲賣家的商品列表
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSellerProducts();
  }

  // 模擬從後端獲取賣家商品數據
  Future<void> _fetchSellerProducts() async {
    setState(() {
      _isLoading = true;
    });
    // TODO: 替換為真實的 API 調用以獲取 widget.currentUser 的商品
    await Future.delayed(const Duration(seconds: 1)); // 模擬網絡延遲

    // --- 模擬數據 ---
    _sellerProducts = List.generate(
      5,
          (index) => Product(
        id: 'prod_id_${widget.currentUser.id.substring(0,3)}_$index',
        name: '我的商品 ${index + 1}',
        description: '這是商品 ${index + 1} 的詳細描述。它非常棒，值得擁有！',
        price: (index + 1) * 199.99 + 50,
        originalPrice: (index + 1) * 299.99 + 100,
        imageUrls: [
          'https://picsum.photos/seed/${index + 1}/200/200',
          'https://picsum.photos/seed/a${index + 1}/200/200'
        ],
        // category: index % 2 == 0 ? '電子產品' : '家居用品', // 您的模型有 category 和 categoryId
        category: index % 2 == 0 ? '電子產品' : '家居用品', // 暫時使用 category name
        categoryId: index + 1, // 假設 categoryId
        stockQuantity: 10 + index * 5,
        isSold: false,
        status: 'available',
        createdAt: DateTime.now().subtract(Duration(days: index)),
        updatedAt: DateTime.now().subtract(Duration(hours: index)),
        // sellerId: widget.currentUser.id,       // 您的模型直接使用 User 對象
        // sellerName: widget.currentUser.username, // 您的模型直接使用 User 對象
        seller: widget.currentUser, // <-- 直接使用傳入的 User 對象
        // attributes: { // 您的模型沒有 'attributes' 字段，但可以將這些信息放入 tags 或 description
        //   'condition': index % 3 == 0 ? '全新' : (index % 3 == 1 ? '近全新' : '良好'),
        //   'type': index % 2 == 0 ? '一般商品' : '限時特價',
        // }
        tags: [ // 示例：將 condition 和 type 放入 tags
          index % 3 == 0 ? '全新' : (index % 3 == 1 ? '近全新' : '良好'),
          index % 2 == 0 ? '一般商品' : '限時特價',
        ],
        salesCount: index * 5,
        averageRating: index % 2 == 0 ? 4.5 - index * 0.1 : null,
        reviewCount: index * 3,
        shippingInfo: null, // 暫時設為 null，您可以根據需要創建 ShippingInformation 實例
      ),
    );
    // --- 模擬數據結束 ---

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 導航到商品上傳/編輯頁面
  Future<void> _navigateAndUpsertProduct({Product? productToEdit}) async {
    // Navigate to the ProductUploadPage.
    // The 'await' keyword is used because ProductUploadPage might return a value
    // (e.g., true if a product was successfully added/updated).
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductUploadPage(
          seller: widget.currentUser, // 傳遞當前賣家信息
          productToEdit: productToEdit, // 如果是編輯，傳遞商品；否則為 null
        ),
      ),
    );

    // If ProductUploadPage returns true, it means an operation was successful,
    // so we should refresh the list of products.
    if (result == true) {
      _fetchSellerProducts(); // 重新獲取商品列表
    }
  }

  // 刪除商品的模擬方法
  Future<void> _deleteProduct(BuildContext context, Product product) async {
    // Show a confirmation dialog
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: Text('您確定要刪除商品 "${product.name}" 嗎？此操作無法撤銷。'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // User canceled
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('刪除'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // User confirmed
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      // TODO: 調用 API 刪除後端商品數據
      print('API CALL: Deleting product ${product.id}');
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call

      // 從本地列表中移除並刷新UI
      setState(() {
        _sellerProducts.removeWhere((p) => p.id == product.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('商品 "${product.name}" 已刪除'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的商品管理'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2.0,
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
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                _navigateAndUpsertProduct(); // 調用導航方法，不傳遞 productToEdit 即為新增
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
                    image: NetworkImage(product.imageUrls.first), // 顯示第一張圖片
                    fit: BoxFit.cover,
                  )
                      : null, // 可以放一個占位圖
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
                    '價格: NT\$${product.price.toStringAsFixed(0)}', // 假設價格無小數
                    style: TextStyle(color: theme.primaryColorDark, fontWeight: FontWeight.w500),
                  ),
                  Text('庫存: ${product.stockQuantity}'),
                  Text(
                    product.status == 'sold_out' ? '已售罄' : (product.isSold ? '已售出' : '銷售中'),
                    style: TextStyle(
                        color: product.isSold || product.status == 'sold_out' ? Colors.redAccent : Colors.green,
                        fontStyle: FontStyle.italic
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: theme.colorScheme.secondary),
                    tooltip: '編輯商品',
                    onPressed: () {
                      _navigateAndUpsertProduct(productToEdit: product); // 傳遞商品進行編輯
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
                // 可以導航到商品詳情頁，或直接編輯
                _navigateAndUpsertProduct(productToEdit: product);
              },
            ),

            // --- 主要導航按鈕 ---
            GridView.count(
              shrinkWrap: true, // 讓 GridView 適應內容高度
              physics: NeverScrollableScrollPhysics(), // 禁用 GridView 自身的滾動
              crossAxisCount: 2, // 每行顯示2個按鈕
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.1, // 調整按鈕的寬高比，可以根據內容調整
              children: <Widget>[
                _buildDashboardButton(
                  context: context,
                  icon: Icons.storefront_outlined,
                  label: '商品管理\n(我的商品)',
                  onPressed: () {
                    // TODO: 導航到商品管理頁面
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('導航到 商品管理 頁面 (待實現)')),
                    );
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => YourProductManagementScreen()));
                  },
                ),
                _buildDashboardButton(
                  context: context,
                  icon: Icons.receipt_long_outlined,
                  label: '訂單管理\n(商品訂單)',
                  onPressed: () {
                    // 導航到訂單管理頁面
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SellerOrderPage())
                    );
                  },
                ),
                _buildDashboardButton(
                  context: context,
                  icon: Icons.add_circle_outline,
                  label: '上架新商品',
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductUploadPage()));
                    // TODO: 導航到上架商品頁面
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('導航到 上架新商品 頁面 (待實現)')),
                    );
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => YourAddProductScreen()));
                  },
                ),
                _buildDashboardButton(
                  context: context,
                  icon: Icons.settings_outlined,
                  label: '店鋪設置',
                  onPressed: () {
                    // TODO: 導航到店鋪設置頁面
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('導航到 店鋪設置 頁面 (待實現)')),
                    );
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => YourShopSettingsScreen()));
                  },
                ),
                // 您可以根據需要添加更多按鈕
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigateAndUpsertProduct(); // 調用導航方法，不傳遞 productToEdit 即為新增
        },
        tooltip: '上架新商品',
        icon: const Icon(Icons.add_shopping_cart_outlined),
        label: const Text('上架商品'),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: Colors.white,
      ),
    );
  }
}