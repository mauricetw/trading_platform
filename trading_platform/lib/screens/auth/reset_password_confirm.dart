import 'package:first_flutter_project/screens/auth/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:first_flutter_project/api_service.dart';

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
  final TextEditingController _codeController = TextEditingController();
  String? _errorText;
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleNextStep() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorText = '驗證碼不可為空');
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    try {
      final response = await ApiService().verifyCode(int.parse(widget.userId), code);

      if (response['success']) {
        final token = response['token']; // 從後端取得的 token
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PasswordResetPage(token: token),
            ),
          );
        }
      } else {
        setState(() {
          _errorText = response['message'] ?? '驗證失敗';
        });
      }
    } catch (e) {
      setState(() {
        _errorText = '驗證失敗：$e';
      });
    } finally {
      setState(() => _isLoading = false);
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
              const Text(
                '輸入驗證碼',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0E5DA5)),
              ),
              const SizedBox(height: 8),

              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E5DA5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: _codeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    hintText: '請輸入驗證碼',
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  onChanged: (_) {
                    if (_errorText != null) {
                      setState(() => _errorText = null);
                    }
                  },
                ),
              ),

              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const Spacer(),

              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7913E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: const Size(120, 44),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    '下一步',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    // 加入重發驗證碼的功能（如有）
                  },
                  child: const Text(
                    '沒有收到？重發郵件',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
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