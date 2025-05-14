import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'notification_settings.dart'; // 導入通知設定頁面檔案
// 假設您有處理登出邏輯的服務或提供者
// import 'auth_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 通知設定入口
          const Text(
            '通知設定',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2.0,
            child: ListTile( // 使用 ListTile 作為導航項目
              leading: const Icon(Icons.notifications_none),
              title: const Text('管理通知設定'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 導航到通知設定頁面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationSettingsPage()),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // 帳戶設定區塊
          const Text(
            '帳戶設定',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2.0,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('更改個人資訊'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // 導航到個人資訊更改頁面
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditProfilePage()),
                    );
                  },
                ),
                // 可以根據需要添加其他帳戶相關的 ListTile
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 登出按鈕
          ElevatedButton(
            onPressed: () {
              // TODO: 處理登出邏輯
              print('點擊登出');
              // 例如：
              // AuthService().logout(); // 調用登出服務
              // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // 導航到登入頁面並移除所有歷史堆棧
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              textStyle: const TextStyle(fontSize: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('登出', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}