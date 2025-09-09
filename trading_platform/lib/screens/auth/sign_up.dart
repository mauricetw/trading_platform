// --- FILE: lib/screens/auth/sign_up.dart ---
// (已整合 AuthProvider 和修復所有編譯錯誤)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isRegistering = false;
  bool _isSendingCode = false;
  Timer? _timer;
  int _countdown = 60;
  bool _isCountingDown = false;

  @override
  void dispose() {
    _timer?.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    FocusScope.of(context).unfocus();
    if (!_emailController.text.endsWith('@mail.ntust.edu.tw')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入有效的台科大信箱 (@mail.ntust.edu.tw)'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() { _isSendingCode = true; });

    try {
      await Provider.of<AuthProvider>(context, listen: false).sendVerificationCode(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('驗證碼已寄出'), backgroundColor: Colors.green),
        );
      }
      _startTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('發送失敗: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSendingCode = false; });
      }
    }
  }

  void _startTimer() {
    _countdown = 60;
    _isCountingDown = true;
    if (mounted) setState(() {});

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        if (mounted) setState(() { _countdown--; });
      } else {
        _timer?.cancel();
        if (mounted) {
          setState(() {
            _isCountingDown = false;
          });
        }
      }
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isRegistering = true; });

    try {
      await Provider.of<AuthProvider>(context, listen: false).register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _codeController.text.trim(),
      );

      if (mounted) {
        // 註冊成功 - 顯示成功訊息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('註冊成功！已自動為您登入'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // 等待一下讓使用者看到成功訊息
        await Future.delayed(const Duration(milliseconds: 800));

        // 由於 AuthProvider 的 register 方法會自動呼叫 _handleAuthSuccess
        // 使用者已經登入了，所以我們可以直接返回或導航到主頁
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(); // 返回登入頁面，但使用者已經登入
          // 或者你可以導航到主頁面：
          // Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      // 詳細的錯誤日誌，幫助除錯
      print('註冊過程發生錯誤: $e');

      if (mounted) {
        String errorMessage = '註冊過程中發生錯誤';
        IconData errorIcon = Icons.error;

        // 根據錯誤內容提供更精確的使用者提示
        final errorString = e.toString().toLowerCase();

        if (errorString.contains('email') || errorString.contains('信箱')) {
          errorMessage = '電子信箱格式錯誤或已被使用';
          errorIcon = Icons.email_outlined;
        } else if (errorString.contains('code') || errorString.contains('驗證碼')) {
          errorMessage = '驗證碼錯誤或已過期，請重新取得';
          errorIcon = Icons.verified_user_outlined;
        } else if (errorString.contains('username') || errorString.contains('用戶') || errorString.contains('使用者')) {
          errorMessage = '用戶名稱已被使用，請選擇其他名稱';
          errorIcon = Icons.person_outline;
        } else if (errorString.contains('password') || errorString.contains('密碼')) {
          errorMessage = '密碼格式不符合要求';
          errorIcon = Icons.lock_outline;
        } else if (errorString.contains('network') || errorString.contains('connection') || errorString.contains('連線')) {
          errorMessage = '網路連接錯誤，請檢查網路後重試';
          errorIcon = Icons.wifi_off;
        } else if (errorString.contains('timeout') || errorString.contains('逾時')) {
          errorMessage = '請求逾時，請稍後重試';
          errorIcon = Icons.access_time;
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
      }
    } finally {
      if (mounted) {
        setState(() { _isRegistering = false; });
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
                  const SizedBox(height: 20),

                  // 標題
                  const Text('帳號註冊', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF004E98))),
                  const SizedBox(height: 40),

                  // 表單欄位
                  _buildSectionTitle('使用者帳號'),
                  TextFormField(
                    controller: _usernameController,
                    decoration: _buildInputDecoration(),
                    validator: (v) => (v == null || v.isEmpty) ? '欄位不能為空' : null,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('使用者密碼'),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _buildInputDecoration(),
                    validator: (v) => (v == null || v.length < 8) ? '密碼長度至少需8個字元' : null,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('再次確認密碼'),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: _buildInputDecoration(),
                    validator: (v) => (v != _passwordController.text) ? '兩次輸入的密碼不一致' : null,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('電子信箱'),
                  TextFormField(
                    controller: _emailController,
                    decoration: _buildInputDecoration(),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.endsWith('@mail.ntust.edu.tw')) ? '請輸入有效的台科大信箱' : null,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('驗證碼'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _codeController,
                          decoration: _buildInputDecoration(),
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.length != 6) ? '請輸入6位數驗證碼' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: (_isSendingCode || _isCountingDown) ? null : _sendVerificationCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C00),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        child: _isSendingCode
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : Text(_isCountingDown ? '$_countdown 秒' : '發送信件', style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 註冊按鈕
                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isRegistering ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004E98),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: _isRegistering
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('註冊', style: TextStyle(color: Color(0xFFFF8C00), fontSize: 18, fontWeight: FontWeight.w600)),
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

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF004E98)),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFD1D6E2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }
}