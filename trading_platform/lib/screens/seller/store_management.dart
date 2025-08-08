// --- FILE: lib/screens/seller/store_management.dart ---
import 'package:flutter/material.dart';
import 'product_management.dart';
import 'order_page.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('賣家中心', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.1,
        children: <Widget>[
          _buildDashboardButton(
            context: context,
            icon: Icons.storefront_outlined,
            label: '商品管理',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductManagementScreen()),
              );
            },
          ),
          _buildDashboardButton(
            context: context,
            icon: Icons.receipt_long_outlined,
            label: '訂單管理',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SellerOrderPage()),
              );
            },
          ),
          // ... 其他按鈕
        ],
      ),
    );
  }

  // 輔助函式
  Widget _buildDashboardButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.0),
            const SizedBox(height: 12.0),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
