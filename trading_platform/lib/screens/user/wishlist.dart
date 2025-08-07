import 'package:first_flutter_project/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../models/product/product.dart';
import '../../models/user/wishlist_item.dart';

import '../../widgets/FullBottomConcaveAppBarShape.dart';

// 假設您有一個 ProductCard Widget，如果沒有，我們會內聯創建列表項
// import '../../widgets/product_card.dart'; // 例如

class WishlistScreen extends StatefulWidget {
  static const routeName = '/wishlist'; // 用於路由導航

  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    // 進入頁面時，如果狀態是 initial 或 error，嘗試獲取最新的願望清單
    // 使用 WidgetsBinding.instance.addPostFrameCallback 確保 Provider 已準備好
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
      // 只有在用戶已登錄 (wishlistProvider 內部會通過 _currentUserId 間接判斷)
      // 且數據尚未加載或加載出錯時才主動獲取
      if (wishlistProvider.status == WishlistStatus.initial ||
          (wishlistProvider.status == WishlistStatus.error && wishlistProvider.wishlistItems.isEmpty)) {
        // 如果是錯誤狀態但列表不為空，可能是上次加載失敗但仍有舊數據，
        // 這種情況下用戶可能需要手動刷新。
        // 或者，您也可以決定只要是 error 就重新 fetch。
        wishlistProvider.fetchWishlistItems();
      }
    });
  }

  Future<void> _refreshWishlist(BuildContext context) async {
    // 包裹在 try-catch 中不是必須的，因為 Provider 內部會處理錯誤並更新狀態
    // 但如果想在這裡做特定的 UI 反饋也可以
    await Provider.of<WishlistProvider>(context, listen: false)
        .fetchWishlistItems(forceRefresh: true);
  }

  void _showUndoSnackBar(BuildContext context, Product product, WishlistItem removedItem) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // 隱藏可能存在的舊 SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} 已從願望清單移除'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '撤銷',
          onPressed: () {
            // 注意: WishlistProvider 的 addToWishlist 期望一個 Product 對象
            // 這裡我們直接調用它，它會處理與後端的交互
            // 如果您的 addToWishlist 內部會檢查是否已存在，那麼重複添加應該沒問題
            // 或者您可以有一個更底層的 "reAddItem(WishlistItem item)" 方法
            context.read<WishlistProvider>().addToWishlist(product);
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context); // 使用 watch/of 獲取狀態

    Widget content;

    switch (wishlistProvider.status) {
      case WishlistStatus.initial:
      case WishlistStatus.loading:
        content = const Center(child: CircularProgressIndicator());
        break;
      case WishlistStatus.error:
        content = Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 16),
                Text(
                  '加載願望清單失敗',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (wishlistProvider.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      wishlistProvider.errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('重試'),
                  onPressed: () => wishlistProvider.fetchWishlistItems(forceRefresh: true),
                ),
              ],
            ),
          ),
        );
        break;
      case WishlistStatus.empty:
        content = Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 24),
                Text(
                  '您的願望清單是空的',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  '去發現一些您喜歡的商品吧！',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  child: const Text('去逛逛'),
                  onPressed: () {
                    // 導航到您的主市場頁面或分類頁面
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context); // 返回上一頁
                    } else {
                      // 如果不能 pop，可能需要一個到主頁的硬編碼路由
                      // Navigator.pushReplacementNamed(context, '/main_market');
                    }
                  },
                ),
              ],
            ),
          ),
        );
        break;
      case WishlistStatus.loaded:
        final wishlistData = wishlistProvider.wishlistItems; // List<WishlistItem>
        if (wishlistData.isEmpty) { // 理論上 status 應該是 empty，但作為雙重檢查
          content = Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  Text(
                    '您的願望清單是空的',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '去發現一些您喜歡的商品吧！',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    child: const Text('去逛逛'),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
          break; // 跳出 switch
        }
        content = RefreshIndicator(
          onRefresh: () => _refreshWishlist(context),
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0), // 給列表一些邊距
            itemCount: wishlistData.length,
            itemBuilder: (ctx, index) {
              final wishlistItem = wishlistData[index];
              final product = wishlistItem.product; // 直接從 WishlistItem 獲取 Product

              // 這裡您可以使用自定義的 ProductCard Widget，
              // 或者如下所示直接構建列表項
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                elevation: 2,
                child: ListTile(
                  leading: SizedBox(
                    width: 70,
                    height: 70,
                    child: product.imageUrls.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.network(
                        product.imageUrls.first, // 假設取第一張圖
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    )
                        : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    product.price.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                    tooltip: '從願望清單移除',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext dialogContext) => AlertDialog(
                          title: const Text('確認移除'),
                          content: Text('您確定要從願望清單中移除 "${product.name}" 嗎？'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('取消'),
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('移除'),
                              onPressed: () => Navigator.of(dialogContext).pop(true),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        // 保留下被移除的 item 和 product 以便撤銷
                        final removedItemSnapshot = wishlistItem; // 使用其 ID
                        final productSnapshot = product;

                        final success = await wishlistProvider
                            .removeFromWishlistById(removedItemSnapshot.id); // 使用 WishlistItem ID 移除

                        if (success && mounted) { // 檢查 widget 是否還掛載
                          _showUndoSnackBar(context, productSnapshot, removedItemSnapshot);
                        } else if (!success && mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('移除 "${productSnapshot.name}" 失敗: ${wishlistProvider.errorMessage}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  onTap: () {
                    // TODO: 導航到商品詳情頁面
                    // Navigator.pushNamed(context, ProductDetailScreen.routeName, arguments: product.id);
                    print('Tapped on product: ${product.name}');
                  },
                ),
              );
            },
          ),
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        shape: FullBottomConcaveAppBarShape(curveHeight: 25.0 ),
        backgroundColor: primaryCS.primary,
        // 可以考慮添加一個 "清空願望清單" 的按鈕，如果需要
        // actions: [
        //   if (wishlistProvider.status == WishlistStatus.loaded && wishlistProvider.wishlistItems.isNotEmpty)
        //     IconButton(
        //       icon: const Icon(Icons.delete_sweep_outlined),
        //       tooltip: '清空願望清單',
        //       onPressed: () { /* TODO: 實現清空邏輯 */ },
        //     ),
        // ],
      ),
      body: content,
    );
  }
}
