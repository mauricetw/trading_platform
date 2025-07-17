import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 使用 addPostFrameCallback 確保 BuildContext 已經準備好
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    // 取得 AuthProvider，但不需要監聽變化
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 呼叫 AuthProvider 的方法來嘗試自動登入
    final bool isLoggedIn = await authProvider.tryAutoLogin();

    // 根據登入狀態進行導航
    if (mounted) { // 檢查 widget 是否還在 widget tree 中
      if (isLoggedIn) {
        // 如果已登入，替換當前頁面為首頁
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // 如果未登入，替換當前頁面為登入頁
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 顯示一個簡單的載入畫面
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('載入中...'),
          ],
        ),
      ),
    );
  }
}
