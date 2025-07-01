import 'package:flutter/material.dart';
import 'package:first_flutter_project/api_service.dart';

class PasswordResetPage extends StatefulWidget {
  final String token; // 這是從驗證碼步驟傳入的 token

  const PasswordResetPage({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordsNotMatch = false;
  bool _passwordTooShort = false;
  bool _isLoading = false;
  bool _passwordSameAsPrevious = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() async {
    if (_isLoading) return; // 避免重複提交

    // 重設錯誤狀態
    setState(() {
      _passwordsNotMatch = false;
      _passwordTooShort = false;
    });

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

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

    setState(() => _isLoading = true);

    // 模擬檢查是否與上一個密碼相同
    /*
    if (newPassword == "oldpassword") {  // 實際應用中需要後端驗證
      setState(() {
        _passwordSameAsPrevious = true;
      });
      return;
    }
    */

    // 這裡應該有API調用來更新密碼
    try {
      final api = ApiService();
      await api.resetPassword(widget.token, newPassword);

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('密碼修改成功！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('重設密碼失敗：$e')),
        );
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
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 45,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0055A7),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 16,
                ),
                Text(
                  '返回',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        leadingWidth: 100, // 提供足夠的空間給返回按鈕
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(50, 45, 50, 45),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // 驗證 Token 顯示
            const Text(
              '驗證憑證（Token）',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF0055A7),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.token, // 動態顯示使用者ID
              style: const TextStyle(
                fontSize: 12, // Token 通常很長，改成較小字體
                fontWeight: FontWeight.w400,
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
                onPressed: _isLoading ? null : _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726), // 橙色按鈕
                  minimumSize: const Size(120, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
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