// --- FILE: lib/screens/search.dart ---
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product/product.dart';
import '../providers/product_provider.dart';
import '../widgets/filter_options.dart'; // 確保 FilterOptionsWidget 路徑正確
import 'home_page.dart'; // 我們將重用 HomePage 中的 _ProductCard Widget

class SearchPage extends StatefulWidget {
  final String? searchText;

  const SearchPage({super.key, this.searchText});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  // 本地狀態，用於管理篩選條件
  // 注意：這裡的篩選是純 UI 狀態，最終會傳遞給 Provider
  FilterOptions _activeFilters = const FilterOptions();

  @override
  void initState() {
    super.initState();

    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    if (widget.searchText != null && widget.searchText!.trim().isNotEmpty) {
      _searchController.text = widget.searchText!;
      // 頁面載入時，如果帶有初始搜尋文字，立即執行一次搜尋
      // 注意：目前 ProductProvider.fetchProducts 不支援搜尋參數
      // 這裡先載入所有產品，然後在本地進行篩選
      productProvider.fetchProducts();
    } else {
      // 載入所有產品
      productProvider.fetchProducts();
    }

    // 監聽文字框的變化以實現防抖搜尋
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// 當搜尋框文字改變時觸發，使用 Timer 實現防抖
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  /// 執行搜尋的核心方法
  Future<void> _performSearch() async {
    final provider = context.read<ProductProvider>();
    // 移除未使用的變數 queryText

    // 從篩選器中獲取 categoryId
    final categoryName = _activeFilters.categories.isNotEmpty ? _activeFilters.categories.first : null;
    final categoryId = _getCategoryIdByName(categoryName);

    // 根據 ProductProvider 的實際能力調整
    // 目前只支援按分類篩選，搜尋功能需要在本地實現
    if (categoryId != null) {
      // 按分類篩選
      provider.filterByCategory(categoryId);
    } else {
      // 載入所有產品（清除分類篩選）
      provider.fetchProducts();
    }

    // 注意：文字搜尋目前在 UI 層進行本地篩選
    // 如果需要後端搜尋，需要擴展 ProductProvider 和 ProductService
  }

  /// 顯示篩選器 BottomSheet
  void _showFilterOptions() async {
    final selectedFilters = await showModalBottomSheet<FilterOptions>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return FilterOptionsWidget(initialFilters: _activeFilters);
      },
    );

    if (selectedFilters != null && selectedFilters != _activeFilters) {
      setState(() {
        _activeFilters = selectedFilters;
      });
      // 套用篩選後，立即重新執行搜尋
      _performSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: '篩選',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildActiveFiltersDisplay(), // 顯示當前激活的篩選條件
          Expanded(
            // 使用 Consumer 來監聽 Provider 的狀態變化並重建 UI
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.listError != null) {
                  return Center(child: Text('發生錯誤: ${provider.listError}'));
                }
                if (provider.products.isEmpty) {
                  // 檢查是否正在載入或有錯誤
                  if (provider.isListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 根據是否有搜尋詞或篩選條件，顯示不同的提示
                  final bool hasInput = _searchController.text.trim().isNotEmpty || _activeFilters.categories.isNotEmpty;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(hasInput ? Icons.sentiment_dissatisfied_outlined : Icons.search_off_outlined, size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          hasInput ? '找不到符合條件的商品' : '輸入關鍵詞開始搜尋',
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // 檢查搜尋結果是否為空
                final filteredProducts = _filterProductsBySearch(provider.products);
                if (filteredProducts.isEmpty && _searchController.text.trim().isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sentiment_dissatisfied_outlined, size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          '找不到符合 "${_searchController.text.trim()}" 的商品',
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                // 如果有資料，則顯示結果列表（包含本地搜尋篩選）
                return _buildResultsList(_filterProductsBySearch(provider.products));
              },
            ),
          ),
        ],
      ),
    );
  }

  // 新增：本地搜尋篩選方法
  List<Product> _filterProductsBySearch(List<Product> allProducts) {
    final queryText = _searchController.text.trim().toLowerCase();

    if (queryText.isEmpty) {
      return allProducts;
    }

    return allProducts.where((product) {
      // 在產品名稱、描述、分類中搜尋
      return product.name.toLowerCase().contains(queryText) ||
          product.description.toLowerCase().contains(queryText) ||
          product.category.toLowerCase().contains(queryText) ||
          // 修正：完整的 null 檢查
          (product.tags != null && product.tags!.isNotEmpty &&
              product.tags!.any((tag) => tag.toLowerCase().contains(queryText)));
    }).toList();
  }

  // --- UI 元件 (主要採用組員版本的美化設計) ---

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: '搜尋商品...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),
      onSubmitted: (value) {
        _debounce?.cancel();
        _performSearch();
      },
    );
  }

  Widget _buildActiveFiltersDisplay() {
    if (_activeFilters.categories.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: _activeFilters.categories.map((categoryName) => Chip(
          label: Text(categoryName),
          onDeleted: () {
            setState(() {
              final updatedCategories = List<String>.from(_activeFilters.categories)..remove(categoryName);
              _activeFilters = _activeFilters.copyWith(categories: updatedCategories);
            });
            _performSearch();
          },
        )).toList(),
      ),
    );
  }

  Widget _buildResultsList(List<Product> results) {
    // 修正：如果 _ProductsGrid 不存在，創建一個簡單的網格佈局
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ProductsGrid(products: results), // 移除底線前綴，使用公開的 widget
      ),
    );
  }

  // 輔助函式，根據分類名稱找到對應的 ID
  int? _getCategoryIdByName(String? name) {
    if (name == null) return null;
    try {
      // _categories 來自 home_page.dart，為了方便我們在這裡重新定義
      final categories = [
        Category(id: 1, name: '書籍文具', icon: '📚', count: 0),
        Category(id: 2, name: '電子產品', icon: '📱', count: 0),
        Category(id: 3, name: '服裝配件', icon: '👕', count: 0),
        Category(id: 4, name: '家居用品', icon: '🏠', count: 0),
        Category(id: 5, name: '美容保健', icon: '💄', count: 0),
        Category(id: 6, name: '運動戶外', icon: '⚽', count: 0),
      ];
      return categories.firstWhere((c) => c.name == name).id;
    } catch (e) {
      return null;
    }
  }
}

// 如果 home_page.dart 中的 _ProductsGrid 是私有的，需要創建一個公開版本
class ProductsGrid extends StatelessWidget {
  final List<Product> products;

  const ProductsGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]); // 使用公開的 ProductCard
      },
    );
  }
}

// 如果 home_page.dart 中的 ProductCard 是私有的，需要創建一個公開版本
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品圖片
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: product.imageUrls.isNotEmpty
                  ? Image.network(
                product.imageUrls.first,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              )
                  : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 50),
              ),
            ),
          ),
          // 商品資訊
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NT\${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}