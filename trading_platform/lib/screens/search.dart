import 'dart:async'; // 用於 Timer (防抖)
import 'package:flutter/material.dart';
import 'package:first_flutter_project/services/api_service.dart';
// 導入您的 FilterOptions 和 FilterOptionsWidget
import 'package:first_flutter_project/widgets/filter_options.dart'; // <<<=== 確保路徑正確


class SearchPage extends StatefulWidget {
  final String? searchText;

  const SearchPage({super.key, this.searchText});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  bool _hasSearched = false;
  Timer? _debounce;

  // 新增：保存當前激活的篩選條件
  FilterOptions _activeFilters = const FilterOptions(); // 使用 freezed 生成的預設構造函數

  @override
  void initState() {
    super.initState();

    if (widget.searchText != null && widget.searchText!.trim().isNotEmpty) {
      _searchController.text = widget.searchText!;
      _debounce?.cancel();
      // 初始搜索時也應用當前（可能為預設）的篩選條件
      _performSearch(widget.searchText!.trim(), filters: _activeFilters);
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
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      // 當搜索詞改變時，也應用當前的篩選條件
      _performSearch(query, filters: _activeFilters);
    });
  }

  // 修改 _performSearch 以接受和使用 FilterOptions
  Future<void> _performSearch(String query, {FilterOptions? filters}) async {
    final currentFiltersToUse = filters ?? _activeFilters;

    // 如果查詢為空並且沒有任何篩選條件，則清空結果
    if (query.isEmpty &&
        (currentFiltersToUse.sortBy == null || currentFiltersToUse.sortBy!.isEmpty) &&
        currentFiltersToUse.categories.isEmpty) {
      setState(() {
        _searchResults = [];
        // 即使是清空，也標記為已搜索，以顯示合適的提示
        _hasSearched = true;
        _isLoading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      // 在調用 API 時傳遞篩選條件
      // 您需要修改 ApiService().searchItems 來接受這些篩選參數
      final results = await _apiService.searchItems(
        query,
        sortBy: currentFiltersToUse.sortBy,
        categories: currentFiltersToUse.categories,
        // ... 其他您在 FilterOptions 中定義的篩選條件
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "搜索時發生錯誤: $e";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        autofocus: widget.searchText == null || widget.searchText!.isEmpty,
        decoration: InputDecoration(
          hintText: '搜索商品、資訊...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              // 清空時會自動觸發 _onSearchChanged
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            _debounce?.cancel();
            _performSearch(value.trim(), filters: _activeFilters);
          } else {
            // 如果提交的是空字符串，也觸發一次帶篩選的搜索（可能清空結果或按篩選顯示）
            _performSearch("", filters: _activeFilters);
          }
        },
      ),
    );
  }

  // 新增：顯示篩選器 BottomSheet 的方法
  void _showFilterOptions() async {
    final selectedFilters = await showModalBottomSheet<FilterOptions>(
      context: context,
      isScrollControlled: true, // 如果篩選內容較多，允許滾動
      shape: const RoundedRectangleBorder( // 美化頂部圓角
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        // 傳遞當前激活的篩選條件給 FilterOptionsWidget
        return FilterOptionsWidget(initialFilters: _activeFilters);
      },
    );

    // 如果用戶確認了篩選（selectedFilters 不是 null）
    if (selectedFilters != null) {
      bool filtersChanged = selectedFilters != _activeFilters; // 簡單比較是否改變
      setState(() {
        _activeFilters = selectedFilters;
      });
      // 只有當篩選條件確實改變時，或者搜索框有內容時，才重新執行搜索
      // 或者如果篩選條件不為空
      if (filtersChanged || _searchController.text.trim().isNotEmpty || _activeFilters.categories.isNotEmpty || (_activeFilters.sortBy !=null && _activeFilters.sortBy!.isNotEmpty) ) {
        _debounce?.cancel(); // 如果有正在進行的防抖搜索，取消它
        _performSearch(_searchController.text.trim(), filters: _activeFilters);
      }
    }
  }

  // 新增：構建顯示當前激活篩選條件的 Widget
  Widget _buildActiveFiltersDisplay() {
    if (_activeFilters.categories.isEmpty && (_activeFilters.sortBy == null || _activeFilters.sortBy!.isEmpty)) {
      return const SizedBox.shrink(); // 沒有激活的篩選，不顯示任何東西
    }

    List<Widget> filterChips = [];

    if (_activeFilters.sortBy != null && _activeFilters.sortBy!.isNotEmpty) {
      filterChips.add(Chip(
        label: Text('排序: ${_activeFilters.sortBy}'),
        onDeleted: () {
          setState(() {
            _activeFilters = _activeFilters.copyWith(sortBy: null); // 清除排序
          });
          _performSearch(_searchController.text.trim(), filters: _activeFilters);
        },
      ));
    }

    for (String category in _activeFilters.categories) {
      filterChips.add(Chip(
        label: Text(category),
        onDeleted: () {
          List<String> updatedCategories = List.from(_activeFilters.categories)..remove(category);
          setState(() {
            _activeFilters = _activeFilters.copyWith(categories: updatedCategories);
          });
          _performSearch(_searchController.text.trim(), filters: _activeFilters);
        },
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: filterChips,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索'),
        backgroundColor: const Color(0xFF004E98),
        actions: [
          // 添加篩選按鈕到 AppBar
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: '篩選',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildSearchBar(),
          _buildActiveFiltersDisplay(), // 顯示當前激活的篩選條件
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
                child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center),
                    )))
          else if (!_hasSearched && _searchController.text.isEmpty && _activeFilters.categories.isEmpty && (_activeFilters.sortBy == null || _activeFilters.sortBy!.isEmpty))
            // 只有在沒有搜索過、搜索框為空且沒有篩選條件時顯示初始提示
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_outlined,
                          size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('輸入關鍵詞開始搜索，或使用篩選器',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              )
            else if (_searchResults.isEmpty && _hasSearched)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sentiment_dissatisfied_outlined,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.trim().isEmpty && _activeFilters.categories.isEmpty && (_activeFilters.sortBy == null || _activeFilters.sortBy!.isEmpty)
                              ? '請輸入關鍵詞或選擇篩選條件'
                              : '未找到與您的搜索和篩選條件相符的結果',
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      String title = "未知標題";
                      String subtitle = "";

                      if (item is Map) {
                        title = item['name'] ?? item['title'] ?? 'N/A';
                        subtitle = item['description'] ?? item['category'] ?? '';
                      }
                      // else if (item is Product) { // 如果您有具體的 Product 模型
                      //   title = item.name;
                      //   subtitle = item.category ?? '';
                      // }

                      return ListTile(
                        title: Text(title),
                        subtitle: Text(subtitle),
                        onTap: () {
                          print('Tapped on: $item');
                          // TODO: 導航到詳情頁
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}