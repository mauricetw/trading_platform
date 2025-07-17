import 'package:first_flutter_project/screens/settings/setting.dart';
import 'package:flutter/material.dart';
import '../models/user/user.dart';
import 'cart.dart';
import 'review.dart';
import 'orderlist.dart';
import 'seller/store_management.dart';
// TODO: 如果存在「訂單資訊」和「銷售商品管理」頁面，請取消註解並匯入
// import 'order_info_page.dart';
// import 'sell_product_management_page.dart';

class Profile extends StatelessWidget {
  final User currentUser;

  // 從 UserProfileFrame 設計稿中提取的靜態或預設文字，理想情況下應來自 currentUser 或其他來源
  final String userLocation = "台北市大安區"; // 範例地點
  final String userSchool = "台灣科技大學"; // 範例學校

  // 評價相關的模擬數據
  final double averageBuyReviewRate = 4.5;
  final String totalBuyReviews = "120";
  final double averageSellReviewRate = 4.8;
  final String totalSellReviews = "85";

  const Profile({super.key, required this.currentUser});

  // 輔助函式：建立資訊文字樣式
  Widget _buildInfoText(String text, {double fontSize = 16, Color color = Colors.black, FontWeight fontWeight = FontWeight.normal, TextAlign textAlign = TextAlign.start}) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        // fontFamily: 'Inter', // 根據要求忽略特定字體
        fontWeight: fontWeight,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  // 輔助函式：建立主要按鈕 (橘色背景)
  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    Color iconColor = Colors.white,
  }) {
    return ElevatedButton.icon(
      icon: icon != null ? Icon(icon, color: iconColor) : const SizedBox.shrink(),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF004E98), // UserProfileFrame 中的文字顏色
        backgroundColor: const Color(0xFFFF8C35), // UserProfileFrame 中的橘色背景
        padding: const EdgeInsets.symmetric(vertical: 18.0), // 調整垂直內邊距
        textStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500), // 調整字型大小和粗細
        minimumSize: const Size(double.infinity, 60), // 按鈕最小尺寸，使其填滿可用寬度
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0), // 圓角
        ),
      ),
    );
  }

  // 輔助函式：建立次要按鈕 (藍色背景)
  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return Expanded( // 使按鈕在 Row 中等寬分配
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 20), // 圖示顏色和大小
        label: Text(label, style: const TextStyle(fontStyle: FontStyle.italic)), // 斜體文字
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, // 文字顏色
          backgroundColor: const Color(0xFF004E98), // UserProfileFrame 中的藍色背景
          padding: const EdgeInsets.symmetric(vertical: 18.0), // 調整垂直內邊距
          textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w900), // 調整字型大小和粗細
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0), // 圓角
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    return Scaffold( // 使用 Scaffold 作為頁面根佈局
      backgroundColor: const Color(0xFFEBEBEB), // UserProfileFrame 的背景顏色
      body: SafeArea( // 避免內容被系統狀態列或瀏海遮擋
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0), // 整體內邊距
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // 使 Column 子元件填滿水平空間
            children: [
              // --- 使用者資訊區塊 (大頭貼, 名稱, ID, 評價統計) ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center, // 垂直居中對齊 Row 內的元件
                children: [
                  // 大頭貼
                  CircleAvatar(
                    radius: 54, // UserProfileFrame 中的大頭貼半徑 (108 / 2)
                    backgroundColor: const Color(0xFFD9D9D9), // 預設背景色
                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                    child: user.avatarUrl == null ? const Icon(Icons.person, size: 54, color: Colors.grey) : null,
                  ),
                  const SizedBox(width: 20), // 大頭貼和文字資訊之間的間距
                  // 名稱和 ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoText(user.username, fontSize: 24, fontWeight: FontWeight.w500), // 使用者名稱
                        const SizedBox(height: 5),
                        _buildInfoText(user.id ?? 'N/A', fontSize: 20, color: Colors.black54), // 使用者 ID
                      ],
                    ),
                  ),
                  const SizedBox(width: 10), // 文字資訊和評價統計之間的間距
                  // 評價統計
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildInfoText('平均買家評價', fontSize: 14, color: Colors.black87),
                      _buildInfoText('$averageBuyReviewRate ★', fontSize: 16, fontWeight: FontWeight.bold),
                      const SizedBox(height: 8),
                      _buildInfoText('平均賣家評價', fontSize: 14, color: Colors.black87),
                      _buildInfoText('$averageSellReviewRate ★', fontSize: 16, fontWeight: FontWeight.bold),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 25), // 使用者資訊區塊和學校資訊區塊之間的間距

              // --- 學校資訊區塊 ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0), // 內邊距
                decoration: ShapeDecoration(
                  color: const Color(0xFFD9D9D9), // UserProfileFrame 中的背景顏色
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // 圓角
                  shadows: [ // 輕微陰影效果
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoText(userSchool, fontSize: 18, fontWeight: FontWeight.w500, textAlign: TextAlign.center),
                    if (user.schoolName != null && user.schoolName!.isNotEmpty && userLocation.isNotEmpty) const SizedBox(height: 5),
                    _buildInfoText(userLocation, fontSize: 16, color: Colors.black54, textAlign: TextAlign.center),
                    // 如果您想顯示 User model 中的 bio 或 schoolName，可以取消註解以下內容
                    // if (user.bio != null && user.bio!.isNotEmpty) ...
                    // if (user.schoolName != null && user.schoolName!.isNotEmpty) ...
                  ],
                ),
              ),
              const SizedBox(height: 30), // 學校資訊區塊和按鈕區塊之間的間距

              // --- 按鈕區塊 (2x2 佈局的藍色按鈕) ---
              Row(
                children: [
                  _buildSecondaryButton(
                    label: '收藏',
                    icon: Icons.favorite_border,
                    onPressed: () {
                      print('點擊收藏');
                      // TODO: 導航到收藏頁面
                    },
                  ),
                  const SizedBox(width: 15), // 按鈕之間的間距
                  _buildSecondaryButton(
                    label: '購物車',
                    icon: Icons.shopping_cart_outlined,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15), // 兩行按鈕之間的間距
              Row(
                children: [
                  _buildSecondaryButton(
                    label: '評價',
                    icon: Icons.star_border,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewPage()));
                    },
                  ),
                  const SizedBox(width: 15), // 按鈕之間的間距
                  _buildSecondaryButton(
                    label: '設定',
                    icon: Icons.settings_outlined,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30), // 藍色按鈕區塊和橘色按鈕區塊之間的間距

              // --- 主要功能按鈕 (橘色) ---
              _buildPrimaryButton(
                label: '訂單資訊', // 在 UserProfileFrame 中是「訂單狀態」
                // icon: Icons.receipt_long_outlined, // 您可以選擇是否添加圖示
                onPressed: () {
                  print('點擊訂單資訊');
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OrderListScreen()));
                },
              ),
              const SizedBox(height: 15), // 按鈕之間的間距
              _buildPrimaryButton(
                label: '銷售商品管理', // 在 UserProfileFrame 中是「管理上架商品」
                // icon: Icons.storefront_outlined, // 您可以選擇是否添加圖示
                onPressed: () {
                  print('點擊銷售商品管理');
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SellerDashboardScreen()));
                  // TODO: 導航到銷售商品管理頁面
                },
              ),
              const SizedBox(height: 20), // 頁面底部額外間距

              // --- UserProfileFrame 中的底部藍色列 (可選) ---
              // Container(
              //   height: 74, // UserProfileFrame 中的高度
              //   color: const Color(0xFF004E98),
              //   child: Center(child: _buildInfoText("底部導覽列", color: Colors.white)),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}