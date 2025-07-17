// lib/screens/seller/upload.dart (或您的文件名)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 確保這些模型的導入路徑是正確的
import '../../models/user/user.dart';
import '../../models/product/product.dart';
// import 'package:image_picker/image_picker.dart'; // 取消註釋以使用 image_picker

class ProductUploadPage extends StatefulWidget {
  final User seller; // 當前賣家信息
  final Product? productToEdit; // 要編輯的商品 (如果為 null，則是新增模式)

  const ProductUploadPage({
    super.key,
    required this.seller,
    this.productToEdit,
  });

  @override
  State<ProductUploadPage> createState() => _ProductUploadPageState();
}

class _ProductUploadPageState extends State<ProductUploadPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // 用於表單驗證

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  // late TextEditingController _originalPriceController; // 如果需要原價

  List<String> _selectedImages = []; // 存儲圖片路徑或 URL
  String _selectedCategory = '';
  String _selectedCondition = '';
  String _selectedType = '';

  // 選項列表
  final List<String> _categories = [
    '書籍文具', '電子產品', '服裝配件', '家居用品', '美容保健', '運動戶外', '其他'
  ];
  final List<String> _conditions = [
    '全新', '近全新', '良好', '普通', '需要維修'
  ];
  final List<String> _types = [
    '一般商品', '限時特價', '二手商品', '收藏品', '手作商品'
  ];

  bool _isLoading = false; // 用於表示是否正在上傳

  bool get _isEditMode => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _quantityController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    // _originalPriceController = TextEditingController();

    if (_isEditMode && widget.productToEdit != null) {
      final product = widget.productToEdit!;
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toStringAsFixed(0); // 假設價格無小數
      // _originalPriceController.text = product.originalPrice?.toStringAsFixed(0) ?? '';
      _quantityController.text = product.stockQuantity.toString();
      _selectedImages = List.from(product.imageUrls); // 複製圖片 URL 列表

      if (_categories.contains(product.category)) {
        _selectedCategory = product.category;
      }

      // 處理 condition 和 type (假設它們存儲在 tags 中)
      if (product.tags != null) {
        for (String tag in product.tags!) {
          if (_conditions.contains(tag) && _selectedCondition.isEmpty) { // 只取第一個匹配的
            _selectedCondition = tag;
          }
          if (_types.contains(tag) && _selectedType.isEmpty) { // 只取第一個匹配的
            _selectedType = tag;
          }
        }
      }
    }
  }

  // --- 響應式 UI 輔助方法 ---
  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    // ... (您的實現)
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
    // ... (您的實現)
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseSpacing * 0.8;
    if (screenWidth < 600) return baseSpacing;
    if (screenWidth < 900) return baseSpacing * 1.2;
    return baseSpacing * 1.5;
  }

  double _getResponsivePadding(BuildContext context) {
    // ... (您的實現)
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return 12.0;
    if (screenWidth < 600) return 16.0;
    if (screenWidth < 900) return 20.0;
    return 24.0;
  }

  // --- 圖片處理 ---
  // TODO: 實現真實的圖片選擇邏輯 (例如使用 image_picker)
  Future<void> _selectImage() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多只能選擇 5 張圖片')),
      );
      return;
    }
    // final picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   // TODO: 在這裡，您可能需要先將圖片上傳到服務器，然後獲取 URL
    //   // String imageUrl = await uploadImageToServer(image.path);
    //   // setState(() {
    //   //   _selectedImages.add(imageUrl);
    //   // });
    //   setState(() {
    //      _selectedImages.add('https://picsum.photos/seed/${_selectedImages.length + DateTime.now().millisecond}/200'); // 模擬添加網絡圖片
    //   });
    // }
    setState(() {
      // 模擬：實際應為選擇的本地文件路徑或上傳後的 URL
      _selectedImages.add('placeholder_image_path_${DateTime.now().millisecondsSinceEpoch}.jpg');
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // --- 預覽功能 ---
  void _previewProduct() {
    if (!_formKey.currentState!.validate()) { // 觸發表單驗證
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請修正表單中的錯誤'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    // 表單驗證通過後再顯示預覽
    _formKey.currentState!.save(); // 觸發 onSaved 回調 (如果有的話)

    // ... (您的預覽對話框邏輯，可以使用當前 controller 的值)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('商品預覽'),
        content: SingleChildScrollView( // 如果內容過多，允許滾動
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('商品名稱: ${_nameController.text}'),
              Text('價格: NT\$${_priceController.text}'),
              Text('數量: ${_quantityController.text.isEmpty ? "未設定" : _quantityController.text}'),
              Text('類別: ${_selectedCategory.isEmpty ? "未選擇" : _selectedCategory}'),
              Text('商品狀態: ${_selectedCondition.isEmpty ? "未選擇" : _selectedCondition}'),
              Text('商品類型: ${_selectedType.isEmpty ? "未選擇" : _selectedType}'),
              Text('描述: ${_descriptionController.text.isEmpty ? "未填寫" : _descriptionController.text}'),
              Text('圖片數量: ${_selectedImages.length}'),
              // 可以添加圖片預覽
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('圖片預覽:', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedImages.map((imgSrc) {
                    // 假設 imgSrc 可能是網絡 URL 或本地模擬路徑
                    // 實際應用中，本地圖片需要用 FileImage，網絡圖片用 NetworkImage
                    return SizedBox(width: 60, height: 60, child: Image.network(imgSrc, fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(Icons.broken_image))); // 簡易網絡圖片預覽
                  }).toList(),
                )
              ]
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  // --- 完成上傳/更新 ---
  Future<void> _completeUpload() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請修正表單中的錯誤後再提交'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    _formKey.currentState!.save();

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請至少上傳一張商品圖片'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: 這裡需要真實的圖片上傳邏輯
    // 假設 _selectedImages 經過處理後已經是有效的圖片 URL 列表
    List<String> finalImageUrls = List.from(_selectedImages);
    // 例如:
    // List<String> finalImageUrls = [];
    // for (String imagePathOrUrl in _selectedImages) {
    //   if (isLocalPath(imagePathOrUrl)) { // 判斷是否為本地路徑
    //     String? uploadedUrl = await uploadImageToServer(imagePathOrUrl);
    //     if (uploadedUrl != null) {
    //       finalImageUrls.add(uploadedUrl);
    //     } else {
    //       // 處理上傳失敗
    //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('圖片 $imagePathOrUrl 上傳失敗')));
    //       setState(() => _isLoading = false);
    //       return;
    //     }
    //   } else { // 假定已经是 URL (编辑模式下的旧图)
    //     finalImageUrls.add(imagePathOrUrl);
    //   }
    // }


    // 準備 Product 對象
    final String productName = _nameController.text;
    final double productPrice = double.tryParse(_priceController.text) ?? 0.0;
    // final double? originalPrice = double.tryParse(_originalPriceController.text);
    final int quantity = int.tryParse(_quantityController.text) ?? 1; // 默認為1件
    final String description = _descriptionController.text;
    final String categoryName = _selectedCategory;
    // 根據 categoryName 獲取 categoryId，這裡假設 _categories 的索引+1 就是 id
    final int categoryId = _categories.indexOf(categoryName) +1;


    // 根據UI選擇構建 tags 列表或其他特定字段
    List<String> tags = [];
    if (_selectedCondition.isNotEmpty) tags.add(_selectedCondition);
    if (_selectedType.isNotEmpty) tags.add(_selectedType);

    Product productData = Product(
      id: _isEditMode ? widget.productToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString(), // 或由後端生成ID
      name: productName,
      description: description,
      price: productPrice,
      // originalPrice: originalPrice,
      categoryId: categoryId,
      stockQuantity: quantity,
      imageUrls: finalImageUrls,
      category: categoryName,
      status: _isEditMode ? widget.productToEdit!.status : 'available', // 或根據 _selectedCondition 映射
      createdAt: _isEditMode ? widget.productToEdit!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
      seller: widget.seller,
      isSold: _isEditMode ? widget.productToEdit!.isSold : false,
      tags: tags.isNotEmpty ? tags : null, // 如果沒有tag則為null
      salesCount: _isEditMode ? widget.productToEdit!.salesCount : 0,
      averageRating: _isEditMode ? widget.productToEdit!.averageRating : null,
      reviewCount: _isEditMode ? widget.productToEdit!.reviewCount : 0,
      shippingInfo: _isEditMode ? widget.productToEdit!.shippingInfo : null, // 根據需要處理
    );

    // --- 模擬 API 調用 ---
    print('--- ${_isEditMode ? "更新" : "上傳"}商品 ---');
    print('賣家: ${widget.seller.username} (ID: ${widget.seller.id})');
    print('商品數據: ${productData.toJson()}'); // 確保 Product 有 toJson()

    bool success = false;
    try {
      // TODO: 在此處進行真實的 API 調用
      // if (_isEditMode) {
      //   success = await ApiService.updateProduct(productData);
      // } else {
      //   success = await ApiService.createProduct(productData);
      // }
      await Future.delayed(const Duration(seconds: 2)); // 模擬網絡延遲
      success = true; // 假設成功
    } catch (e) {
      print('上傳/更新商品失敗: $e');
      success = false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('商品${_isEditMode ? "更新" : "上傳"}成功！'),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) {
        Navigator.pop(context, true); // 返回 true 表示操作成功，通知前一頁刷新
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('商品${_isEditMode ? "更新" : "上傳"}失敗，請稍後再試。'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    // _originalPriceController.dispose();
    super.dispose();
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
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black87,
            size: _getResponsiveFontSize(context, 24),
          ),
          onPressed: _isLoading ? null : () => Navigator.pop(context), // 上傳時禁用返回
        ),
        title: Text(
          _isEditMode ? '編輯商品' : '上傳新商品',
          style: TextStyle(
            color: Colors.black87,
            fontSize: _getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: AbsorbPointer( // 上傳時禁用交互
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

                _buildSectionTitle('商品選項 (數量)'),
                _buildQuantitySection(context),
                SizedBox(height: spacing),

                _buildSectionTitle('商品類別'), // 之前叫 "商品材質"
                _buildCategoryDropdownSection(context),
                SizedBox(height: spacing),

                _buildSectionTitle('商品狀態'), // 之前叫 "商品出貨時間"
                _buildConditionDropdownSection(context),
                SizedBox(height: spacing),

                _buildSectionTitle('商品類型'), // 這個是新增的，對應 _selectedType
                _buildTypeDropdownSection(context),
                SizedBox(height: spacing),

                _buildSectionTitle('商品描述'),
                _buildDescriptionSection(context),
                SizedBox(height: spacing),

                _buildSectionTitle('價格設定'),
                _buildPriceSection(context), // 將價格和類型分開，更清晰
                // SizedBox(height: spacing), // 如果有原價，可以在這裡添加

                SizedBox(height: spacing * 2),
                _buildActionButtons(context),

                if (_isLoading) ...[ // 顯示加載指示器
                  SizedBox(height: spacing),
                  const Center(child: CircularProgressIndicator()),
                  const Center(child: Text("正在處理中...")),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: _getResponsiveSpacing(context, 8)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: _getResponsiveFontSize(context, 16),
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(BuildContext context) {
    double imageSize = MediaQuery.of(context).size.width < 360 ? 70 : MediaQuery.of(context).size.width < 600 ? 80 : 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap( // 使用 Wrap 處理多張圖片的佈局
          spacing: 8,
          runSpacing: 8,
          children: [
            // 已選擇的圖片
            ..._selectedImages.asMap().entries.map((entry) {
              int index = entry.key;
              String imagePathOrUrl = entry.value;
              return Stack(
                children: [
                  Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                      // color: Colors.grey[200], // 移除背景色，直接顯示圖片
                    ),
                    // child: Image.network(imagePathOrUrl, fit: BoxFit.cover, // 假設是網絡圖片
                    //   errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image, color: Colors.grey[400]))),
                    // TODO: 根據 imagePathOrUrl 是本地文件還是網絡 URL 決定如何顯示
                    // 這裡用一個占位符
                    child: imagePathOrUrl.startsWith('http')
                        ? Image.network(imagePathOrUrl, width: imageSize, height: imageSize, fit: BoxFit.cover,
                        errorBuilder: (c,e,s) => Center(child: Icon(Icons.error_outline, size: imageSize * 0.4, color: Colors.grey[500])))
                        : Center(child: Icon(Icons.image, size: imageSize * 0.4, color: Colors.grey[500])), // 模擬本地圖片
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Icon(Icons.close, size: _getResponsiveFontSize(context, 12), color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),

            // 添加圖片按鈕 (僅當圖片數量小於5時顯示)
            if (_selectedImages.length < 5)
              GestureDetector(
                onTap: _selectImage,
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(Icons.add_a_photo_outlined, size: imageSize * 0.4, color: Colors.grey[600]),
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: _getResponsiveSpacing(context, 4)),
          child: Text(
            '圖片大小建議小於5MB，支持JPG、PNG格式。',
            style: TextStyle(fontSize: _getResponsiveFontSize(context, 10), color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines = 1,
    String? Function(String?)? validator,
    IconData? prefixIcon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: _getResponsiveSpacing(context, 10),
          vertical: _getResponsiveSpacing(context, maxLines == 1 ? 2 : 8)), // 單行和多行不同padding
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3)
          ]
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: _getResponsiveFontSize(context, 14)),
          border: InputBorder.none,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[600], size: _getResponsiveFontSize(context, 18)) : null,
        ),
        style: TextStyle(fontSize: _getResponsiveFontSize(context, 14)),
        validator: validator,
      ),
    );
  }

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
      hintText: '輸入庫存數量',
      prefixIcon: Icons.production_quantity_limits,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '請輸入數量';
        }
        final n = int.tryParse(value);
        if (n == null || n < 0) { // 允許數量為0，表示暫時無貨
          return '請輸入有效的數量';
        }
        return null;
      },
    );
  }

  Widget _buildCustomDropdown<T>({
    required BuildContext context,
    required String hintText,
    required T? value,
    required List<T> items,
    required String Function(T) itemText,
    required void Function(T?)? onChanged,
    String? Function(T?)? validator,
    IconData? prefixIcon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _getResponsiveSpacing(context, 10), vertical: _getResponsiveSpacing(context, 2)),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3)]
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        hint: Text(hintText, style: TextStyle(color: Colors.grey[500], fontSize: _getResponsiveFontSize(context, 14))),
        isExpanded: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[600], size: _getResponsiveFontSize(context, 18)) : null,
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(itemText(item), style: TextStyle(fontSize: _getResponsiveFontSize(context, 14))),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildCategoryDropdownSection(BuildContext context) {
    return _buildCustomDropdown<String>(
      context: context,
      hintText: '選擇商品所屬類別',
      prefixIcon: Icons.category_outlined,
      value: _selectedCategory.isEmpty || !_categories.contains(_selectedCategory) ? null : _selectedCategory,
      items: _categories,
      itemText: (category) => category,
      onChanged: (value) {
        setState(() {
          _selectedCategory = value ?? '';
        });
      },
      validator: (value) => (value == null || value.isEmpty) ? '請選擇商品類別' : null,
    );
  }

  Widget _buildConditionDropdownSection(BuildContext context) {
    return _buildCustomDropdown<String>(
      context: context,
      hintText: '選擇商品的新舊狀況',
      prefixIcon: Icons.new_releases_outlined,
      value: _selectedCondition.isEmpty || !_conditions.contains(_selectedCondition) ? null : _selectedCondition,
      items: _conditions,
      itemText: (condition) => condition,
      onChanged: (value) {
        setState(() {
          _selectedCondition = value ?? '';
        });
      },
      validator: (value) => (value == null || value.isEmpty) ? '請選擇商品狀態' : null,
    );
  }

  Widget _buildTypeDropdownSection(BuildContext context) {
    return _buildCustomDropdown<String>(
      context: context,
      hintText: '選擇商品的銷售類型',
      prefixIcon: Icons.sell_outlined,
      value: _selectedType.isEmpty || !_types.contains(_selectedType) ? null : _selectedType,
      items: _types,
      itemText: (type) => type,
      onChanged: (value) {
        setState(() {
          _selectedType = value ?? '';
        });
      },
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
      hintText: '輸入售價 (NT\$)',
      prefixIcon: Icons.attach_money,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly], // 也可以允許小數點 [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.preview_outlined, size: _getResponsiveFontSize(context, 18)),
            label: Text(
              '預覽',
              style: TextStyle(fontSize: _getResponsiveFontSize(context, 16), fontWeight: FontWeight.bold),
            ),
            onPressed: _isLoading ? null : _previewProduct,
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
            label: Text(
              _isEditMode ? '保存修改' : '完成上傳',
              style: TextStyle(fontSize: _getResponsiveFontSize(context, 16), fontWeight: FontWeight.bold),
            ),
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
}
