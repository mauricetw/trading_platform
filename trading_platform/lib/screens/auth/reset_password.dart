import 'package:flutter/material.dart';
import 'reset_password_confirm.dart';
import 'package:first_flutter_project/api_service.dart';

class AccountVerificationPage extends StatefulWidget {
  const AccountVerificationPage({Key? key}) : super(key: key);

  @override
  State<AccountVerificationPage> createState() => _AccountVerificationPageState();
}

class _AccountVerificationPageState extends State<AccountVerificationPage> {
  final TextEditingController _accountController = TextEditingController();
  bool _showError = false;


  void _verifyAccountAndProceed() async {
    final account = _accountController.text.trim();
    final ApiService apiService = ApiService();

    if (account.isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    }

    setState(() {
      _showError = false;
    });

    try {
      await apiService.forgotPassword(account);

      // 顯示成功訊息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('驗證信已發送至 $account，請檢查您的信箱。')),
      );

    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('無法發送驗證信：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1), // 淺灰色背景
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
                        // 返回上一頁
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text('返回', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1), // 深藍色按鈕
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
                      // 當輸入改變時，重設錯誤訊息
                      if (_showError) {
                        setState(() {
                          _showError = false;
                        });
                      }
                    },
                  ),
                ),

                // 錯誤訊息
                if (_showError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '*帳號不存在',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                          Text(
                            '*電子信箱未註冊',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 確認按鈕
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: ElevatedButton(
                    onPressed: _verifyAccountAndProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800), // 橙色按鈕
                      minimumSize: const Size(120, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      '確認',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // 底部文字
                const Text(
                  '沒有收到？重新發送',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
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