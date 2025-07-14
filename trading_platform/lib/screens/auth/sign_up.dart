import 'package:flutter/material.dart';
import 'package:first_flutter_project/services/api_service.dart';
import '../auth/sign_in.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 移除右上角的调试标签
      title: '注册界面', // 应用标题，通常显示在任务管理器中
      theme: ThemeData(
        primarySwatch: Colors.blue, // 主题色为蓝色
        fontFamily: 'Microsoft YaHei', // 使用微软雅黑作为默认字体，支持中文显示
      ),
      home: const SignUpPage(), // 设置应用的首页为注册页面
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

/// 注册页面的状态管理类
class _SignUpPageState extends State<SignUpPage> {
  // GlobalKey用于获取Form的状态，可以用来验证表单
  final _formKey = GlobalKey<FormState>();

  // 创建文本控制器，用于获取和设置各个输入框的值
  final TextEditingController _usernameController = TextEditingController(); // 用户名控制器
  final TextEditingController _passwordController = TextEditingController(); // 密码控制器
  final TextEditingController _confirmPasswordController = TextEditingController(); // 确认密码控制器
  final TextEditingController _emailController = TextEditingController(); // 电子邮箱控制器
  final TextEditingController _verificationCodeController = TextEditingController(); // 验证码控制器

  bool _isLoading = false;  // 用於顯示加載指示器
  String _errorMessage = ''; // 用於顯示錯誤訊息
  bool _hasErrors = false; // 显示错误信息标志
  final ApiService apiService = ApiService();

  // 验证码按钮状态
  int _countdown = 0;
  bool _isCountingDown = false;

  void handleRegister() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;  // 顯示加載動畫
      _errorMessage = ''; // 清空錯誤訊息
      _hasErrors = false; // 重置错误状态
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      setState(() {
        _isLoading = false;
        _hasErrors = true;
        _errorMessage = "Passwords do not match";
      });
      return;
    }

    try {
      final response = await apiService.registerUser(username, email, password);

      if (!mounted) return;

      _showSuccessDialog(response['message']);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasErrors = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignInPage()),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // 获取验证码功能
  void _getVerificationCode() {
    if (_isCountingDown) return;

    setState(() {
      _isCountingDown = true;
      _countdown = 60;
    });

    // 开始倒计时
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _countdown--;
          if (_countdown > 0) {
            _startCountdown();
          } else {
            _isCountingDown = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // 释放所有控制器资源，防止内存泄漏
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _verificationCodeController.dispose();
    super.dispose(); // 调用父类的dispose方法
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 返回按钮
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF004E98),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    padding: const EdgeInsets.all(0),
                  ),
                ),
                const SizedBox(height: 20),

                // 标题 - 帳號註冊
                const Text(
                  '帳號註冊',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004E98),
                  ),
                ),
                const SizedBox(height: 40),

                // 注册表单
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 使用者帳號
                      const Text(
                        '使用者帳號',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF004E98),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D6E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 使用者密碼
                      const Text(
                        '使用者密碼',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF004E98),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D6E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 再次確認密碼
                      const Text(
                        '再次確認密碼',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF004E98),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D6E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 電子信箱
                      const Text(
                        '電子信箱',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF004E98),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D6E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 驗證碼
                      const Text(
                        '驗證碼',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF004E98),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // 验证码输入框
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1D6E2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextFormField(
                                controller: _verificationCodeController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 發送信件按钮
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8C00), // 橙色
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextButton(
                              onPressed: _isCountingDown ? null : _getVerificationCode,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              child: Text(
                                _isCountingDown ? '${_countdown}s' : '發送信件',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // 错误提示区域
                      if (_hasErrors)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '• 使用者帳號規範不正確',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                            Text(
                              '• 使用者帳號已存在',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                            Text(
                              '• 密碼規範不正確',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                            Text(
                              '• 密碼與上面不同',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                            Text(
                              '• 驗證碼錯誤',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),

                      // 註冊按钮
                      Center(
                        child: Container(
                          width: 120,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF004E98),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextButton(
                            onPressed: _isLoading ? null : handleRegister,
                            child: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              '註冊',
                              style: TextStyle(
                                color: Color(0xFFFF8C00),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 發生問題請點選此處
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // 处理问题的逻辑
                          },
                          child: const Text(
                            '發生問題請點選此處',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}