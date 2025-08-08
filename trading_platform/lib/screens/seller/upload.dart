// --- FILE: lib/screens/seller/upload.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product/product.dart';
import '../../providers/product_provider.dart';

class ProductUploadPage extends StatefulWidget {
  final Product? productToEdit;
  const ProductUploadPage({super.key, this.productToEdit});

  @override
  State<ProductUploadPage> createState() => _ProductUploadPageState();
}

class _ProductUploadPageState extends State<ProductUploadPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockQuantityController;

  // 模擬資料，實際應從 CategoryProvider 獲取
  final List<String> _categories = ['書籍文具', '電子產品', '服裝配件'];
  String _selectedCategory = '書籍文具';

  List<String> _selectedImages = [];
  bool _isLoading = false;
  bool get _isEditMode => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productToEdit?.name);
    _descriptionController = TextEditingController(text: widget.productToEdit?.description);
    _priceController = TextEditingController(text: widget.productToEdit?.price.toString());
    _stockQuantityController = TextEditingController(text: widget.productToEdit?.stockQuantity.toString());
    if (_isEditMode) {
      _selectedCategory = widget.productToEdit!.category;
      _selectedImages = List.from(widget.productToEdit!.imageUrls);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockQuantityController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    // TODO: 實現真實的圖片選擇與上傳邏輯
    setState(() {
      _selectedImages.add('https://via.placeholder.com/150'); // 新增一個佔位圖片
    });
    print('模擬：選擇圖片');
  }

  Future<void> _completeUpload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('請至少上傳一張圖片')));
      return;
    }

    setState(() { _isLoading = true; });

    final productData = {
      "name": _nameController.text,
      "description": _descriptionController.text,
      "price": double.tryParse(_priceController.text) ?? 0.0,
      "category_id": _categories.indexOf(_selectedCategory) + 1,
      "category": _selectedCategory,
      "stock_quantity": int.tryParse(_stockQuantityController.text) ?? 1,
      "image_urls": _selectedImages,
      "tags": [], // 暫時為空
    };

    try {
      if (_isEditMode) {
        // TODO: 實現更新邏輯
      } else {
        await Provider.of<ProductProvider>(context, listen: false).addProduct(productData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('商品${_isEditMode ? "更新" : "上傳"}成功！'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失敗: $e'), backgroundColor: Colors.red),
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
        title: Text(_isEditMode ? '編輯商品' : '上架新商品'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: '商品名稱'), validator: (v) => v!.isEmpty ? '不能為空' : null),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: '商品描述'), maxLines: 3, validator: (v) => v!.isEmpty ? '不能為空' : null),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: '價格'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? '不能為空' : null),
              TextFormField(controller: _stockQuantityController, decoration: const InputDecoration(labelText: '庫存'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? '不能為空' : null),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
                decoration: const InputDecoration(labelText: '分類'),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(onPressed: _selectImage, icon: const Icon(Icons.add_a_photo), label: const Text('新增圖片')),
              // 圖片預覽...
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _completeUpload,
                child: _isLoading ? const CircularProgressIndicator() : Text(_isEditMode ? '保存修改' : '完成上傳'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
