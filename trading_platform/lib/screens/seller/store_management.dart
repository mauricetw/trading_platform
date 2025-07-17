import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'upload.dart';
import 'product_management.dart';
import '../../providers/auth_provider.dart';
import '../../models/user/user.dart';
// --- 色彩定義 (可以根據您的主題調整) ---
const Color primaryBlue = Color(0xFF004E98);
const Color lightBackground = Color(0xFFF0F4F8);
const Color darkTextColor = Color(0xFF333333);
const Color lightTextColor = Colors.white;
const Color cardBackgroundColor = Colors.white;
const Color iconColor = primaryBlue;


class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  // 輔助方法來創建風格化的導航按鈕
  Widget _buildDashboardButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? buttonColor,
    Color? textColor,
    Color? iconForegroundColor,
  }) {
    final effectiveButtonColor = buttonColor ?? cardBackgroundColor;
    final effectiveTextColor = textColor ?? darkTextColor;
    final effectiveIconColor = iconForegroundColor ?? iconColor;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: effectiveButtonColor,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 40.0, color: effectiveIconColor),
              SizedBox(height: 12.0),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: effectiveTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final User? currentUser = authProvider.currentUser;

    if (currentUser == null) {
      // 處理 currentUser 為 null 的情況
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '賣家中心',
          style: TextStyle(fontWeight: FontWeight.bold, color: lightTextColor),
        ),
        backgroundColor: primaryBlue,
        elevation: 2,
        iconTheme: IconThemeData(color: lightTextColor), // 確保返回按鈕也是淺色
      ),
      backgroundColor: lightBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- 歡迎語或賣家信息 (可選) ---
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                '歡迎回來，賣家！', // 或者顯示賣家名稱
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: darkTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> ProductManagementScreen(currentUser: currentUser)));
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
                    // TODO: 導航到訂單管理頁面
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('導航到 訂單管理 頁面 (待實現)')),
                    );
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => YourOrderManagementScreen()));
                  },
                ),
                _buildDashboardButton(
                  context: context,
                  icon: Icons.comment,
                  label: '查看評價',
                  onPressed: () {
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
    );
  }
}
