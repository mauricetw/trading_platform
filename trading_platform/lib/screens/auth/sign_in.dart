// --- FILE: lib/screens/auth/sign_in.dart ---
// (已整合 AuthProvider，並採用與註冊頁一致的 UI 風格)
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'forget_password.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _identifierController.text.trim(),
        _passwordController.text.trim(),
      );

      // 修復：檢查 mounted 後再使用 context
      if (!mounted) return;

      // 登入成功 - 顯示歡迎訊息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('登入成功！歡迎回來'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      // 稍微延遲一下讓用戶看到成功訊息
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);

    } catch (e) {
      debugPrint('登入錯誤: $e');

      if (!mounted) return;

      String errorMessage = '登入失敗，請檢查您的帳號或密碼';
      IconData errorIcon = Icons.error_outline;

      // 根據錯誤類型提供更具體的提示
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('user not found') || errorString.contains('用戶不存在') || errorString.contains('帳號')) {
        errorMessage = '找不到此帳號，請檢查用戶名稱或使用Email登入';
        errorIcon = Icons.person_search;
      } else if (errorString.contains('password') || errorString.contains('密碼') || errorString.contains('incorrect')) {
        errorMessage = '密碼錯誤，請重新輸入';
        errorIcon = Icons.lock_outline;
      } else if (errorString.contains('email') && errorString.contains('not verified')) {
        errorMessage = 'Email尚未驗證，請檢查信箱完成驗證';
        errorIcon = Icons.mark_email_unread;
      } else if (errorString.contains('network') || errorString.contains('connection')) {
        errorMessage = '網路連接錯誤，請檢查網路後重試';
        errorIcon = Icons.wifi_off;
      } else if (errorString.contains('server') || errorString.contains('伺服器')) {
        errorMessage = '伺服器暫時無法回應，請稍後重試';
        errorIcon = Icons.data_usage;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(errorIcon, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(errorMessage)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '確認',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 返回按鈕
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF004E98),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 標題
                  const Text(
                    '帳號登入',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004E98),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 使用者帳號/信箱
                  const Text('使用者帳號 / 電子信箱', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF004E98))),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _identifierController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD1D6E2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? '欄位不能為空' : null,
                  ),
                  const SizedBox(height: 24),

                  // 密碼
                  const Text('使用者密碼', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF004E98))),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD1D6E2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? '欄位不能為空' : null,
                  ),
                  const SizedBox(height: 24),

                  // 登入按鈕
                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004E98),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('登入', style: TextStyle(color: Color(0xFFFF8C00), fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 忘記密碼
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
                      },
                      child: const Text(
                        '忘記密碼了嗎？',
                        style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}