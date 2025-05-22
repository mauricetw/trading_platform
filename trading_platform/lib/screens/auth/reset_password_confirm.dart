import 'package:first_flutter_project/screens/auth/reset_password.dart';
import 'package:flutter/material.dart';

class PasswordResetConfirmPage extends StatefulWidget {
  final String userId;

  const PasswordResetConfirmPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<PasswordResetConfirmPage> createState() => _PasswordResetPageConfirmState();
}

class _PasswordResetPageConfirmState extends State<PasswordResetConfirmPage> {
  final TextEditingController _passwordController = TextEditingController();
  String? _passwordError;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordError = "驗證碼錯誤";
      });
    } else {
      setState(() {
        _passwordError = null;
      });
    }
  }

  void _handleNextStep() {
    _validatePassword(_passwordController.text);
    if (_passwordError == null) {
      // 處理下一步邏輯
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordResetPage(
            userId: widget.userId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // 使用淺藍灰色背景
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(50, 45, 50, 45),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 返回按鈕
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E5DA5), // 深藍色按鈕
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(80, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chevron_left, color: Colors.white, size: 20),
                    Text(
                      '返回',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 使用者編號標題
              const Text(
                '使用者編號',
                style: TextStyle(
                  color: Color(0xFF0E5DA5), // 深藍色文字
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // 使用者編號
              Text(
                widget.userId,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // 輸入驗證碼標題
              const Text(
                '輸入驗證碼',
                style: TextStyle(
                  color: Color(0xFF0E5DA5), // 深藍色文字
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // 驗證碼輸入框
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E5DA5), // 深藍色背景
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    hintText: '',
                  ),
                  onChanged: (value) {
                    // 清除錯誤提示
                    if (_passwordError != null) {
                      setState(() {
                        _passwordError = null;
                      });
                    }
                  },
                ),
              ),

              // 錯誤提示
              if (_passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _passwordError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),

              // 填充空間
              const Spacer(),

              // 下一步按鈕
              Center(
                child: ElevatedButton(
                  onPressed: _handleNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7913E), // 橙色按鈕
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(120, 44),
                  ),
                  child: const Text(
                    '下一步',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 沒有收到郵件提示
              Center(
                child: TextButton(
                  onPressed: () {
                    // 重發郵件邏輯
                  },
                  child: const Text(
                    '沒有收到？重發郵件',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// 示範用的主應用
class PasswordResetConfirmApp extends StatelessWidget {
  const PasswordResetConfirmApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 移除debug標籤
      title: '密碼重置',
      theme: ThemeData(
        primaryColor: const Color(0xFF0E5DA5), // 主題色為深藍色
        scaffoldBackgroundColor: const Color(0xFFE4E6EC), // 底色為淺藍灰色
      ),
      home: const PasswordResetConfirmPage(userId: '123456'),
    );
  }
}

void main() {
  runApp(const PasswordResetConfirmApp());
}