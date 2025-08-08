// --- FILE: lib/screens/auth/sign_up.dart ---
// --- FILE: lib/screens/auth/sign_up.dart ---
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

  // --- 狀態變數重構 ---
  bool _isRegistering = false; // 控制「註冊」按鈕的載入狀態
  bool _isSendingCode = false;  // 控制「發送驗證碼」按鈕的載入狀態
  bool _isCountingDown = false; // 控制是否正在倒數計時

  Timer? _timer;
  int _countdown = 60;

  @override
  void dispose() {
    _timer?.cancel(); // 頁面銷毀時，務必取消計時器
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // --- 發送驗證碼邏輯 ---
  Future<void> _sendVerificationCode() async {
    // 先只驗證 email 格式是否正確
    if (!_emailController.text.endsWith('@mail.ntust.edu.tw')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入有效的台科大信箱'), backgroundColor: Colors.orange),
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

  // --- 倒數計時器邏輯修正 ---
  void _startTimer() {
    _countdown = 60;
    _isCountingDown = true;
    if (mounted) setState(() {}); // 立即更新 UI 顯示 "60秒"

    _timer?.cancel(); // 先取消可能存在的舊計時器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        if (mounted) setState(() { _countdown--; });
      } else {
        // 倒數結束
        _timer?.cancel();
        if (mounted) {
          setState(() {
            _isCountingDown = false; // 明確地將狀態設為「沒有在倒數」
          });
        }
      }
    });
  }

  // --- 註冊邏輯 ---
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
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('註冊失敗: $e'), backgroundColor: Colors.red),
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
      appBar: AppBar(title: const Text('建立帳號')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(controller: _usernameController, labelText: '使用者帳號', icon: Icons.person_outline, validator: (v) => (v == null || v.isEmpty) ? '欄位不能為空' : null),
                const SizedBox(height: 16),
                _buildTextField(controller: _emailController, labelText: '電子信箱 (@mail.ntust.edu.tw)', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => (v == null || !v.endsWith('@mail.ntust.edu.tw')) ? '請輸入有效的台科大信箱' : null),
                const SizedBox(height: 16),
                _buildTextField(controller: _passwordController, labelText: '密碼 (至少8個字元)', icon: Icons.lock_outline, obscureText: true, validator: (v) => (v == null || v.length < 8) ? '密碼長度至少需8個字元' : null),
                const SizedBox(height: 16),
                _buildTextField(controller: _confirmPasswordController, labelText: '再次確認密碼', icon: Icons.lock_person_outlined, obscureText: true, validator: (v) => (v != _passwordController.text) ? '兩次輸入的密碼不一致' : null),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _codeController,
                        labelText: '驗證碼',
                        icon: Icons.pin_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.length != 6) ? '請輸入6位數驗證碼' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      // --- 按鈕狀態邏輯修正 ---
                      onPressed: (_isSendingCode || _isCountingDown) ? null : _sendVerificationCode,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      ),
                      child: _isSendingCode
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_isCountingDown ? '$_countdown 秒後重發' : '發送驗證碼'),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isRegistering ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFFF8C35),
                    foregroundColor: Colors.white,
                  ),
                  child: _isRegistering ? const CircularProgressIndicator(color: Colors.white) : const Text('註冊'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String labelText, required IconData icon, bool obscureText = false, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(controller: controller, decoration: InputDecoration(labelText: labelText, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), obscureText: obscureText, keyboardType: keyboardType, validator: validator, autovalidateMode: AutovalidateMode.onUserInteraction);
  }
}
