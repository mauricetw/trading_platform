import 'package:flutter/foundation.dart'; // 為了 @immutable 和 listEquals
import 'package:flutter/material.dart';

@immutable // 建議添加此註解，靜態分析器會檢查是否有可變成員
class FilterOptions {
  final String? sortBy;
  final List<String> categories;

  // 構造函數
  const FilterOptions({
    this.sortBy,
    List<String>? categories, // 接收可選的列表
  }) : categories = categories ?? const []; // 如果為 null，則使用空列表

  // 1. copyWith 方法
  FilterOptions copyWith({
    String? sortBy, // 使用 nullable type 來表示可以清除該值
    List<String>? categories,
  }) {
    return FilterOptions(
      // 如果 sortBy 未提供 (null)，則使用當前的 sortBy
      // 如果 sortBy 提供了 (即使是 null)，則使用提供的值
      // 為了能將 sortBy 清除 (設為 null)，我們需要一個方法來區分“未提供”和“提供的值是 null”
      // 一種簡單的方式是，如果調用者想清除 sortBy，他們明確傳入 null
      sortBy: sortBy ?? this.sortBy,
      categories: categories ?? this.categories,
    );
  }

  // 如果您想更精確地控制 copyWith，使其能夠將 sortBy 設置為 null：
  // FilterOptions copyWith({
  //   ValueGetter<String?>? sortBy, // 使用 ValueGetter 允許傳遞一個返回 null 的函數
  //   List<String>? categories,
  // }) {
  //   return FilterOptions(
  //     sortBy: sortBy != null ? sortBy() : this.sortBy,
  //     categories: categories ?? this.categories,
  //   );
  // }
  // // 調用時:
  // // currentFilters.copyWith(sortBy: () => null) // 清除 sortBy
  // // currentFilters.copyWith(sortBy: () => 'newSort') // 設置新 sortBy
  // // currentFilters.copyWith() // sortBy 不變

  // 2. 值相等性 (== 和 hashCode)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FilterOptions &&
        other.sortBy == sortBy &&
        listEquals(other.categories, categories); // 使用 listEquals 比較列表內容
  }

  @override
  int get hashCode => Object.hash(sortBy, Object.hashAll(categories)); // 使用 Object.hashAll 處理列表

  // 3. toString 方法 (方便調試)
  @override
  String toString() {
    return 'FilterOptions(sortBy: $sortBy, categories: $categories)';
  }
}

// -------------------------------------------------------------------------
// FilterOptionsWidget 和 _FilterOptionsWidgetState 的程式碼將保持【完全不變】
// 因為它們對 FilterOptions 的使用方式（訪問屬性 sortBy, categories 和調用 copyWith）
// 在這個手動實現中是兼容的。
// -------------------------------------------------------------------------

class FilterOptionsWidget extends StatefulWidget {
  final FilterOptions initialFilters;

  const FilterOptionsWidget({super.key, required this.initialFilters});

  @override
  State<FilterOptionsWidget> createState() => _FilterOptionsWidgetState();
}

class _FilterOptionsWidgetState extends State<FilterOptionsWidget> {
  late FilterOptions _currentFilters;
  final List<String> _availableCategories = ['電子產品', '書籍', '服裝', '家具'];
  final List<String> _sortByOptions = ['相關性', '價格低到高', '價格高到低', '最新上架'];

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('排序方式', style: Theme.of(context).textTheme.titleLarge),
          DropdownButtonFormField<String>(
            value: _currentFilters.sortBy ?? _sortByOptions.first,
            items: _sortByOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                // copyWith 的調用方式不變
                _currentFilters = _currentFilters.copyWith(sortBy: newValue);
              });
            },
            decoration: const InputDecoration(labelText: '選擇排序'),
          ),
          const SizedBox(height: 20),
          Text('商品分類', style: Theme.of(context).textTheme.titleLarge),
          Wrap(
            spacing: 8.0,
            children: _availableCategories.map((category) {
              return FilterChip(
                label: Text(category),
                selected: _currentFilters.categories.contains(category),
                onSelected: (bool selected) {
                  setState(() {
                    List<String> currentCategories = List.from(_currentFilters.categories);
                    if (selected) {
                      currentCategories.add(category);
                    } else {
                      currentCategories.remove(category);
                    }
                    _currentFilters = _currentFilters.copyWith(categories: currentCategories);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    // 重置為初始空篩選，現在使用我們手動定義的構造函數
                    _currentFilters = const FilterOptions();
                  });
                },
                child: const Text('重置'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _currentFilters);
                },
                child: const Text('應用篩選'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}