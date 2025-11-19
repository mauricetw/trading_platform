import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishpool_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart'; // 1. 引入 CategoryProvider
import '../../models/product/category.dart';     // 引入 Category 模型 (假設路徑)

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

  // 2. 新增變數來儲存選中的分類 ID
  int? _selectedCategoryId;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 3. 進入頁面時，載入分類資料
    Future.microtask(() =>
        context.read<CategoryProvider>().fetchCategories()
    );
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
    // 確保有登入
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('建立願望')),
        body: const Center(child: Text('請先登入')),
      );
    }

    final wishPoolProvider = context.read<WishPoolProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('建立願望'),
        backgroundColor: const Color(0xFF004E98),
        foregroundColor: Colors.white,
      ),
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
                  hintText: '例如：二手計算機、大一微積分課本...',
                ),
                validator: (v) =>
                v == null || v.isEmpty ? '請輸入願望名稱' : null,
              ),
              const SizedBox(height: 16),

              // 4. 新增分類下拉選單
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  if (categoryProvider.isLoading) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ));
                  }

                  return DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: '商品分類 (可選)',
                      border: OutlineInputBorder(),
                    ),
                    items: categoryProvider.categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '願望描述',
                  border: OutlineInputBorder(),
                  hintText: '描述您希望的商品狀況、版本或其他細節...',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '最低預算 (可選)',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '最高預算 (可選)',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagCtrl,
                decoration: const InputDecoration(
                  labelText: '標籤',
                  border: OutlineInputBorder(),
                  hintText: '例如：課本, 電子產品 (以逗號分隔)',
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.add),
                  label: Text(
                    _isSubmitting ? '建立中...' : '建立願望',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004E98),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _isSubmitting = true);

                    try {
                      final body = {
                        'title': _titleCtrl.text.trim(),
                        'description': _descCtrl.text.trim(),
                        'price_min': int.tryParse(_minCtrl.text),
                        'price_max': int.tryParse(_maxCtrl.text),
                        // 5. 將選中的 category_id 加入 body
                        'category_id': _selectedCategoryId,
                        'tags': _tagCtrl.text.isNotEmpty
                            ? _tagCtrl.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList()
                            : [],
                      };

                      await wishPoolProvider.addWishPool(body);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('願望建立成功！')),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      debugPrint('建立願望失敗: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('建立失敗：$e'), backgroundColor: Colors.red),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isSubmitting = false);
                      }
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