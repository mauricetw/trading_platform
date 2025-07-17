import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductUploadPage extends StatefulWidget {
  const ProductUploadPage({super.key});

  @override
  State<ProductUploadPage> createState() => _ProductUploadPageState();
}

class _ProductUploadPageState extends State<ProductUploadPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final List<String> _selectedImages = [];
  String _selectedCategory = '';
  String _selectedCondition = '';
  String _selectedType = '';

  final List<String> _categories = [
    '書籍文具', '電子產品', '服裝配件', '家居用品', '美容保健', '運動戶外', '其他'
  ];

  final List<String> _conditions = [
    '全新', '近全新', '良好', '普通', '需要維修'
  ];

  final List<String> _types = [
    '一般商品', '限時特價', '二手商品', '收藏品', '手作商品'
  ];

  // 響應式設計輔助方法
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

  // 模擬圖片選擇
  void _selectImage() {
    if (_selectedImages.length < 5) {
      setState(() {
        _selectedImages.add('image_${_selectedImages.length + 1}');
      });
    }
  }

  // 移除圖片
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 預覽功能
  void _previewProduct() {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請填寫商品名稱和價格'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('商品預覽'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('商品名稱: ${_nameController.text}'),
            Text('價格: NT\$${_priceController.text}'),
            Text('數量: ${_quantityController.text.isEmpty ? "未設定" : _quantityController.text}'),
            Text('類別: ${_selectedCategory.isEmpty ? "未選擇" : _selectedCategory}'),
            Text('商品狀態: ${_selectedCondition.isEmpty ? "未選擇" : _selectedCondition}'),
            Text('商品類型: ${_selectedType.isEmpty ? "未選擇" : _selectedType}'),
            Text('圖片數量: ${_selectedImages.length}'),
          ],
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

  // 完成上傳
  void _completeUpload() {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請填寫必要資訊'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 這裡應該調用API上傳商品
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('商品上傳成功！'),
        backgroundColor: Colors.green,
      ),
    );

    // 返回上一頁
    Navigator.pop(context);
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '上傳商品',
          style: TextStyle(
            color: Colors.black87,
            fontSize: _getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 圖片上傳區域
            _buildImageUploadSection(context),

            SizedBox(height: spacing),

            // 商品名稱
            _buildProductNameSection(context),

            SizedBox(height: spacing),

            // 商品選項（數量）
            _buildQuantitySection(context),

            SizedBox(height: spacing),

            // 商品材質
            _buildCategorySection(context),

            SizedBox(height: spacing),

            // 商品出貨時間
            _buildConditionSection(context),

            SizedBox(height: spacing),

            // 商品描述
            _buildDescriptionSection(context),

            SizedBox(height: spacing),

            // 金額和類別
            _buildPriceAndTypeSection(context),

            SizedBox(height: spacing * 2),

            // 預覽和完成按鈕
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(BuildContext context) {
    double imageSize = MediaQuery.of(context).size.width < 360 ? 80 : MediaQuery.of(context).size.width < 600 ? 100 : 120;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 主圖片區域
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedImages.isNotEmpty
                  ? Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: imageSize * 0.4,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(0),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: _getResponsiveFontSize(context, 14),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: imageSize * 0.3,
                      color: Colors.grey[400],
                    ),
                    Text(
                      'NO IMAGE',
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 10),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: _getResponsiveSpacing(context, 12)),

            // 添加圖片按鈕
            GestureDetector(
              onTap: _selectImage,
              child: Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    size: imageSize * 0.4,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),

            SizedBox(width: _getResponsiveSpacing(context, 12)),

            // 圖片說明
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '圖片檔案不能大於',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 12),
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '5mb',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 12),
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '最多上傳5張',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 12),
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '第一張圖片請上傳商品主圖',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 12),
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '範圍(2)',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 12),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // 額外圖片顯示
        if (_selectedImages.length > 1)
          Padding(
            padding: EdgeInsets.only(top: _getResponsiveSpacing(context, 8)),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedImages.asMap().entries.skip(1).map((entry) {
                int index = entry.key;
                return Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 30,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildProductNameSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '商品名稱：',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.edit,
              size: _getResponsiveFontSize(context, 20),
              color: Colors.grey[600],
            ),
          ],
        ),
        SizedBox(height: _getResponsiveSpacing(context, 8)),
        Container(
          padding: EdgeInsets.all(_getResponsiveSpacing(context, 12)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: '請輸入商品名稱',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: _getResponsiveFontSize(context, 14),
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '商品選項(數量)：',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: _getResponsiveSpacing(context, 8)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: _getResponsiveSpacing(context, 12),
            vertical: _getResponsiveSpacing(context, 8),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Text(
                '預設為無',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 14),
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: '輸入數量',
                    hintStyle: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 12),
                      color: Colors.grey[500],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: _getResponsiveSpacing(context, 8),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 14),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    size: _getResponsiveFontSize(context, 20),
                  ),
                  onPressed: () {
                    int current = int.tryParse(_quantityController.text) ?? 0;
                    _quantityController.text = (current + 1).toString();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '商品材質：',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: _getResponsiveSpacing(context, 8)),
        Container(
          padding: EdgeInsets.all(_getResponsiveSpacing(context, 12)),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedCategory.isEmpty ? null : _selectedCategory,
            hint: Text(
              '請選擇商品類別',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 14),
                color: Colors.grey[600],
              ),
            ),
            isExpanded: true,
            underline: Container(),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 14),
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? '';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConditionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '商品出貨時間(下單後)：',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: _getResponsiveSpacing(context, 8)),
        Container(
          padding: EdgeInsets.all(_getResponsiveSpacing(context, 12)),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedCondition.isEmpty ? null : _selectedCondition,
            hint: Text(
              '請選擇商品狀態',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 14),
                color: Colors.grey[600],
              ),
            ),
            isExpanded: true,
            underline: Container(),
            items: _conditions.map((condition) {
              return DropdownMenuItem(
                value: condition,
                child: Text(
                  condition,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 14),
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCondition = value ?? '';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '商品描述：',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.edit,
              size: _getResponsiveFontSize(context, 20),
              color: Colors.grey[600],
            ),
          ],
        ),
        SizedBox(height: _getResponsiveSpacing(context, 8)),
        Container(
          padding: EdgeInsets.all(_getResponsiveSpacing(context, 12)),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '請輸入商品描述...',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: _getResponsiveFontSize(context, 14),
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndTypeSection(BuildContext context) {
    return Row(
      children: [
        // 金額部分
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '金額：',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: _getResponsiveSpacing(context, 8)),
              Container(
                padding: EdgeInsets.all(_getResponsiveSpacing(context, 12)),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'NT\$',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: _getResponsiveFontSize(context, 14),
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 14),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: _getResponsiveSpacing(context, 16)),

        // 類別部分
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '類別：',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: _getResponsiveSpacing(context, 8)),
              Container(
                padding: EdgeInsets.all(_getResponsiveSpacing(context, 12)),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedType.isEmpty ? null : _selectedType,
                  hint: Text(
                    '選擇類別',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 14),
                      color: Colors.grey[600],
                    ),
                  ),
                  isExpanded: true,
                  underline: Container(),
                  items: _types.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: _getResponsiveFontSize(context, 14),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value ?? '';
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _previewProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black87,
              padding: EdgeInsets.symmetric(
                vertical: _getResponsiveSpacing(context, 12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '預覽',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        SizedBox(width: _getResponsiveSpacing(context, 16)),

        Expanded(
          child: ElevatedButton(
            onPressed: _completeUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: _getResponsiveSpacing(context, 12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '完成',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}