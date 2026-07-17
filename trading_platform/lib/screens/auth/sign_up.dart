// --- FILE: lib/screens/auth/sign_up.dart ---
// (已整合 AuthProvider)
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

  bool _isLoading = false;  // 用於顯示加載指示器
  String _errorMessage = ''; // 用於顯示錯誤訊息
  final ApiService apiService = ApiService();

  void handleRegister() async {
    setState(() {
      _isLoading = true;  // 顯示加載動畫
      _errorMessage = ''; // 清空錯誤訊息
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      _showErrorDialog("Passwords do not match");
      return;
    }

    try {
      final response = await apiService.registerUser(username, email, password);
      _showSuccessDialog(response['message']);
      // 點擊按鈕時跳轉至登入頁面
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text("Success"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // 返回登入頁面
                },
                child: Text("OK"),
              ),
            ],
          ),
    );
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('註冊成功！請登入。'), backgroundColor: Colors.green),
        );
        // 註冊成功後，返回登入頁
        Navigator.of(context).pop();
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
