import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/product/product.dart';
import '../providers/product_provider.dart';
import '../widgets/filter_options.dart';
import 'product.dart';

class SearchPage extends StatefulWidget {
  final String? searchText;

  const SearchPage({super.key, this.searchText});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // 本地狀態：目前篩選條件（含分類名稱 List<String>）
  FilterOptions _activeFilters = const FilterOptions();

  @override
  void initState() {
    super.initState();
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    if (widget.searchText != null && widget.searchText!.trim().isNotEmpty) {
      _searchController.text = widget.searchText!;
      productProvider.fetchProducts();
    } else {
      productProvider.fetchProducts();
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

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _performSearch);
  }

  Future<void> _performSearch() async {
    final provider = context.read<ProductProvider>();

    // 取第一個分類名稱（你的 FilterOptions.categories 是 List<String>）
    final String? categoryName =
    _activeFilters.categories.isNotEmpty ? _activeFilters.categories.first : null;

    // 對照表：分類名稱 -> 分類 ID（與 HomePage 的 CategoryUI 一致）
    const Map<String, int> kCategoryNameToId = {
      '書籍文具': 1,
      '電子產品': 2,
      '服裝配件': 3,
      '家居用品': 4,
      '美容保健': 5,
      '運動戶外': 6,
    };

    final int? categoryId = categoryName != null ? kCategoryNameToId[categoryName] : null;

    // 目前 Provider 僅支援按分類篩選；搜尋文字在 UI 端本地過濾
    if (categoryId != null) {
      provider.filterByCategory(categoryId);
    } else {
      provider.fetchProducts(); // 清除分類篩選
    }
  }

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
                  final bool hasInput =
                      _searchController.text.trim().isNotEmpty ||
                          _activeFilters.categories.isNotEmpty;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasInput
                              ? Icons.sentiment_dissatisfied_outlined
                              : Icons.search_off_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
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

                // 本地文字搜尋（名稱/描述/分類/標籤）
                final results = _filterProductsBySearch(provider.products);

                if (results.isEmpty && _searchController.text.trim().isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sentiment_dissatisfied_outlined,
                            size: 60, color: Colors.grey),
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

                return _buildResultsList(results);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Product> _filterProductsBySearch(List<Product> allProducts) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return allProducts;

    return allProducts.where((p) {
      final inName = p.name.toLowerCase().contains(q);
      final inDesc = p.description.toLowerCase().contains(q);
      final inCat = p.category.toLowerCase().contains(q);
      final inTags = p.tags != null &&
          p.tags!.any((t) => t.toLowerCase().contains(q));
      return inName || inDesc || inCat || inTags;
    }).toList();
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: '搜尋商品...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),
      onSubmitted: (_) {
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
        children: _activeFilters.categories
            .map(
              (name) => Chip(
            label: Text(name),
            onDeleted: () {
              setState(() {
                final updated =
                List<String>.from(_activeFilters.categories)..remove(name);
                _activeFilters = _activeFilters.copyWith(categories: updated);
              });
              _performSearch();
            },
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildResultsList(List<Product> results) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _SearchProductsGrid(products: results),
      ),
    );
  }
}

// =====================
// 公開的結果 Grid / Card
// =====================

class _SearchProductsGrid extends StatelessWidget {
  final List<Product> products;
  const _SearchProductsGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 360 ? 1 : (width < 700 ? 2 : 3);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.74,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) => _SearchProductCard(product: products[i]),
    );
  }
}

class _SearchProductCard extends StatelessWidget {
  final Product product;
  const _SearchProductCard({required this.product});

  String _formatPrice(double price) {
    final f = NumberFormat.currency(locale: 'zh_TW', symbol: 'NT\$', decimalDigits: 0);
    return f.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final provider = context.read<ProductProvider>();
    final imageUrl =
    (product.imageUrls.isNotEmpty && product.imageUrls.first.isNotEmpty)
        ? product.imageUrls.first
        : 'https://via.placeholder.com/300x250/E0E0E0/000000?Text=No+Image';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          // ✅ 關鍵：帶 initialProduct，且把 product.id 直接傳「int」
          builder: (_) => ProductScreen(
            productId: product.id,
            initialProduct: product,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 圖片
            Expanded(
              flex: 3,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              size: 40, color: Colors.grey),
                        ),
                      ),
                      loadingBuilder: (c, child, p) => p == null
                          ? child
                          : Center(
                        child: CircularProgressIndicator(
                          value: p.expectedTotalBytes != null
                              ? p.cumulativeBytesLoaded /
                              p.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    ),
                  ),
                  if (product.isSold)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'SOLD',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  // 收藏
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        provider.toggleFavoriteStatus(product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(product.isFavorite
                                ? '已取消收藏'
                                : '已加入收藏 ❤️'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product.isFavorite
                              ? Colors.redAccent
                              : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 文案
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatPrice(product.price),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product.originalPrice != null &&
                            product.originalPrice! > product.price)
                          Text(
                            _formatPrice(product.originalPrice!),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
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
