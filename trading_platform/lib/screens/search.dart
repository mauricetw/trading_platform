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

  const SearchPage({Key? key, this.searchText}) : super(key: key);

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
      productProvider.fetchProducts(search: widget.searchText!.trim());
    } else {
      // 如果沒有初始文字，清空 Provider 中的商品列表，以顯示初始提示
      productProvider.clearProducts();
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
    final query = _searchController.text.trim();

    // 從篩選器中獲取 categoryId
    // 注意：FilterOptions 中的 categories 是 List<String>，而我們的 API 需要 int?
    // 這裡我們假設只選擇一個分類進行篩選
    final categoryName = _activeFilters.categories.isNotEmpty ? _activeFilters.categories.first : null;
    final categoryId = _getCategoryIdByName(categoryName);

    // 呼叫 Provider 的 fetchProducts 方法，傳入搜尋關鍵字和分類 ID
    provider.fetchProducts(search: query, categoryId: categoryId);
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
                // 如果有資料，則顯示結果列表
                return _buildResultsList(provider.products);
              },
            ),
          ),
        ],
      ),
    );
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
    // 為了 UI 一致性，我們重用 HomePage 中的 _ProductsGrid 和 _ProductCard
    // 如果希望搜尋結果是列表而不是網格，可以改用 ListView.builder
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _ProductsGrid(products: results), // 直接重用網格佈局
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
