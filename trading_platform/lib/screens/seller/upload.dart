// --- FILE: lib/screens/seller/upload.dart (UI 還原 + 邏輯串接最終版) ---
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/product/product.dart';
import '../../models/product/category.dart';
import '../../providers/product_provider.dart';

class ProductUploadPage extends StatefulWidget {
  final Product? productToEdit;

  const ProductUploadPage({
    super.key,
    this.productToEdit,
  });

  @override
  State<ProductUploadPage> createState() => _ProductUploadPageState();
}

class _ProductUploadPageState extends State<ProductUploadPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;

  final List<XFile> _imageFiles = [];
  final List<String> _imageUrls = [];

  int? _selectedCategoryId;
  String _selectedCondition = '';
  String _selectedType = '';

  final List<String> _conditions = ['全新', '近全新', '良好', '普通', '需要維修'];
  final List<String> _types = ['一般商品', '限時特價', '二手商品', '收藏品', '手作商品'];

  bool _isLoading = false;
  bool get _isEditMode => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _quantityController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _originalPriceController = TextEditingController();

    // 如果是編輯模式，用傳入的商品資料初始化表單
    if (_isEditMode && widget.productToEdit != null) {
      final product = widget.productToEdit!;
      _nameController.text = product.name;
      _descriptionController.text = product.description ?? '';
      _priceController.text = product.price.toStringAsFixed(0);
      _originalPriceController.text = product.originalPrice?.toStringAsFixed(0) ?? '';
      _quantityController.text = product.stockQuantity.toString();
      _imageUrls.addAll(product.imageUrls);
      _selectedCategoryId = product.categoryId;

      if (product.tags != null) {
        for (String tag in product.tags!) {
          if (_conditions.contains(tag)) _selectedCondition = tag;
          if (_types.contains(tag)) _selectedType = tag;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    super.dispose();
  }

  // --- 響應式 UI 輔助方法 (已還原) ---
  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = 1.0;
    if (screenWidth < 360) {
      scaleFactor = 0.85;
    } else if (screenWidth < 600) {
      scaleFactor = 1.0;
    } else if (screenWidth < 900) {
      scaleFactor = 1.1;
    } else {
      scaleFactor = 1.2;
    }
    return baseSize * scaleFactor;
  }

  double _getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseSpacing * 0.8;
    if (screenWidth < 600) return baseSpacing;
    if (screenWidth < 900) return baseSpacing * 1.2;
    return baseSpacing * 1.5;
  }

  double _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return 12.0;
    if (screenWidth < 600) return 16.0;
    if (screenWidth < 900) return 20.0;
    return 24.0;
  }

  // --- 圖片處理 (已串接 Provider) ---
  Future<void> _selectImage() async {
    if (_imageFiles.length + _imageUrls.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('最多只能選擇 5 張圖片')));
      return;
    }
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() {
        _imageFiles.addAll(images);
      });
    }
  }

  void _removeLocalImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  void _removeUrlImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  // --- 完成上傳/更新 (已串接 Provider) ---
  Future<void> _completeUpload() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('請修正表單中的錯誤後再提交'), backgroundColor: Colors.orange));
      return;
    }
    if (_imageFiles.isEmpty && _imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('請至少上傳一張商品圖片'), backgroundColor: Colors.red));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final productProvider = context.read<ProductProvider>();

      List<String> newImageUrls = [];
      for (final imageFile in _imageFiles) {
        final imageUrl = await productProvider.uploadProductImage(File(imageFile.path));
        newImageUrls.add(imageUrl);
      }

      final List<String> finalImageUrls = [..._imageUrls, ...newImageUrls];

      final Map<String, dynamic> productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'original_price': _originalPriceController.text.trim().isEmpty ? null : double.parse(_originalPriceController.text.trim()),
        'stock_quantity': int.parse(_quantityController.text.trim()),
        'category_id': _selectedCategoryId,
        'tags': [_selectedCondition, _selectedType].where((t) => t.isNotEmpty).toList(),
        'image_urls': finalImageUrls,
      };

      if (_isEditMode) {
        await productProvider.updateProduct(widget.productToEdit!.id, productData);
      } else {
        await productProvider.addProduct(productData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('商品${_isEditMode ? "更新" : "上傳"}成功！'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失敗: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = _getResponsivePadding(context);
    final spacing = _getResponsiveSpacing(context, 16.0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: _getResponsiveFontSize(context, 24)),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? '編輯商品' : '上傳新商品',
          style: TextStyle(color: Colors.black87, fontSize: _getResponsiveFontSize(context, 18), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: AbsorbPointer(
        absorbing: _isLoading,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('商品圖片 (第一張為主圖，最多5張)'),
                _buildImageUploadSection(context),
                SizedBox(height: spacing),

                _buildSectionTitle('商品名稱'),
                _buildProductNameSection(context),
                SizedBox(height: spacing),

                _buildSectionTitle('商品類別'),
                _buildCategoryDropdownSection(context),
                SizedBox(height: spacing),

                _buildSectionTitle('商品狀態'),
                _buildConditionDropdownSection(context),
                SizedBox(height: spacing),

                _buildSectionTitle('商品類型'),
                _buildTypeDropdownSection(context),
                SizedBox(height: spacing),

                _buildSectionTitle('商品描述'),
                _buildDescriptionSection(context),
                SizedBox(height: spacing),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('價格設定 (NT\$)'),
                          _buildPriceSection(context),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('庫存數量'),
                          _buildQuantitySection(context),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing),

                SizedBox(height: spacing * 2),
                _buildActionButtons(context),

                if (_isLoading) ...[
                  SizedBox(height: spacing),
                  const Center(child: CircularProgressIndicator()),
                  const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("正在處理中，請稍候..."),
                  )),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Builder Widgets (已還原) ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: _getResponsiveSpacing(context, 8)),
      child: Text(
        title,
        style: TextStyle(fontSize: _getResponsiveFontSize(context, 16), fontWeight: FontWeight.w500, color: Colors.black87),
      ),
    );
  }

  Widget _buildImageUploadSection(BuildContext context) {
    double imageSize = MediaQuery.of(context).size.width < 360 ? 70 : 80;
    List<Widget> imageWidgets = [];

    // 已存在的網路圖片
    imageWidgets.addAll(_imageUrls.asMap().entries.map((entry) {
      int index = entry.key;
      String url = entry.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: imageSize, height: imageSize,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(url, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: const Icon(Icons.error_outline)))),
          ),
          Positioned(top: -8, right: -8, child: GestureDetector(onTap: () => _removeUrlImage(index), child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, color: Colors.white, size: 16)))),
        ],
      );
    }));

    // 新選擇的本地圖片
    imageWidgets.addAll(_imageFiles.asMap().entries.map((entry) {
      int index = entry.key;
      XFile file = entry.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: imageSize, height: imageSize,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(file.path), fit: BoxFit.cover)),
          ),
          Positioned(top: -8, right: -8, child: GestureDetector(onTap: () => _removeLocalImage(index), child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, color: Colors.white, size: 16)))),
        ],
      );
    }));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...imageWidgets,
        if (_imageFiles.length + _imageUrls.length < 5)
          GestureDetector(
            onTap: _selectImage,
            child: Container(
              width: imageSize, height: imageSize,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[400]!), borderRadius: BorderRadius.circular(8)),
              child: Center(child: Icon(Icons.add_a_photo_outlined, size: imageSize * 0.4, color: Colors.grey[600])),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomTextField({ required BuildContext context, required TextEditingController controller, required String hintText, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters, int? maxLines = 1, String? Function(String?)? validator, IconData? prefixIcon }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: _getResponsiveFontSize(context, 14)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: _getResponsiveSpacing(context, 12), vertical: _getResponsiveSpacing(context, 12)),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[600], size: _getResponsiveFontSize(context, 18)) : null,
      ),
      style: TextStyle(fontSize: _getResponsiveFontSize(context, 14)),
      validator: validator,
    );
  }

  Widget _buildCustomDropdown<T>({ required BuildContext context, required String hintText, required T? value, required List<T> items, required String Function(T) itemText, required dynamic Function(T) itemValue, required void Function(T?)? onChanged, String? Function(T?)? validator, IconData? prefixIcon }) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(hintText, style: TextStyle(color: Colors.grey[500], fontSize: _getResponsiveFontSize(context, 14))),
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: _getResponsiveSpacing(context, 12), vertical: _getResponsiveSpacing(context, 4)),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[600], size: _getResponsiveFontSize(context, 18)) : null,
      ),
      items: items.map((item) => DropdownMenuItem<T>(value: itemValue(item), child: Text(itemText(item), style: TextStyle(fontSize: _getResponsiveFontSize(context, 14))))).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.preview_outlined, size: _getResponsiveFontSize(context, 18)),
            label: Text('預覽', style: TextStyle(fontSize: _getResponsiveFontSize(context, 16), fontWeight: FontWeight.bold)),
            onPressed: _isLoading ? null : () { /* 預覽邏輯 */ },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[200],
              foregroundColor: Colors.black87,
              padding: EdgeInsets.symmetric(vertical: _getResponsiveSpacing(context, 12)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        SizedBox(width: _getResponsiveSpacing(context, 16)),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(_isEditMode ? Icons.save_alt_outlined : Icons.upload_file_outlined, size: _getResponsiveFontSize(context, 18)),
            label: Text(_isEditMode ? '保存修改' : '完成上傳', style: TextStyle(fontSize: _getResponsiveFontSize(context, 16), fontWeight: FontWeight.bold)),
            onPressed: _isLoading ? null : _completeUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: _getResponsiveSpacing(context, 12)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  // --- UI Builder Widgets (已還原) ---
  Widget _buildProductNameSection(BuildContext context) {
    return _buildCustomTextField(
      context: context,
      controller: _nameController,
      hintText: '例：全新iPhone 15 Pro Max 256G',
      prefixIcon: Icons.drive_file_rename_outline,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '請輸入商品名稱';
        }
        if (value.length < 5) {
          return '商品名稱至少5個字符';
        }
        return null;
      },
    );
  }

  Widget _buildQuantitySection(BuildContext context) {
    return _buildCustomTextField(
      context: context,
      controller: _quantityController,
      hintText: '數量',
      prefixIcon: Icons.production_quantity_limits,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '請輸入數量';
        }
        final n = int.tryParse(value);
        if (n == null || n < 0) {
          return '請輸入有效的數量';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdownSection(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.areCategoriesLoading) return const Center(child: CircularProgressIndicator());
        return _buildCustomDropdown<int>(
          context: context,
          hintText: '選擇商品所屬類別',
          prefixIcon: Icons.category_outlined,
          value: _selectedCategoryId,
          items: provider.categories,
          itemText: (category) => category.name,
          itemValue: (category) => category.id,
          onChanged: (value) => setState(() => _selectedCategoryId = value),
          validator: (value) => value == null ? '請選擇商品類別' : null,
        );
      },
    );
  }

  Widget _buildConditionDropdownSection(BuildContext context) {
    return _buildCustomDropdown<String>(
      context: context,
      hintText: '選擇商品的新舊狀況',
      prefixIcon: Icons.new_releases_outlined,
      value: _selectedCondition.isEmpty ? null : _selectedCondition,
      items: _conditions,
      itemText: (condition) => condition,
      itemValue: (condition) => condition,
      onChanged: (value) => setState(() => _selectedCondition = value ?? ''),
      validator: (value) => (value == null || value.isEmpty) ? '請選擇商品狀態' : null,
    );
  }

  Widget _buildTypeDropdownSection(BuildContext context) {
    return _buildCustomDropdown<String>(
      context: context,
      hintText: '選擇商品的銷售類型',
      prefixIcon: Icons.sell_outlined,
      value: _selectedType.isEmpty ? null : _selectedType,
      items: _types,
      itemText: (type) => type,
      itemValue: (type) => type,
      onChanged: (value) => setState(() => _selectedType = value ?? ''),
      validator: (value) => (value == null || value.isEmpty) ? '請選擇商品類型' : null,
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return _buildCustomTextField(
      context: context,
      controller: _descriptionController,
      hintText: '詳細描述商品的特點、尺寸、瑕疵等信息...',
      prefixIcon: Icons.description_outlined,
      maxLines: 4,
      validator: (value) {
        if (value != null && value.isNotEmpty && value.length < 10) {
          return '商品描述至少10個字符（如果填寫）';
        }
        return null; // 描述可以是可選的
      },
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return _buildCustomTextField(
      context: context,
      controller: _priceController,
      hintText: '售價',
      prefixIcon: Icons.attach_money,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '請輸入價格';
        }
        final n = double.tryParse(value);
        if (n == null || n <= 0) {
          return '請輸入有效的價格';
        }
        return null;
      },
    );
  }
}
