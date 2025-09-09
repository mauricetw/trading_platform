// --- FILE: lib/screens/search.dart ---
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product/product.dart';
import '../models/product/category.dart';
import '../providers/product_provider.dart';
import '../widgets/filter_options.dart';
import 'product.dart'; // 引入商品詳情頁
import 'package:intl/intl.dart'; // 用於格式化價格

class SearchPage extends StatefulWidget {
  final String? searchText;

  const SearchPage({super.key, this.searchText});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  FilterOptions _activeFilters = const FilterOptions();

  @override
  void initState() {
    super.initState();

    final productProvider = context.read<ProductProvider>();

    if (widget.searchText != null && widget.searchText!.trim().isNotEmpty) {
      _searchController.text = widget.searchText!;
    }

    // 頁面載入時，立即執行一次搜尋 (可能是空搜尋，即載入所有商品)
    _performSearch();

    // 確保分類列表已載入
    if (productProvider.categories.isEmpty) {
      productProvider.fetchCategories();
    }

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

  /// REFACTORED: 執行搜尋的核心方法，現在會將所有條件傳遞給 Provider
  Future<void> _performSearch() async {
    final provider = context.read<ProductProvider>();

    final categoryName = _activeFilters.categories.isNotEmpty ? _activeFilters.categories.first : null;
    final categoryId = _getCategoryIdByName(categoryName, provider.categories);
    final searchQuery = _searchController.text.trim();

    // 呼叫 Provider 的 fetchProducts，並傳入所有篩選條件
    provider.fetchProducts(
      categoryId: categoryId,
      searchQuery: searchQuery,
    );
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

    if (selectedFilters != null) { // 即使沒有改變也應重新整理
      setState(() {
        _activeFilters = selectedFilters;
      });
      _performSearch();
    }
  }

  // REFACTORED: 輔助函式現在從 Provider 獲取分類列表
  int? _getCategoryIdByName(String? name, List<Category> categories) {
    if (name == null) return null;
    try {
      return categories.firstWhere((c) => c.name == name).id;
    } catch (e) {
      return null;
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
          _buildActiveFiltersDisplay(),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isListLoading && provider.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.listError != null) {
                  return Center(child: Text('發生錯誤: ${provider.listError}'));
                }
                if (provider.products.isEmpty) {
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

                // REFACTORED: 不再需要本地篩選，直接顯示 Provider 的結果
                return _buildResultsList(provider.products);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- UI 元件 ---

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      autofocus: widget.searchText == null, // 如果有初始文字則不自動聚焦
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
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ProductCard(product: results[index]);
      },
    );
  }
}

// --- 共用 Widget ---
// 為了避免循環依賴，將 ProductCard 放在這裡或一個共用的 widgets 檔案
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  String _formatPrice(double price) {
    final formatCurrency = NumberFormat.currency(locale: "zh_TW", symbol: "NT\$", decimalDigits: 0);
    return formatCurrency.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductScreen(productId: product.id))),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: product.imageUrls.isNotEmpty
                    ? Image.network(
                  product.imageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                )
                    : const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatPrice(product.price),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
