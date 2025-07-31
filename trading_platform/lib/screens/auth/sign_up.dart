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
  final _codeController = TextEditingController(); // 新增：驗證碼控制器

  bool _isLoading = false;
  bool _isSendingCode = false;
  Timer? _timer;
  int _countdown = 60;

  @override
  void dispose() {
    _timer?.cancel();
    // ... 其他 dispose ...
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // --- 新增：發送驗證碼邏輯 ---
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('驗證碼已寄出'), backgroundColor: Colors.green),
      );
      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('發送失敗: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() { _isSendingCode = false; });
      }
    }
  }

  void _startTimer() {
    _countdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        if (mounted) setState(() { _countdown--; });
      } else {
        _timer?.cancel();
        if (mounted) setState(() {});
      }
    });
  }

  // --- 修改後的註冊邏輯 ---
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    try {
      await Provider.of<AuthProvider>(context, listen: false).register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _codeController.text.trim(), // 新增：傳入驗證碼
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
        setState(() { _isLoading = false; });
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
                // ... 使用者帳號、密碼、確認密碼的 TextFormField (保持不變) ...
                _buildTextField(controller: _usernameController, labelText: '使用者帳號', icon: Icons.person_outline, validator: (v) => (v == null || v.isEmpty) ? '欄位不能為空' : null),
                const SizedBox(height: 16),
                _buildTextField(controller: _emailController, labelText: '電子信箱 (@mail.ntust.edu.tw)', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => (v == null || !v.endsWith('@mail.ntust.edu.tw')) ? '請輸入有效的台科大信箱' : null),
                const SizedBox(height: 16),
                _buildTextField(controller: _passwordController, labelText: '密碼 (至少8個字元)', icon: Icons.lock_outline, obscureText: true, validator: (v) => (v == null || v.length < 8) ? '密碼長度至少需8個字元' : null),
                const SizedBox(height: 16),
                _buildTextField(controller: _confirmPasswordController, labelText: '再次確認密碼', icon: Icons.lock_person_outlined, obscureText: true, validator: (v) => (v != _passwordController.text) ? '兩次輸入的密碼不一致' : null),
                const SizedBox(height: 16),

                // --- 新增：驗證碼輸入框和按鈕 ---
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
                      onPressed: (_isSendingCode || _countdown > 0) ? null : _sendVerificationCode,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      ),
                      child: _isSendingCode
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_countdown > 0 ? '$_countdown 秒後重發' : '發送驗證碼'),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFFF8C35),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('註冊'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ... _buildTextField 輔助函式 (保持不變)
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}