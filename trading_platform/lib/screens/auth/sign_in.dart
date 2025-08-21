import 'package:first_flutter_project/screens/auth/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:first_flutter_project/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:first_flutter_project/screens/main_market.dart';
import 'package:first_flutter_project/models/user/user.dart'; // 添加 User 模型導入

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
  String _serverError = ''; // 新增服務器錯誤信息
  final ApiService apiService = ApiService();

  bool _isLoading = false;
  bool _hasAttemptedLogin = false; // 追蹤是否已嘗試登入

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      _hasAttemptedLogin = true; // 標記已嘗試登入
      _usernameError = _usernameController.text.isEmpty ? '使用者帳號不能為空' : '';
      _passwordError = _passwordController.text.isEmpty ? '密碼不能為空' : '';
      _serverError = ''; // 清除服務器錯誤信息
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
        String token = data["token"] ?? "No token";

        // 移除生產環境的 print 語句
        // debugPrint("Login Successful! Token: $token");

        final userId = data["id"];
        // debugPrint(userId.toString());

        // 儲存 Token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // 創建用戶對象 - 從API響應中獲取用戶資料
        final User currentUser = User(
          id: userId is String ? int.tryParse(userId) ?? 0 : userId as int, // 處理可能的類型轉換
          username: data["username"] ?? identifier, // 使用API返回的用戶名，如果沒有則使用輸入的標識符
          email: data["email"] ?? "${identifier}@example.com", // 使用API返回的郵箱，如果沒有則生成一個
          registeredAt: DateTime.now(), // 如果API沒有返回，使用當前時間
          isVerified: data["is_verified"] ?? false,
          roles: data["roles"] != null ? List<String>.from(data["roles"]) : ['user'],
          isSeller: data["is_seller"] ?? false,
          productCount: data["product_count"] ?? 0,
          // 其他可選字段
          phoneNumber: data["phone_number"],
          avatarUrl: data["avatar_url"],
          lastLoginAt: DateTime.now(),
          bio: data["bio"],
          schoolName: data["school_name"],
          sellerName: data["seller_name"],
          sellerDescription: data["seller_description"],
          sellerRating: data["seller_rating"]?.toDouble(),
          buyerRating: data["buyer_rating"]?.toDouble(),
          favoriteProductIds: data["favorite_product_ids"] != null
              ? List<String>.from(data["favorite_product_ids"])
              : [],
          publicDisplayName: data["public_display_name"],
          publicBio: data["public_bio"],
          publicCoverPhotoUrl: data["public_cover_photo_url"],
          isSchoolPublic: data["is_school_public"] ?? false,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Successful!")),
          );

          // 跳轉到主頁面，傳入當前用戶
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainMarket(currentUser: currentUser), // 傳入用戶對象
            ),
          );
        }
      } else {
        // 設置服務器錯誤信息
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
      // debugPrint("Login failed: $e");
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

                                // 錯誤訊息 - 只有在嘗試登入後才顯示
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

                                // 服務器錯誤信息 - 只有在有錯誤時才顯示
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

                                // 登入按鈕，增加了載入狀態
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

                                // 忘記密碼
                                const Center(
                                  child: Text(
                                    '發生問題請點此處',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),

                                const SizedBox(height: 20), // 底部間距
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