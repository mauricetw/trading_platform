// --- FILE: lib/screens/profile.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/user/user.dart';
import 'settings/setting.dart';
import 'cart.dart';
import 'review.dart';
import 'auth/login_main.dart';
import 'seller/store_management.dart';
import 'orderlist.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  // 輔助函式：建立資訊文字樣式
  Widget _buildInfoText(String text, {double fontSize = 16, Color color = Colors.black, FontWeight fontWeight = FontWeight.normal, TextAlign textAlign = TextAlign.start}) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
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
  }) {
    return ElevatedButton.icon(
      icon: icon != null ? Icon(icon, color: Colors.white) : const SizedBox.shrink(),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFFFF8C35),
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        textStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
        elevation: 4,
      ),
    );
  }

  // 輔助函式：建立次要按鈕 (藍色背景)
  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF004E98),
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  // 輔助函式：建立評價統計 Widget
  Widget _buildReviewStat(String title, double rating) {
    return Column(
      children: [
        _buildInfoText(title, fontSize: 14, color: Colors.black54),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            _buildInfoText(rating.toStringAsFixed(1), fontSize: 18, fontWeight: FontWeight.bold),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Consumer Widget 來監聽 AuthProvider 的變化
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // --- 情況 1：使用者未登入 ---
        if (!authProvider.isLoggedIn) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('您尚未登入', style: TextStyle(fontSize: 24, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('登入後即可查看您的個人資料', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      // 導航到登入選擇頁
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('前往登入'),
                  ),
                ],
              ),
            ),
          );
        }

        // --- 情況 2：使用者已登入 ---
        final User user = authProvider.currentUser!;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 使用者資訊區塊 ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                            ? Icon(Icons.person, size: 54, color: Colors.grey.shade600)
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoText(user.username, fontSize: 24, fontWeight: FontWeight.bold),
                            const SizedBox(height: 5),
                            _buildInfoText('ID: ${user.id}', fontSize: 16, color: Colors.black54),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // --- 學校與評價區塊 ---
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoText(user.schoolName ?? '尚未設定學校', fontSize: 18, fontWeight: FontWeight.w500),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildReviewStat('買家評價', user.buyerRating ?? 0.0),
                            _buildReviewStat('賣家評價', user.sellerRating ?? 0.0),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 按鈕區塊 ---
                  Row(
                    children: [
                      _buildSecondaryButton(label: '收藏', icon: Icons.favorite_border, onPressed: () {
                        // TODO: 導航到收藏頁面
                      }),
                      const SizedBox(width: 15),
                      _buildSecondaryButton(label: '購物車', icon: Icons.shopping_cart_outlined, onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
                      }),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildSecondaryButton(label: '評價', icon: Icons.star_border, onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewPage()));
                      }),
                      const SizedBox(width: 15),
                      _buildSecondaryButton(label: '設定', icon: Icons.settings_outlined, onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                      }),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- 主要功能按鈕 ---
                  _buildPrimaryButton(
                    label: '訂單狀態',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderListScreen()));
                    },
                  ),
                  const SizedBox(height: 15),

                  // 只有賣家才顯示此按鈕
                  if (user.isSeller == true)
                    _buildPrimaryButton(
                      label: '管理上架商品',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SellerDashboardScreen()));
                      },
                    ),

                  const SizedBox(height: 30),
                  // 登出按鈕
                  TextButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text('登出', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false).logout();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
