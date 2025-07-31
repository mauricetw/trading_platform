import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'reset_password.dart';

class PasswordResetConfirmPage extends StatefulWidget {
  // --- 修正點：接收 loginIdentifier 而不是 userId ---
  final String loginIdentifier;

  const PasswordResetConfirmPage({Key? key, required this.loginIdentifier}) : super(key: key);

  @override
  State<PasswordResetConfirmPage> createState() => _PasswordResetConfirmPageState();
}

class _PasswordResetConfirmPageState extends State<PasswordResetConfirmPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    try {
      // --- 修正點：呼叫正確的 API 方法 ---
      final resetToken = await ApiService().verifyCode(
        widget.loginIdentifier,
        _codeController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PasswordResetPage(token: resetToken)),
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
      appBar: AppBar(title: const Text('輸入驗證碼')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('驗證碼已寄至您的信箱，請於下方輸入以繼續。', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: '6位數驗證碼', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.length != 6) ? '請輸入有效的6位數驗證碼' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleConfirm,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading ? const CircularProgressIndicator() : const Text('下一步'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}