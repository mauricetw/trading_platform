import 'package:flutter/material.dart';
import '../../api_service.dart';
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

  Future<void> _handleVerification() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    final account = _accountController.text.trim();
    try {
      await ApiService().forgotPassword(account);
      if (mounted) {
        // --- 修正點：將 identifier 傳遞到下一頁 ---
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordResetConfirmPage(loginIdentifier: account),
          ),
        );
      }
    } catch (e) {
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
    return Scaffold(
      appBar: AppBar(title: const Text('驗證帳號')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('請輸入您的使用者帳號或電子信箱，我們將會寄送驗證碼給您。', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextFormField(
                controller: _accountController,
                decoration: const InputDecoration(
                  labelText: '使用者帳號或電子信箱',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty) ? '欄位不能為空' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleVerification,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading ? const CircularProgressIndicator() : const Text('發送驗證碼'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}