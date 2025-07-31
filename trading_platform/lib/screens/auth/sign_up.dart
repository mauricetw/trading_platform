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
      _isLoading = true;
      _errorMessage = '';
      _hasErrors = false;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // 基本驗證
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasErrors = true;
        _errorMessage = "請填寫所有必填欄位";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _isLoading = false;
        _hasErrors = true;
        _errorMessage = "密碼不一致";
      });
      return;
    }

    try {
      final response = await apiService.registerUser(
        username: username,
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (response['success']) {
        _showSuccessDialog(response['data']?['message'] ?? '註冊成功！');
      } else {
        setState(() {
          _isLoading = false;
          _hasErrors = true;
          _errorMessage = response['error'] ?? '註冊失敗';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasErrors = true;
        _errorMessage = '註冊時發生錯誤: $e';
      });
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("錯誤"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("確定"),
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
        title: const Text("成功"),
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
            child: const Text("確定"),
          ),
        ],
      ),
    );
  }

  // 获取验证码功能
  void _getVerificationCode() {
    if (_isCountingDown) return;

    String email = _emailController.text.trim();
    if (email.isEmpty) {
      _showErrorDialog('請先輸入電子信箱');
      return;
    }

    setState(() {
      _isCountingDown = true;
      _countdown = 60;
    });

    // 這裡可以加入實際的發送驗證碼 API 呼叫
    // 例如：apiService.sendVerificationCode(email);

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
                          keyboardType: TextInputType.emailAddress,
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
                                style: TextStyle(
                                  color: _isCountingDown ? Colors.grey : Colors.black,
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
                      if (_hasErrors && _errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),

                      if (_hasErrors && _errorMessage.isNotEmpty)
                        const SizedBox(height: 20),

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
                            _showErrorDialog('如有問題，請聯繫客服');
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