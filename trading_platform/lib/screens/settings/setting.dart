// --- FILE: screens/settings/setting.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. 引入 Provider
import 'edit_profile.dart';
import 'notification_settings.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';
import '../../providers/auth_provider.dart'; // 2. 引入 AuthProvider

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // --- 登出邏輯輔助函式 ---
  Future<void> _handleLogout(BuildContext context) async {
    // 3. 顯示一個確認對話框，提升使用者體驗
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認登出'),
          content: const Text('您確定要登出嗎？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(false); // 回傳 false
              },
            ),
            TextButton(
              child: const Text('登出', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true); // 回傳 true
              },
            ),
          ],
        );
      },
    );

    // 4. 如果使用者確認登出，才執行後續操作
    if (confirmLogout == true) {
      // 檢查 context 是否仍然有效
      if (context.mounted) {
        // 5. 呼叫 AuthProvider 中的 logout 方法
        await context.read<AuthProvider>().logout();

        // 6. 安全地導航回登入頁面，並清空所有舊頁面
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = 80.0;
    final double bottomCurveHeight = 25.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8D36),
        elevation: 4.0,
        toolbarHeight: appBarHeight,
        title: const Text('設定'),
        centerTitle: true,
        shape: FullBottomConcaveAppBarShape(curveHeight: bottomCurveHeight),
      ),
      backgroundColor: const Color(0XFF004E98),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 8),
          Card(
            elevation: 4.0,
            child: ListTile(
              leading: const Icon(Icons.notifications_none),
              title: const Text('管理通知設定'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 8),
          Card(
            elevation: 4.0,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('更改個人資訊'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 70),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                // --- 關鍵修正：將 onPressed 連接到我們的登出邏輯 ---
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 80.0,
                  ),
                  textStyle: const TextStyle(fontSize: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  '登出',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
