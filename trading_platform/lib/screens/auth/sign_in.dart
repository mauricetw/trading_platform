import 'package:first_flutter_project/screens/auth/forget_password.dart';
import 'package:flutter/material.dart';
import 'package:first_flutter_project/services/api_service.dart';  // 確保這個路徑正確
import 'package:shared_preferences/shared_preferences.dart';
import 'package:first_flutter_project/screens/main_market.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '登入系統',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SignInPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _usernameError = '';
  String _passwordError = '';
  String _serverError = '';
  final ApiService apiService = ApiService();  // 使用新的 ApiService

  bool _isLoading = false;
  bool _hasAttemptedLogin = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      _hasAttemptedLogin = true;
      _usernameError = _usernameController.text.isEmpty ? '使用者帳號不能為空' : '';
      _passwordError = _passwordController.text.isEmpty ? '密碼不能為空' : '';
      _serverError = '';
    });

    if (_usernameError.isEmpty && _passwordError.isEmpty) {
      _login();
    }
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    String identifier = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    try {
      final response = await apiService.login(identifier, password);

      if (response["success"]) {
        Map<String, dynamic> data = response["data"];

        // 根據後端的實際回應結構調整這裡
        String token = data["access_token"] ?? data["token"] ?? "No token";

        print("Login Successful! Token: $token");
        print("Response data: $data");

        // 儲存 Token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Successful!")),
          );

          // 跳轉到主頁面
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainMarket()),
          );
        }
      } else {
        // 處理登入失敗
        if (mounted) {
          setState(() {
            String errorMessage = response["error"] ?? "Login failed.";
            if (errorMessage.contains("用戶") || errorMessage.contains("帳號")) {
              _serverError = "使用者帳號不存在";
            } else if (errorMessage.contains("密碼")) {
              _serverError = "密碼錯誤";
            } else {
              _serverError = errorMessage;
            }
          });
        }
      }
    } catch (e) {
      print("Login failed: $e");
      if (mounted) {
        setState(() {
          _serverError = "登入失敗，請稍後再試";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(0, 78, 150, 1),
        child: SafeArea(
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width > 540 ? 540 : MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(45, 20, 45, 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 返回按鈕
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.arrow_back,
                                      color: Color.fromRGBO(0, 78, 150, 1)),
                                  label: const Text('返回', style: TextStyle(
                                      color: Color.fromRGBO(0, 78, 150, 1))),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromRGBO(
                                        61, 255, 258, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
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
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                      const AccountVerificationPage()),
                                    );
                                  },
                                  child: const Text(
                                    '忘記密碼了嗎?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),

                                // 錯誤訊息
                                if (_hasAttemptedLogin && _usernameError.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '*$_usernameError',
                                      style: const TextStyle(
                                          color: Colors.greenAccent, fontSize: 12),
                                    ),
                                  ),
                                if (_hasAttemptedLogin && _passwordError.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      '*$_passwordError',
                                      style: const TextStyle(
                                          color: Colors.greenAccent, fontSize: 12),
                                    ),
                                  ),

                                const SizedBox(height: 20),

                                // 服務器錯誤信息
                                if (_serverError.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      '*$_serverError',
                                      style: const TextStyle(
                                          color: Color.fromRGBO(61, 255, 258, 1),
                                          fontSize: 12),
                                    ),
                                  ),

                                // 使用 Spacer 來推送登入按鈕到底部
                                const Spacer(),

                                // 登入按鈕
                                Center(
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _validateInputs,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF9238),
                                      minimumSize: const Size(90, 45),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22.0),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                        : const Text(
                                      '登入',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // 底部提示
                                const Center(
                                  child: Text(
                                    '發生問題請點此處',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}