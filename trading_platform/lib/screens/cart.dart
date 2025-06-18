// lib/cart_page.dart

import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 模擬購物車商品列表
    final List<String> cartItems = [
      '商品 A',
      '商品 B',
      '商品 C',
      '商品 D',
      '商品 E',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('購物車'),
      ),
      body: cartItems.isEmpty // 檢查購物車是否為空
          ? const Center(
        child: Text('您的購物車是空的！'),
      )
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return Card( // 使用 Card 來美化每個商品項目
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              leading: const Icon(Icons.shopping_cart),
              // 商品圖標
              title: Text(item),
              // 商品名稱
              subtitle: const Text('價格: \$XX.XX'),
              // 模擬價格
              trailing: IconButton( // 移除商品按鈕 (無實際功能)
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // 在實際應用中，您會在這裡實現移除購物車商品的邏輯
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('移除 "$item" (無實際功能)')),
                  );
                },
              ),
              onTap: () {
                // 在實際應用中，您可能在這裡導航到商品詳細頁面
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('點擊了 "$item" (無實際功能)')),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar( // 底部總金額顯示 (無實際功能)
        child: Container(
          height: 50.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('總金額:', style: TextStyle(
                  fontSize: 18.0, fontWeight: FontWeight.bold)),
              Text('\$XXX.XX', style: TextStyle(
                  fontSize: 18.0, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended( // 結帳按鈕 (無實際功能)
        onPressed: () {
          // 在實際應用中，您會在這裡實現結帳邏輯
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('前往結帳 (無實際功能)')),
          );
        },
        label: const Text('結帳'),
        icon: const Icon(Icons.payment),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerDocked, // 將 FAB 放在 BottomAppBar 中間
    );
  }
}