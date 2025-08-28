import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // 只有在 Debug 時才會生效；要繞過登入把這裡改成 true
  static const bool kBypassLoginForDev = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // 0) 已登入就直接進首頁（例如其他地方已經 mock 登入過）
    if (auth.isLoggedIn) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }

    // 1) 本地開發繞過登入（只在 Debug + 開關為 true）
    if (kDebugMode && kBypassLoginForDev) {
      await auth.mockLoginForDev();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }

    // 2) 正常流程：嘗試自動登入（讀取 secure storage 的 token）
    final ok = await auth.tryAutoLogin();

    if (!mounted) return;
    if (ok && auth.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
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
