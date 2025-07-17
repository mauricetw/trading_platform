import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile.dart'; // 引入我們整合後的編輯頁面
import 'notification_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: const Color(0xFF004E98),
      ),
      backgroundColor: Colors.grey[200],
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        children: [
          _buildSettingsCard(
            context,
            icon: Icons.person_outline,
            title: '編輯個人資訊',
            onTap: () {
              // --- 整合點：導航到我們新的 EditProfilePage ---
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            context,
            icon: Icons.notifications_none,
            title: '管理通知設定',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
              );
            },
          ),

          const SizedBox(height: 40),

          // 登出按鈕
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('登出'),
            onPressed: () {
              // --- 整合點：呼叫 AuthProvider 的登出方法 ---
              Provider.of<AuthProvider>(context, listen: false).logout();
              // 登出後，我們的 SplashScreen 會自動偵測到狀態改變並導向登入頁
              // 為了更好的體驗，可以手動將使用者導航回 App 的最外層
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 輔助函式，建立統一風格的卡片
  Widget _buildSettingsCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
