// --- FILE: lib/screens/settings/address_form_screen.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user/address.dart';
import '../../providers/address_provider.dart';

class AddressFormScreen extends StatefulWidget {
  // 1. 接收一個可選的地址物件
  // - 如果是 null，代表是「新增」模式
  // - 如果不是 null，代表是「編輯」模式
  final Address? addressToEdit;

  const AddressFormScreen({super.key, this.addressToEdit});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // 2. 為所有欄位建立 Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _postalCodeController;
  late TextEditingController _cityController;
  late TextEditingController _street1Controller;
  late TextEditingController _street2Controller;
  bool _isDefault = false;

  bool get _isEditing => widget.addressToEdit != null;

  @override
  void initState() {
    super.initState();

    // 3. 初始化 Controllers
    final address = widget.addressToEdit;
    _nameController = TextEditingController(text: address?.recipientName ?? '');
    _phoneController = TextEditingController(text: address?.phoneNumber ?? '');
    _postalCodeController = TextEditingController(text: address?.postalCode ?? '');
    _cityController = TextEditingController(text: address?.city ?? '');
    _street1Controller = TextEditingController(text: address?.streetAddress1 ?? '');
    _street2Controller = TextEditingController(text: address?.streetAddress2 ?? '');
    _isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _street1Controller.dispose();
    _street2Controller.dispose();
    super.dispose();
  }

  // 4. 儲存表單
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // 表單驗證失敗
    }

    setState(() { _isLoading = true; });

    // 5. 將所有資料打包成 Map<String, dynamic>
    //    這與後端的 AddressCreate 和 AddressUpdate schema 相符
    final addressData = {
      "recipient_name": _nameController.text.trim(),
      "phone_number": _phoneController.text.trim(),
      "postal_code": _postalCodeController.text.trim(),
      "city": _cityController.text.trim(),
      "street_address_1": _street1Controller.text.trim(),
      "street_address_2": _street2Controller.text.trim().isEmpty ? null : _street2Controller.text.trim(),
      "is_default": _isDefault,
      // (country, province, district 等欄位可以稍後再加入)
    };

    try {
      final provider = context.read<AddressProvider>();
      if (_isEditing) {
        // 更新
        await provider.updateAddress(widget.addressToEdit!.id, addressData);
      } else {
        // 新增
        await provider.addAddress(addressData);
      }

      if (mounted) {
        Navigator.pop(context); // 成功後返回上一頁
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? '地址已更新' : '地址已新增'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('儲存失敗: $e'), backgroundColor: Colors.red),
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
      appBar: AppBar(
        title: Text(_isEditing ? '編輯地址' : '新增地址'),
      ),
      body: AbsorbPointer(
        absorbing: _isLoading,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_nameController, '收件人姓名', '請輸入姓名'),
                _buildTextField(_phoneController, '手機號碼', '請輸入手機號碼', keyboardType: TextInputType.phone),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_postalCodeController, '郵遞區號', '請輸入郵遞區號', keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_cityController, '城市/地區', '例如：台北市')),
                  ],
                ),
                _buildTextField(_street1Controller, '詳細地址', '請輸入街道名稱和門牌號碼'),
                _buildTextField(_street2Controller, '詳細地址 2 (可選)', '', isRequired: false),

                SwitchListTile(
                  title: const Text('設為預設地址'),
                  value: _isDefault,
                  onChanged: (bool value) {
                    setState(() { _isDefault = value; });
                  },
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 32),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('儲存地址'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 輔助函式：建立 TextFormField
  Widget _buildTextField(
      TextEditingController controller,
      String labelText,
      String validationError, {
        TextInputType keyboardType = TextInputType.text,
        bool isRequired = true,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return validationError;
          }
          return null;
        },
      ),
    );
  }
}