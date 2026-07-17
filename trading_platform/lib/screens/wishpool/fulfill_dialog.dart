import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishpool_provider.dart';

class FulfillDialog extends StatefulWidget {
  final int wishPoolId;
  final String wishTitle;
  final int wishPrice;

  const FulfillDialog({
    super.key,
    required this.wishPoolId,
    required this.wishTitle,
    required this.wishPrice,
  });

  @override
  State<FulfillDialog> createState() => _FulfillDialogState();
}

class _FulfillDialogState extends State<FulfillDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Product? _selectedProduct;
  final TextEditingController _newProductNameCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _newProductNameCtrl.text = widget.wishTitle; // 預設新商品名稱 = 願望標題
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newProductNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    await context.read<ProductProvider>().fetchSellerProducts();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().sellerProducts;

    // 過濾出 "上架中" 的商品
    final activeProducts = products.where((p) => p.status == 'available' && p.stockQuantity > 0).toList();

    return AlertDialog(
      title: Text('接單：${widget.wishTitle}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300, // 給定高度以容納 TabView
        child: Column(
          children: [
            Text('成交價格：\$${widget.wishPrice}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16)),
            const SizedBox(height: 10),
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: '從庫存選擇'),
                Tab(text: '快速接單'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: 從庫存選擇
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : activeProducts.isEmpty
                      ? const Center(child: Text('您沒有可用的上架商品'))
                      : Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      children: [
                        DropdownButtonFormField<Product>(
                          value: _selectedProduct,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: '選擇商品',
                            border: OutlineInputBorder(),
                          ),
                          items: activeProducts.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text('${p.name} (原價 \$${p.price.toInt()})', overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (p) => setState(() => _selectedProduct = p),
                        ),
                      ],
                    ),
                  ),

                  // Tab 2: 快速接單
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('系統將為您自動建立一個對應商品並完成接單。', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _newProductNameCtrl,
                          decoration: const InputDecoration(
                            labelText: '商品名稱',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('注意：此商品將設為「保留中」，僅供此買家結帳。', style: TextStyle(fontSize: 12, color: Colors.orange)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isSending ? null : () => _handleConfirm(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _isSending
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('確認接單'),
        ),
      ],
    );
  }

  Future<void> _handleConfirm() async {
    final isQuickFulfill = _tabController.index == 1;

    if (!isQuickFulfill && _selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('請先選擇一個商品')));
      return;
    }

    setState(() => _isSending = true);

    try {
      await context.read<WishPoolProvider>().fulfillWish(
        widget.wishPoolId,
        productId: isQuickFulfill ? null : _selectedProduct!.id,
        newProductName: isQuickFulfill ? _newProductNameCtrl.text : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('接單成功！交易已成立。'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('接單失敗: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}