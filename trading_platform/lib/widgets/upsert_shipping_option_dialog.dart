// --- FILE: lib/widgets/upsert_shipping_option_dialog.dart ---
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // 1. 引入 Provider

import '../models/user/shipping_option.dart';
import '../services/order_service.dart'; // 2. 引入我們真實的 OrderService

class UpsertShippingOptionDialog extends StatefulWidget {
  // 3. 不再需要從外部傳入 Service，我們將從 Provider 獲取
  final ShippingOption? shippingOption; // null if adding new, existing if editing

  const UpsertShippingOptionDialog({
    super.key,
    this.shippingOption,
  });

  @override
  State<UpsertShippingOptionDialog> createState() => _UpsertShippingOptionDialogState();
}

class _UpsertShippingOptionDialogState extends State<UpsertShippingOptionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _costController;
  late TextEditingController _descriptionController;
  late bool _isEnabled;

  bool _isSubmitting = false;
  String _dialogTitle = '新增運送方式';

  @override
  void initState() {
    super.initState();
    final option = widget.shippingOption;

    _nameController = TextEditingController(text: option?.name ?? '');
    _costController = TextEditingController(
      text: option != null ? option.cost.toStringAsFixed(option.cost.truncateToDouble() == option.cost ? 0 : 2) : '',
    );
    _descriptionController = TextEditingController(text: option?.description ?? '');
    _isEnabled = option?.isEnabled ?? true;

    if (option != null) {
      _dialogTitle = '編輯運送方式';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    // 4. 從 Provider 體系中安全地獲取 OrderService 實例
    final orderService = context.read<OrderService>();

    try {
      final double cost = double.parse(_costController.text.trim());

      // 5. 準備要傳送到後端的資料 (一個 Map)
      final Map<String, dynamic> dataToSave = {
        'name': _nameController.text.trim(),
        'cost': cost,
        'description': _descriptionController.text.trim(),
        'is_enabled': _isEnabled,
      };

      ShippingOption result;
      if (widget.shippingOption == null) { // 新增模式
        result = await orderService.addShippingOption(dataToSave);
      } else { // 更新模式
        result = await orderService.updateShippingOption(widget.shippingOption!.id, dataToSave);
      }

      if (mounted) {
        Navigator.of(context).pop(result); // 返回更新/建立後的物件，通知前一頁刷新
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.shippingOption == null ? "新增" : "更新"}失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // (UI 部分的程式碼保持您組員的設計，無需修改)
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(_dialogTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '運送方式名稱 *',
                  hintText: '例如：7-11 超商取貨',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入運送方式名稱';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: '運費 *',
                  hintText: '例如：60',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入運費';
                  }
                  final cost = double.tryParse(value.trim());
                  if (cost == null || cost < 0) {
                    return '請輸入有效的運費金額';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述 (選填)',
                  hintText: '例如：支援本島所有7-11門市',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('啟用此運送方式', style: Theme.of(context).textTheme.titleMedium),
                  Switch(
                    value: _isEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _isEnabled = value;
                      });
                    },
                    activeColor: colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        if (_isSubmitting)
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircularProgressIndicator(strokeWidth: 3),
          )
        else ...[
          TextButton(
            child: const Text('取消'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary),
            onPressed: _submitForm,
            child: const Text('儲存'),
          ),
        ],
      ],
    );
  }
}
