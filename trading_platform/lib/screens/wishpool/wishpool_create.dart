import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishpool_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/address_provider.dart';
import '../../models/user/address.dart';

class WishPoolCreate extends StatefulWidget {
  const WishPoolCreate({super.key});

  @override
  State<WishPoolCreate> createState() => _WishPoolCreateState();
}

class _WishPoolCreateState extends State<WishPoolCreate> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _tagCtrl = TextEditingController();

  int? _selectedCategoryId;
  int? _selectedAddressId;

  final List<Map<String, dynamic>> _shippingMethods = [
    {'name': '標準配送', 'cost': 60.0},
    {'name': '郵局寄送', 'cost': 80.0},
    {'name': '面交', 'cost': 0.0},
  ];

  late Map<String, dynamic> _selectedShipping;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedShipping = _shippingMethods[0];

    Future.microtask(() {
      context.read<CategoryProvider>().fetchCategories();
      context.read<AddressProvider>().fetchAddresses();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  return DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: '商品分類 (可選)',
                      border: OutlineInputBorder(),
                    ),
                    items: categoryProvider.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
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
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '期望價格',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null) ? '請輸入價格' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '數量', border: OutlineInputBorder()),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return (n == null || n < 1) ? '至少為 1' : null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedShipping,
                decoration: const InputDecoration(
                  labelText: '偏好運送方式',
                  border: OutlineInputBorder(),
                ),
                items: _shippingMethods.map((method) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: method,
                    child: Text('${method['name']} (\$${method['cost']})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedShipping = value!;
                  });
                },
              ),

              const SizedBox(height: 16),
              Consumer<AddressProvider>(
                builder: (context, addressProvider, child) {
                  Address? defaultAddress;
                  try {
                    defaultAddress = addressProvider.addresses.firstWhere((a) => a.isDefault);
                  } catch (e) {
                    if (addressProvider.addresses.isNotEmpty) {
                      defaultAddress = addressProvider.addresses.first;
                    }
                  }

                  if (defaultAddress == null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('請至個人中心新增地址')),
                            );
                            // 若有路由可直接跳轉，例如： Navigator.pushNamed(context, '/address');
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(child: Text('您尚未設定收貨地址，無法建立願望。請先新增地址。', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: null,
                            child: Text('請先設定地址'),
                          ),
                        ),
                      ],
                    );
                  }

                  // 顯示地址
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('將寄送至預設地址：', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('${defaultAddress.recipientName} (${defaultAddress.phoneNumber})', style: const TextStyle(fontWeight: FontWeight.bold)),

                            // --- [BUG 修正] 使用 displayAddress，避免 null 顯示 ---
                            // defaultAddress.displayAddress 已經處理好 null 的過濾與拼接
                            Text(defaultAddress.displayAddress),
                          ],
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
                          label: Text(_isSubmitting ? '建立中...' : '建立願望', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004E98), foregroundColor: Colors.white),
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                            if (!_formKey.currentState!.validate()) return;

                            setState(() => _isSubmitting = true);
                            try {
                              final body = {
                                'title': _titleCtrl.text.trim(),
                                'description': _descCtrl.text.trim(),
                                'price': int.parse(_priceCtrl.text),
                                'quantity': int.parse(_qtyCtrl.text),
                                'category_id': _selectedCategoryId,
                                'address_id': defaultAddress!.id,
                                'shipping_name': _selectedShipping['name'],
                                'shipping_cost': _selectedShipping['cost'],
                                'tags': _tagCtrl.text.isNotEmpty
                                    ? _tagCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                                    : [],
                              };
                              await wishPoolProvider.addWishPool(body);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('願望建立成功！')));
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('建立失敗：$e'), backgroundColor: Colors.red));
                            } finally {
                              if (mounted) setState(() => _isSubmitting = false);
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}