// --- FILE: lib/screens/auth/forget_password.dart ---
import 'package:flutter/material.dart';
import '../../services/api_service.dart'; // 確保路徑正確
import 'reset_password_confirm.dart';

class AccountVerificationPage extends StatefulWidget {
  const AccountVerificationPage({Key? key}) : super(key: key);

  @override
  State<AccountVerificationPage> createState() => _AccountVerificationPageState();
}

class _AccountVerificationPageState extends State<AccountVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  // --- 邏輯整合：使用你的 API 呼叫邏輯 ---
  Future<void> _handleVerification() async {
    // 點擊按鈕時，收起鍵盤並進行表單驗證
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    final account = _accountController.text.trim();
    try {
      // 呼叫真實的 API
      await ApiService().forgotPassword(account);

      if (mounted) {
        // 成功後，導航到驗證碼頁面，並傳遞使用者帳號
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordResetConfirmPage(loginIdentifier: account),
          ),
        );
      }
    } catch (e) {
      // 顯示 API 回傳的錯誤訊息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- UI 整合：使用你組員設計的 UI 介面 ---
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('忘記密碼'),
        backgroundColor: const Color(0xFF004E98),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '輸入使用者帳號或電子信箱',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004E98),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _accountController,
                    decoration: InputDecoration(
                      hintText: '使用者帳號或電子信箱',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '欄位不能為空';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : const Text('發送驗證碼'),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      // TODO: 實作重新發送的邏輯
                    },
                    child: const Text(
                      '沒有收到？重新發送',
                      style: TextStyle(color: Colors.black54),
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
