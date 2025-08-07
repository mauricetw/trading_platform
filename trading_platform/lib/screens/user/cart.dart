import 'package:first_flutter_project/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../models/user/cart_item.dart';
import '../../models/product/product.dart'; // Product 模型
import 'checkout.dart'; // 結帳頁面
import '../product.dart'; // 【【確保這個 ProductScreen 已經更新為接收 productId】】

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    // 考慮是否需要在 initState 中觸發購物車數據獲取
    // 例如，如果用戶直接進入購物車頁面且數據可能未加載
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      // 假設 fetchUserCart 內部會處理是否真的需要發起請求 (例如，僅當數據為空時)
      // 或者您可以添加更明確的條件，例如結合 AuthService 判斷登錄狀態
      if (cartProvider.items.isEmpty && !cartProvider.isLoading) {
        print("CartPage: Cart is empty and not loading, attempting to fetch user cart.");
        cartProvider.fetchUserCart().catchError((error) {
          print("CartPage: Error fetching cart on init (silently): $error");
          // 這裡可以不顯示 SnackBar，因為 _buildBody 中有錯誤處理UI
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 使用 watch 來監聽 CartProvider 的變化並重建 UI
    final cartProvider = Provider.of<CartProvider>(context);
    // 直接從 provider 獲取最新的購物車列表
    final List<CartItem> cartItemsList = cartProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('購物車'),
        actions: [
          if (cartItemsList.isNotEmpty && !cartProvider.isLoading)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined), // 稍微換個圖標
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
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('確定清空', style: TextStyle(color: Colors.red)),
            onPressed: () {
              cartProvider.clearCart(); // 假設這個方法會處理後端同步和本地更新
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
    // 初始加載狀態 (當 items 為空且正在 loading)
    if (cartProvider.isLoading && cartItemsList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 加載失敗狀態 (當有 error 且 items 為空)
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
                  // 調用 fetchUserCart 時，provider 內部應重置 error 狀態
                  cartProvider.fetchUserCart();
                },
              )
            ],
          ),
        ),
      );
    }

    // 購物車為空狀態 (items 為空且沒有在 loading，也沒有 error)
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
                // 導航到商品列表頁或首頁
                // 這裡假設您有一個名為 '/home' 的路由代表首頁或商品列表
                if (Navigator.canPop(context)) {
                  // 如果是從其他頁面 push 過來的，可以考慮 pop 回去
                  // 或者直接跳轉到主頁
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false); // 如果有 Home 路由
                } else {
                  // 如果 CartPage 是初始頁面，可能需要不同的導航邏輯
                  // Navigator.pushReplacementNamed(context, '/home');
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

    // 購物車有商品，顯示列表
    return RefreshIndicator(
      onRefresh: () => cartProvider.fetchUserCart(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80), // 避免被 BottomAppBar 遮擋最後一項
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
                // 【【【重要修改】】】
                // 導航到 ProductScreen 並傳遞 productId
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
                  crossAxisAlignment: CrossAxisAlignment.start, // 讓圖片和文字信息頂部對齊
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
                      width: 80, // 稍微加大圖片
                      height: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: item.productImage != null && Uri.tryParse(item.productImage!)?.hasAbsolutePath == true
                            ? Image.network(
                          item.productImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey[200], child: const Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey)),
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
                    // 商品信息和操作
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 讓名稱和價格/數量控制分開
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '價格: \$${item.productPrice.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColorDark, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          // 數量控制
                          Row(
                            mainAxisSize: MainAxisSize.min, // 讓 Row 緊湊
                            children: <Widget>[
                              _buildQuantityButton(
                                context,
                                icon: Icons.remove_circle_outline,
                                onPressed: item.quantity > 1
                                    ? () => cartProvider.decrementQuantity(item.productId)
                                    : () => _confirmRemoveItem(context, cartProvider, item, "確認移除", "數量減至0將移除商品，確定嗎？"),
                                tooltip: item.quantity > 1 ? '減少數量' : '移除商品',
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0), // 增加數字左右間距
                                child: Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              _buildQuantityButton(
                                context,
                                icon: Icons.add_circle_outline,
                                onPressed: () {
                                  // TODO: 實現庫存檢查邏輯 (參考 ProductScreen 中的 isSoldOut)
                                  // if (item.quantity < (item.originalStockQuantity ?? double.infinity)) {
                                  cartProvider.incrementQuantity(item.productId);
                                  // } else {
                                  //   ScaffoldMessenger.of(context).showSnackBar(
                                  //     const SnackBar(content: Text('已達庫存上限')),
                                  //   );
                                  // }
                                },
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
                      padding: EdgeInsets.zero, // 減少按鈕周圍的 padding
                      constraints: const BoxConstraints(), // 移除默認的大小限制
                      onPressed: () {
                        _confirmRemoveItem(context, cartProvider, item);
                      },
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

  // 輔助方法創建數量按鈕，減少重複代碼
  Widget _buildQuantityButton(BuildContext context, {required IconData icon, required VoidCallback onPressed, required String tooltip}) {
    return SizedBox(
      width: 32, // 固定按鈕寬度
      height: 32, // 固定按鈕高度
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 24, color: Theme.of(context).primaryColor), // 統一圖標大小和顏色
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  void _confirmRemoveItem(BuildContext context, CartProvider cartProvider, CartItem item, [String title = '移除商品', String? content]) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content ?? '您確定要從購物車移除 "${item.productName}" 嗎？'),
        actions: <Widget>[
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('確定移除', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(ctx).pop(); // 先關閉對話框
              cartProvider.removeItem(item.productId); // 調用 CartProvider 的方法

              ScaffoldMessenger.of(context).hideCurrentSnackBar(); // 隱藏可能存在的舊 SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已移除 "${item.productName}"'),
                  duration: const Duration(seconds: 4), // 稍微延長時間以便點擊撤銷
                  action: SnackBarAction(
                    label: '撤銷',
                    textColor: Theme.of(context).colorScheme.surface, // 根據主題調整撤銷按鈕顏色
                    onPressed: () {
                      final int originalQuantity = item.quantity;
                      final bool originalIsSelected = item.isSelected;
                      // 【【重要】】撤銷邏輯:
                      // 您的 CartProvider 中的 addItem 方法需要能夠處理這種情況。
                      // 它需要一個 Product 對象。由於我們只有 CartItem，
                      // 我們需要從 CartItem 的信息重建一個 Product 對象。
                      // 這通常意味著 Product 的構造函數應該允許某些字段為可選，
                      // 或者我們為 CartItem 添加更多來自 Product 的字段。

                      // 假設 Product 構造函數允許這樣創建，並且 CartItem 包含必要信息
                      final productToRestore = Product(
                        // --- 從 CartItem 獲取 ---
                        id: item.productId,
                        name: item.productName,
                        price: item.productPrice,
                        imageUrls: item.productImage != null ? [item.productImage!] : [], // 如果 productImage 為 null，則提供空列表

                        // --- 為 Product 的必填字段提供默認值/佔位符 ---
                        description: '', // 或者 item.productDescription 如果您的 CartItem 未來會添加此字段
                        categoryId: 0,   // 提供一個合理的默認分類 ID，或者一個表示“未知”的特殊 ID
                        stockQuantity: originalQuantity, // 恢復購物車時的庫存可以基於購物車中的數量
                        // 注意：這不是產品的總庫存，但對於加入購物車的行為是合理的
                        category: '未知分類', // 提供一個合理的默認分類名稱
                        status: 'available',  // 假設商品在撤銷時仍然可用
                        createdAt: DateTime.now(), // 無法從 CartItem 獲取，使用當前時間作為近似值
                        updatedAt: DateTime.now(), // 同上

                        // --- 可選字段或有默認值的字段將使用它們的默認行為 ---
                        // originalPrice: null, // 或如果 CartItem 有，則從 CartItem 獲取
                        // salesCount: 0, // 使用 Product 構造函數的默認值
                        // averageRating: null,
                        // reviewCount: null,
                        // tags: null,
                        // shippingInfo: null,
                        // seller: null, // 如果需要，且 CartItem 中有 sellerId，可以嘗試創建一個最小的 User 對象
                        // isSold: false, // 使用 Product 構造函數的默認值
                        // isFavoriteByCurrentUser: false, // 通常由用戶交互決定，使用默認值
                      );

                      cartProvider.addItem(
                        productToRestore,
                        originalQuantity,
                        wasSelected: originalIsSelected,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已撤銷移除 "${item.productName}"')),
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
    final themeColors = Theme.of(context).colorScheme; // 使用主題顏色

    return BottomAppBar(
      elevation: 8,
      child: Container(
        height: 70, // 略微增加高度以獲得更好的間距
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // 全選區域
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
                    visualDensity: VisualDensity.compact, // 讓 Checkbox 更緊湊
                  ),
                  const SizedBox(width: 4), // 調整間距
                  const Text('全選', style: TextStyle(fontSize: 15)),
                ],
              ),
            ),

            // 合計金額
            Expanded( // 使用 Expanded 讓金額部分可以適應空間
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0), // 增加水平間距
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
                  crossAxisAlignment: CrossAxisAlignment.end,   // 文字右對齊
                  children: [
                    Text(
                      '合計 (已選 ${cartProvider.selectedItemCount} 件):',
                      style: TextStyle(fontSize: 12, color: themeColors.onSurfaceVariant), // 使用主題中更合適的次要文字顏色
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '\$${cartProvider.totalSelectedAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: themeColors.primary), // 總金額使用主題主色
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 結算按鈕
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cartProvider.selectedItemCount > 0 ? themeColors.primary : Colors.grey[400],
                foregroundColor: cartProvider.selectedItemCount > 0 ? themeColors.onPrimary : Colors.grey[700], // 按鈕文字顏色
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // 調整按鈕大小
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), // 更圓潤的按鈕
              ),
              onPressed: cartProvider.selectedItemCount > 0
                  ? () {
                final selectedItemsToCheckout = cartProvider.items
                    .where((item) => item.isSelected)
                    .toList();
                if (selectedItemsToCheckout.isEmpty) { // 再次檢查，以防萬一
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('請至少選擇一件商品進行結算')),
                  );
                  return;
                }
                // 檢查選中商品數量是否有效 (例如，是否 > 0)
                // if (selectedItemsToCheckout.any((item) => item.quantity <= 0)) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(content: Text('選中商品數量異常，請檢查！')),
                //   );
                //   return;
                // }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(), // 【【傳遞選中的商品到結帳頁】】
                  ),
                );
              }
                  : null, // 如果沒有選中商品，禁用按鈕
              child: Text('結算 (${cartProvider.selectedItemCount})'),
            ),
          ],
        ),
      ),
    );
  }
}
