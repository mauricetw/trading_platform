import 'package:flutter/material.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';
import '../../widgets/BottomConvexArcWidget.dart'; // 確保路徑正確

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _enableAllNotifications = true;
  bool _enablePushNotifications = true;
  bool _enableEmailNotifications = false;
  bool _enableSmsNotifications = false;

  // AppBar 和底部按鈕的弧度高度
  final double commonCurveHeight = 25.0;
  // 底部凸起按鈕的基礎高度 (不包含弧度)
  final double bottomBarBaseHeight = 90.0;


  @override
  void initState() {
    super.initState();
    _updateEnableAllNotifications();
  }

  void _updateEnableAllNotifications() {
    setState(() {
      _enableAllNotifications =
          _enablePushNotifications || _enableEmailNotifications || _enableSmsNotifications;
    });
  }

  void _saveSettings() {
    print(
        '保存通知設定：全部: $_enableAllNotifications, 推播: $_enablePushNotifications, 電子郵件: $_enableEmailNotifications, 簡訊: $_enableSmsNotifications');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知設定已保存')),
    );
    // if (Navigator.canPop(context)) {
    //   Navigator.pop(context);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = 80.0;
    final double actualButtonHeight = bottomBarBaseHeight + commonCurveHeight;


    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        toolbarHeight: appBarHeight,
        title: const Text('通知設定'),
        centerTitle: true,
        backgroundColor: const Color(0xFF3DFF9E),
        shape: FullBottomConcaveAppBarShape(curveHeight: commonCurveHeight),
      ),
      body: ListView(
        // 為底部按鈕預留空間，高度是底部欄的總高度 (基礎高度 + 弧度高度)
        // 再額外加一點padding，避免緊貼
        padding: EdgeInsets.fromLTRB(
            16.0,
            16.0,
            16.0,
            actualButtonHeight + 16.0
        ),
        children: [
          SwitchListTile(
            title: const Text('啟用全部通知'),
            value: _enableAllNotifications,
            onChanged: (bool value) {
              setState(() {
                _enableAllNotifications = value;
                _enablePushNotifications = value;
                _enableEmailNotifications = value;
                _enableSmsNotifications = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('啟用推播通知'),
            value: _enablePushNotifications,
            onChanged: (bool value) {
              setState(() {
                _enablePushNotifications = value;
                _updateEnableAllNotifications();
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('啟用電子郵件通知'),
            value: _enableEmailNotifications,
            onChanged: (bool value) {
              setState(() {
                _enableEmailNotifications = value;
                _updateEnableAllNotifications();
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('啟用手機簡訊通知'),
            value: _enableSmsNotifications,
            onChanged: (bool value) {
              setState(() {
                _enableSmsNotifications = value;
                _updateEnableAllNotifications();
              });
            },
          ),
          const Divider(height: 1),
          // const SizedBox(height: 20), // 舊的按鈕間距可以移除或調整
          // 移除了舊的 ElevatedButton
        ],
      ),
      // 使用自定義的底部凸起圓弧按鈕
      bottomNavigationBar: BottomConvexArcWidget(
        barHeight: bottomBarBaseHeight, // 傳遞調整後的高度
        curveHeight: commonCurveHeight,  // 弧度不變
        backgroundColor: Theme.of(context).primaryColor,
        child: InkWell(
          onTap: _saveSettings,
          child: SizedBox(
            height: bottomBarBaseHeight, // InkWell 的 child 高度也隨之變化
            width: double.infinity,
            child: Align(
              alignment: Alignment(0.0, -0.55),
              child: Text(
                '保存設定',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
