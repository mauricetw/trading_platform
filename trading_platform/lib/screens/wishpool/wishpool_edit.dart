import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishpool_provider.dart';
import '../../models/wishpool/wishpool.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';

class WishPoolEdit extends StatefulWidget {
  final WishPool wish;
  const WishPoolEdit({super.key, required this.wish});

  @override
  State<WishPoolEdit> createState() => _WishPoolEditState();
}

class _WishPoolEditState extends State<WishPoolEdit> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;
  late TextEditingController _tagCtrl;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final wish = widget.wish;
    _titleCtrl = TextEditingController(text: wish.title);
    _descCtrl = TextEditingController(text: wish.description ?? '');
    _minCtrl = TextEditingController(text: wish.priceMin?.toString() ?? '');
    _maxCtrl = TextEditingController(text: wish.priceMax?.toString() ?? '');
    _tagCtrl = TextEditingController(text: wish.tags?.join(', ') ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WishPoolProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('編輯願望', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF004E98),
        shape: const FullBottomConcaveAppBarShape(curveHeight: 25.0),
        elevation: 6.0,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
                      decoration: const InputDecoration(labelText: '最低價格'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _maxCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '最高價格'),
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
                  icon: const Icon(Icons.save),
                  label: Text(_isSubmitting ? '儲存中...' : '儲存修改'),
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _isSubmitting = true);

                    final body = {
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

                    try {
                      await provider.updateWishPool(widget.wish.id, body);

                      if (context.mounted) {
                        await showDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierColor: Colors.black54,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 60),
                                  SizedBox(height: 12),
                                  Text(
                                    '願望已更新！',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 8),
                                  Text('點擊任意地方關閉',
                                      style:
                                      TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      debugPrint('更新願望失敗: $e');
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
