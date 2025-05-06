import 'package:first_flutter_project/screens/auth/reset_password.dart';
import 'package:flutter/material.dart';
import '../auth/login_main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '登入系統',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SignInPage(),
      debugShowCheckedModeBanner: true,
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _usernameError = '';
  String _passwordError = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      _usernameError = _usernameController.text.isEmpty ? '使用者帳號不存在' : '';
      _passwordError = _passwordController.text.isEmpty ? '密碼錯誤' : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[300],
        child: Center(
          child: Container(
            width: 540,
            height: 960,
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 78, 150, 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(45, 20, 45, 20),
                  alignment: Alignment.centerLeft,
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(45, 20, 45, 20),
                  color: Color.fromRGBO(0, 78, 150, 1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 返回按鈕
                      Container(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(0, 78, 150, 1)), // 返回图标
                          label: const Text('返回', style: TextStyle(color: Color.fromRGBO(0, 78, 150, 1))), // 按钮文本
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(61, 255, 258, 1), // 背景
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),

                      // 使用者帳號
                      const Text(
                        '使用者帳號',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 12.0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20.0),

                      // 使用者密碼
                      const Text(
                        '使用者密碼',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 12.0,
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ResetPasswordPage()),);
                        },
                        child:Text(
                            '忘記密碼了嗎?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      // 錯誤訊息
                      if (_usernameError.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '*$_usernameError',
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                          ),
                        ),
                      if (_passwordError.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '*$_passwordError',
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                          ),
                        ),

                      const SizedBox(height: 20),

                      const Text(
                        '*使用者帳號不存在',
                        style: TextStyle(color: Color.fromRGBO(61, 255, 258, 1), fontSize: 12),
                      ),

                      const Text(
                        '*密碼錯誤',
                        style: TextStyle(color: Color.fromRGBO(61, 255, 258, 1), fontSize: 12),
                      ),

                      const SizedBox(height: 260),

                      // 登入按鈕
                      Center(
                        child: ElevatedButton(
                          onPressed: _validateInputs,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9238),
                            minimumSize: const Size(90, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.0),
                            ),
                          ),
                          child: const Text(
                            '登入',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 忘記密碼
                      const Center(
                        child: Text(
                          '發生問題請點此處',
                          style: TextStyle(color: Colors.white, fontSize: 12),
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