import 'package:flutter/material.dart';
import '../auth/sign_in.dart';

class PasswordResetPage extends StatefulWidget {
  final String userId; // 使用者帳號

  const PasswordResetPage({
    super.key,
    required this.userId,
  });

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordsNotMatch = false;
  bool _passwordTooShort = false;
  bool _passwordSameAsPrevious = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    // 重設錯誤狀態
    setState(() {
      _passwordsNotMatch = false;
      _passwordTooShort = false;
      _passwordSameAsPrevious = false;
    });

    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 驗證密碼
    if (newPassword.length < 8) {
      setState(() {
        _passwordTooShort = true;
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _passwordsNotMatch = true;
      });
      return;
    }

    // 模擬檢查是否與上一個密碼相同
    if (newPassword == "oldpassword") {  // 實際應用中需要後端驗證
      setState(() {
        _passwordSameAsPrevious = true;
      });
      return;
    }

    // 這裡應該有API調用來更新密碼

    // 若成功，返回登入頁面
    // 可以直接回到最初頁面，清除導航堆疊
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );

    // 這裡可加入提示密碼修改成功的彈窗
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('密碼修改成功！')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAEEF2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0055A7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // 使用者帳號
            const Text(
              '使用者帳號',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF0055A7),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.userId, // 動態顯示使用者ID
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // 新密碼
            const Text(
              '新使用者密碼',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF0055A7),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blue[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 30),

            // 再次確認密碼
            const Text(
              '再次確認密碼',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF0055A7),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blue[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),

            // 錯誤訊息
            if (_passwordTooShort)
              const Text(
                '* 密碼規範不正確',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            if (_passwordsNotMatch)
              const Text(
                '* 兩個密碼不同',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            if (_passwordSameAsPrevious)
              const Text(
                '* 密碼與前一次相同',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),

            const Spacer(),

            // 確認按鈕
            Center(
              child: ElevatedButton(
                onPressed: _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726), // 橙色按鈕
                  minimumSize: const Size(120, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  '確認',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 返回登入頁面提示
            const Center(
              child: Text(
                '點選即返回登入畫面',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}