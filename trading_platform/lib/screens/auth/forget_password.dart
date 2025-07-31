import 'package:flutter/material.dart';
import 'package:first_flutter_project/services/api_service.dart';
import 'package:first_flutter_project/screens/auth/reset_password_confirm.dart';

class AccountVerificationPage extends StatefulWidget {
  const AccountVerificationPage({super.key});

  @override
  State<AccountVerificationPage> createState() => _AccountVerificationPageState();
}

class _AccountVerificationPageState extends State<AccountVerificationPage> {
  final TextEditingController _accountController = TextEditingController();
  bool _showError = false;
  bool _isLoading = false;
  String _errorMessage = '';
  final ApiService apiService = ApiService();

  void _verifyAccountAndProceed() async {
    final account = _accountController.text.trim();

    if (account.isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = '請輸入使用者帳號或電子信箱';
      });
      return;
    }

    setState(() {
      _showError = false;
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 判斷輸入的是帳號還是信箱
      String loginField = account;

      // 呼叫忘記密碼 API
      final response = await apiService.forgotPassword(loginField);

      if (!mounted) return;

      if (response['success']) {
        // 成功：顯示成功訊息並跳轉到下一頁
        _showSuccessDialog();
      } else {
        // 失敗：顯示錯誤訊息
        setState(() {
          _showError = true;
          _errorMessage = response['error'] ?? '帳號或信箱不存在';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _showError = true;
        _errorMessage = '網路連線錯誤，請稍後再試';
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('發送成功'),
          content: const Text('密碼重設信件已發送到您的電子信箱，請查收。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PasswordResetPage(userId: _accountController.text.trim()),
                  ),
                );
              },
              child: const Text('確定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 540,
            height: 960,
            decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1)
            ),
            padding: const EdgeInsets.fromLTRB(45, 20, 45, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 返回按鈕
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, left: 16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text('返回', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ),

                // 標題
                const SizedBox(height: 100),
                const Text(
                  '輸入使用者帳號/電子信箱',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(0, 78, 152, 1),
                  ),
                ),

                // 輸入框
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _accountController,
                    enabled: !_isLoading, // 載入時禁用輸入
                    decoration: InputDecoration(
                      hintText: '輸入使用者帳號或電子信箱',
                      hintStyle: const TextStyle(
                          color: Color.fromRGBO(209, 241, 266, 0.5)
                      ),
                      filled: true,
                      fillColor: const Color.fromRGBO(0, 78, 152, 1),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      if (_showError) {
                        setState(() {
                          _showError = false;
                          _errorMessage = '';
                        });
                      }
                    },
                  ),
                ),

                // 錯誤訊息
                if (_showError && _errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                  ),

                // 說明文字
                if (!_showError)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 24, right: 24),
                    child: Text(
                      '我們會發送密碼重設連結到您的電子信箱',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // 確認按鈕
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyAccountAndProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      minimumSize: const Size(120, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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
                      '發送重設信件',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // 底部文字
                TextButton(
                  onPressed: _isLoading ? null : () {
                    // 重新發送邏輯
                    if (_accountController.text.trim().isNotEmpty) {
                      _verifyAccountAndProceed();
                    }
                  },
                  child: const Text(
                    '沒有收到？重新發送',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }
}