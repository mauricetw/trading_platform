import 'package:flutter/material.dart';

// 假設您有處理通知設置狀態和保存邏輯的服務或提供者
// import 'notification_settings_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // 模擬通知設定的狀態
  bool _enableAllNotifications = true; // 新增：控制全部通知的狀態
  bool _enablePushNotifications = true;
  bool _enableEmailNotifications = false;
  bool _enableSmsNotifications = false;

  @override
  void initState() {
    super.initState();
    // TODO: 在這裡從後端服務或狀態管理中讀取當前的通知設定
    // 例如：
    // final currentSettings = NotificationSettingsService().getSettings();
    // _enablePushNotifications = currentSettings.push;
    // _enableEmailNotifications = currentSettings.email;
    // _enableSmsNotifications = currentSettings.sms;

    // 初始化時根據單獨的設定判斷「全部通知」的初始狀態
    _updateEnableAllNotifications();
  }

  // 根據單獨的通知設定狀態更新「全部通知」的狀態
  void _updateEnableAllNotifications() {
    setState(() {
      _enableAllNotifications =
          _enablePushNotifications || _enableEmailNotifications || _enableSmsNotifications;
    });
  }

  // 保存通知設定的函式
  void _saveSettings() {
    // TODO: 在這裡調用後端服務或狀態管理來保存通知設定
    print(
        '保存通知設定：全部: $_enableAllNotifications, 推播: $_enablePushNotifications, 電子郵件: $_enableEmailNotifications, 簡訊: $_enableSmsNotifications');
    // 例如：
    // NotificationSettingsService().saveSettings(
    //   push: _enablePushNotifications,
    //   email: _enableEmailNotifications,
    //   sms: _enableSmsNotifications,
    // );
    // 顯示保存成功的提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知設定已保存')),
    );
    // 返回上一頁
    // Navigator.pop(context); // 如果您希望保存後自動返回
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
        centerTitle: true,
        backgroundColor: const Color(0xFF3DFF9E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 新增：全部通知開關 (放在最上面)
          SwitchListTile(
            title: const Text('啟用全部通知'),
            value: _enableAllNotifications,
            onChanged: (bool value) {
              setState(() {
                _enableAllNotifications = value;
                // 當「全部通知」開關改變時，同步更新所有單獨通知的狀態
                _enablePushNotifications = value;
                _enableEmailNotifications = value;
                _enableSmsNotifications = value;
              });
              // TODO: 如果需要，在這裡呼叫保存邏輯或標記需要保存
            },
          ),
          const Divider(height: 1), // 分隔線

          // 推播通知開關
          SwitchListTile(
            title: const Text('啟用推播通知'),
            value: _enablePushNotifications,
            onChanged: (bool value) {
              setState(() {
                _enablePushNotifications = value;
                // 當單獨通知狀態改變時，更新「全部通知」開關的狀態
                _updateEnableAllNotifications();
              });
              // TODO: 如果需要，在這裡呼叫保存邏輯或標記需要保存
            },
          ),
          const Divider(height: 1), // 分隔線

          // 電子郵件通知開關
          SwitchListTile(
            title: const Text('啟用電子郵件通知'),
            value: _enableEmailNotifications,
            onChanged: (bool value) {
              setState(() {
                _enableEmailNotifications = value;
                // 當單獨通知狀態改變時，更新「全部通知」開關的狀態
                _updateEnableAllNotifications();
              });
              // TODO: 如果需要，在這裡呼叫保存邏輯或標記需要保存
            },
          ),
          const Divider(height: 1), // 分隔線

          // 手機簡訊通知開關
          SwitchListTile(
            title: const Text('啟用手機簡訊通知'),
            value: _enableSmsNotifications,
            onChanged: (bool value) {
              setState(() {
                _enableSmsNotifications = value;
                // 當單獨通知狀態改變時，更新「全部通知」開關的狀態
                _updateEnableAllNotifications();
              });
              // TODO: 如果需要，在這裡呼叫保存邏輯或標記需要保存
            },
          ),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // 保存按鈕
          ElevatedButton(
            onPressed: _saveSettings, // 點擊按鈕時保存設定
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              textStyle: const TextStyle(fontSize: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('保存設定'),
          ),
        ],
      ),
    );
  }
}