import 'package:flutter/material.dart';
import 'package:first_flutter_project/api_service.dart';
import '../auth/sign_in.dart';

/*void main() {
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
}*/

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

/// 注册页面的状态管理类
class _SignUpPageState extends State<SignUpPage> {
  // GlobalKey用于获取Form的状态，可以用来验证表单
  final _formKey = GlobalKey<FormState>();
  // 默认显示错误信息，在真实应用中应该根据表单验证结果设置
  bool _hasErrors = false;

  // 创建文本控制器，用于获取和设置各个输入框的值
  final TextEditingController _usernameController = TextEditingController(); // 用户名控制器
  final TextEditingController _passwordController = TextEditingController(); // 密码控制器
  final TextEditingController _confirmPasswordController = TextEditingController(); // 确认密码控制器
  final TextEditingController _emailController = TextEditingController(); // 电子邮箱控制器
  final TextEditingController _verificationCodeController = TextEditingController(); // 验证码控制器

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
      body: Center(
        child: Container(
          width: 540, // page宽度
          height: 960, // [age高度
          decoration: BoxDecoration(
            color: Colors.white // 背景颜色为白色
          ),
          child: SingleChildScrollView( // 添加滚动视图
            child: Padding(
              padding: const EdgeInsets.fromLTRB(60.0, 20.0, 60.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20), // 垂直间距

                // 返回按钮
                Align(
                  alignment: Alignment.centerLeft, // 左对齐
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white), // 返回图标
                    label: const Text('返回', style: TextStyle(color: Colors.white)), // 按钮文本
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3333AA), // 背景
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 45), // 垂直间距

                // 注册表单
                Form(
                  key: _formKey, // 关联表单key，用于表单验证
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 子组件左对齐
                    children: [
                      // 用户名输入区域
                      const Text('使用者帳號', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // 标签
                      const SizedBox(height: 5), // 间距
                      TextFormField( // 输入框
                        controller: _usernameController, // 关联控制器
                        decoration: InputDecoration(
                          filled: true, // 填充背景
                          fillColor: Colors.grey[200], // 背景颜色为浅灰色
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15), // 内容内边距
                        ),
                        // 可以添加验证器
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return '请输入用户名';
                        //   }
                        //   return null;
                        // },
                      ),
                      const SizedBox(height: 20), // 垂直间距

                      // 密码输入区域
                      const Text('使用者密碼', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // 标签
                      const SizedBox(height: 5), // 间距
                      TextFormField(
                        controller: _passwordController, // 关联控制器
                        obscureText: true, // 密码模式，文本显示为圆点
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 确认密码输入区域
                      const Text('再次確認密碼', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _confirmPasswordController, // 关联控制器
                        obscureText: true, // 密码模式
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                        // 可以添加验证器确保与密码一致
                        // validator: (value) {
                        //   if (value != _passwordController.text) {
                        //     return '两次输入的密码不一致';
                        //   }
                        //   return null;
                        // },
                      ),
                      const SizedBox(height: 20),

                      // 电子邮箱输入区域
                      const Text('電子信箱', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _emailController, // 关联控制器
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                        // 可以添加电子邮箱格式验证
                        // validator: (value) {
                        //   if (value == null || !value.contains('@')) {
                        //     return '请输入有效的电子邮箱';
                        //   }
                        //   return null;
                        // },
                      ),
                      const SizedBox(height: 20),

                      // 验证码输入区域和获取验证码按钮
                      const Text('驗證碼', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded( // 验证码输入框占据大部分空间
                            child: TextFormField(
                              controller: _verificationCodeController, // 关联控制器
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10), // 水平间距
                          // 获取验证码按钮
                          ElevatedButton(
                            onPressed: () {
                              // 获取验证码的逻辑
                              // 例如: _sendVerificationCode();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9C44), // 橙色背景
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15), // 内边距
                            ),
                            child: const Text('重新獲送', style: TextStyle(color: Colors.black)), // 按钮文本
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 错误提示区域，当_hasErrors为true时显示
                      if (_hasErrors)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
                          children: const [
                            // 各种错误信息，使用红色文字显示
                            Text('• 使用者帳號規範不正確', style: TextStyle(color: Colors.red, fontSize: 14)),
                            Text('• 使用者帳號已存在', style: TextStyle(color: Colors.red, fontSize: 14)),
                            Text('• 密碼規範不正確', style: TextStyle(color: Colors.red, fontSize: 14)),
                            Text('• 密碼與上面不同', style: TextStyle(color: Colors.red, fontSize: 14)),
                            Text('• 驗證碼錯誤', style: TextStyle(color: Colors.red, fontSize: 14)),
                          ],
                        ),
                      const SizedBox(height: 30),

                      // 注册按钮
                      Center( // 居中对齐
                        child: ElevatedButton(
                          onPressed: () {
                            // 表单验证通过后执行注册逻辑
                            if (_formKey.currentState!.validate()) {
                              // 执行注册逻辑
                              // 例如: _register();
                            }
                            //跳過驗證
                            handleRegister();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9C44), // 橙色背景
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), // 按钮内边距
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25), // 圆角形状
                            ),
                          ),
                          child: const Text('註冊', style: TextStyle(fontSize: 18, color: Colors.black)), // 按钮文本
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 问题链接
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // 处理问题的逻辑
                            // 例如: _handleProblem();
                          },
                          child: const Text(
                            '發生問題請點選此處', // 链接文本
                            style: TextStyle(color: Colors.black), // 文本样式
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
    ),
    );
  }
}