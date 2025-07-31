import 'package:flutter/material.dart';
import '../../models/user/user.dart'; // 假設你可能需要 User 模型，如果不需要可以移除
import 'package:first_flutter_project/services/auth_service.dart'; // 如果 getCurrentUserId 來自這裡
import '../../widgets/upsert_shipping_option_dialog.dart';
import '../../models/user/shipping_option.dart';
import '../../services/shipping_api_service.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';
import '../../widgets/BottomConvexArcWidget.dart';

// 模擬獲取當前用戶ID (你需要用你實際的認證邏輯替換)
String getCurrentUserId() {
  // TODO: 替換為從你的認證服務中獲取實際用戶ID的邏輯
  // 例如: return AuthService.instance.currentUser?.uid ?? '';
  return 'test_seller_id_http'; // 替換為實際的用戶ID獲取方式
}

class ShippingSettingsPage extends StatefulWidget {
  const ShippingSettingsPage({super.key});

  @override
  State<ShippingSettingsPage> createState() => _ShippingSettingsPageState();
}

class _ShippingSettingsPageState extends State<ShippingSettingsPage> {
  late final String _currentUserId;
  final ShippingApiService _apiService = ShippingApiService(); // 實例化 API 服務

  List<ShippingOption> _shippingOptions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentUserId = getCurrentUserId();
    if (_currentUserId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "錯誤：用戶未登錄或無法獲取用戶ID";
      });
      print("錯誤：用戶未登錄或無法獲取用戶ID");
    } else {
      _loadShippingOptions();
    }
  }

  Future<void> _loadShippingOptions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final options = await _apiService.getShippingOptions(_currentUserId);
      if (mounted) {
        setState(() {
          _shippingOptions = options;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "加載運送方式失敗: $e";
          _isLoading = false;
        });
      }
      print("Error loading shipping options: $e");
    }
  }

  Future<void> _navigateToUpsertShippingOptionPage({ShippingOption? option}) async {
    final result = await showDialog<ShippingOption?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // UpsertShippingOptionDialog 現在將使用 apiService
        return UpsertShippingOptionDialog(
          apiService: _apiService, // 傳遞 apiService
          shippingOption: option,
          userId: _currentUserId,
        );
      },
    );

    if (result != null) {
      // 成功新增或更新後，重新加載列表以顯示最新數據
      _loadShippingOptions();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(option == null ? '運送方式已新增' : '運送方式已更新'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteShippingOption(ShippingOption option) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: Text('您確定要刪除 "${option.name}" 嗎？此操作無法復原。'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('刪除'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmDelete) {
      try {
        await _apiService.deleteShippingOption(option.id);
        if (mounted) {
          // 成功刪除後，重新加載列表
          _loadShippingOptions();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('運送方式已刪除'), duration: Duration(seconds: 2)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('刪除失敗: $e'), duration: const Duration(seconds: 2)),
          );
        }
        print("Error deleting shipping option: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget bodyContent;

    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      bodyContent = Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_errorMessage!, style: TextStyle(color: colorScheme.error, fontSize: 16), textAlign: TextAlign.center),
          )
      );
    } else if (_shippingOptions.isEmpty) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_shipping_outlined, size: 80, color: colorScheme.outline),
              const SizedBox(height: 16),
              Text('尚未設定任何運送方式', style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                '點擊右下角的「新增運送方式」按鈕，開始設定您可以提供的運送服務吧！',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      bodyContent = ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _shippingOptions.length,
        itemBuilder: (context, index) {
          // 為了確保列表更新，最好對列表進行排序（如果API未排序）
          // 或者在 _loadShippingOptions 成功後對 _shippingOptions 排序
          // 例如: _shippingOptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final option = _shippingOptions[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              title: Text(
                option.name,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '運費: \$${option.cost.toStringAsFixed(0)}', // 假設 cost 仍然是 double
                    style: textTheme.bodyMedium,
                  ),
                  if (option.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        option.description,
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      children: [
                        Icon(
                          option.isEnabled ? Icons.check_circle_outline : Icons.highlight_off_outlined,
                          color: option.isEnabled ? Colors.green.shade600 : colorScheme.error,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          option.isEnabled ? '已啟用' : '已停用',
                          style: textTheme.labelMedium?.copyWith(
                              color: option.isEnabled ? Colors.green.shade700 : colorScheme.error,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_note, color: colorScheme.primary, size: 26),
                    tooltip: '編輯',
                    onPressed: () => _navigateToUpsertShippingOptionPage(option: option),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_forever_outlined, color: colorScheme.error, size: 26),
                    tooltip: '刪除',
                    onPressed: () => _deleteShippingOption(option),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        shape: FullBottomConcaveAppBarShape(curveHeight: 20.0),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        actions: [ // 添加刷新按鈕以便測試
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _currentUserId.isNotEmpty ? _loadShippingOptions : null,
            tooltip: '刷新列表',
          )
        ],
      ),
      body: bodyContent,
      floatingActionButton: _currentUserId.isNotEmpty ? FloatingActionButton.extended(
        onPressed: () => _navigateToUpsertShippingOptionPage(),
        label: const Text('新增運送方式'),
        icon: const Icon(Icons.add_circle_outline),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        elevation: 4,
      ) : null,
    );
  }
}
