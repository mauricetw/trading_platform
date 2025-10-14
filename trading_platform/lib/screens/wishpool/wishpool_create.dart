import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishpool_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user/user.dart';

class WishPoolCreate extends StatefulWidget {
  const WishPoolCreate({super.key});

  @override
  State<WishPoolCreate> createState() => _WishPoolCreateState();
}

class _WishPoolCreateState extends State<WishPoolCreate> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser as User;
    final wishPoolProvider = context.read<WishPoolProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('建立願望')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: '願望名稱',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? '請輸入願望名稱' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '願望描述',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                      const InputDecoration(labelText: '最低價格 (可選)'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _maxCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                      const InputDecoration(labelText: '最高價格 (可選)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagCtrl,
                decoration: const InputDecoration(
                  labelText: '標籤（以逗號分隔）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(_isSubmitting ? '建立中...' : '建立願望'),
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _isSubmitting = true);

                    try {
                      final body = {
                        'user_id': currentUser.id,
                        'title': _titleCtrl.text.trim(),
                        'description': _descCtrl.text.trim(),
                        'price_min': int.tryParse(_minCtrl.text),
                        'price_max': int.tryParse(_maxCtrl.text),
                        'tags': _tagCtrl.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList(),
                      };

                      await wishPoolProvider.addWishPool(body);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('願望建立成功')),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      debugPrint('建立願望失敗: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('建立失敗：$e')),
                        );
                      }
                    } finally {
                      setState(() => _isSubmitting = false);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
