// --- FILE: lib/screens/seller/shipping_setting_page.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. 引入 Provider

import '../../providers/seller_provider.dart'; // 2. 引入我們新建的 SellerProvider
import '../../widgets/upsert_shipping_option_dialog.dart';
import '../../models/user/shipping_option.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';
import '../../theme/app_theme.dart';

class ShippingSettingsPage extends StatefulWidget {
  const ShippingSettingsPage({super.key});

  @override
  State<ShippingSettingsPage> createState() => _ShippingSettingsPageState();
}

class _ShippingSettingsPageState extends State<ShippingSettingsPage> {
  @override
  void initState() {
    super.initState();
    // 確保 build 完成後再獲取資料，避免錯誤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 頁面初始化時，立即從後端獲取運送選項
      _refreshOptions();
    });
  }

  // 抽離出刷新邏輯，呼叫 Provider
  Future<void> _refreshOptions() async {
    try {
      await context.read<SellerProvider>().fetchShippingOptions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('無法載入運送方式: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 導航到新增/編輯對話框
  Future<void> _navigateToUpsertDialog({ShippingOption? option}) async {
    final result = await showDialog<ShippingOption?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Dialog 現在會自動從 Provider 體系中獲取 OrderService
        return UpsertShippingOptionDialog(
          shippingOption: option,
        );
      },
    );

    if (result != null && mounted) {
      // 成功新增或更新後，Provider 會自動更新列表，我們只需顯示一個提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(option == null ? '運送方式已新增' : '運送方式已更新'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // 刪除運送方式
  Future<void> _deleteShippingOption(ShippingOption option) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: Text('您確定要刪除 "${option.name}" 嗎？'),
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

    if (confirmDelete && mounted) {
      try {
        await context.read<SellerProvider>().deleteShippingOption(option.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('運送方式已刪除'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('刪除失敗: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Consumer 來獲取並監聽 SellerProvider 的狀態
    return Consumer<SellerProvider>(
      builder: (context, provider, child) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          appBar: AppBar(
            title: const Text('運送設定'),
            shape: const FullBottomConcaveAppBarShape(curveHeight: 20.0),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary, // 修正顏色以確保可見性
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshOptions,
                tooltip: '刷新列表',
              )
            ],
          ),
          body: _buildBodyContent(provider, textTheme, colorScheme),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _navigateToUpsertDialog(),
            label: const Text('新增運送方式'),
            icon: const Icon(Icons.add_circle_outline),
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
            elevation: 4,
          ),
        );
      },
    );
  }

  // --- 以下 UI Builder Widgets 完整保留組員的設計，並適配 Provider ---

  Widget _buildBodyContent(SellerProvider provider, TextTheme textTheme, ColorScheme colorScheme) {
    if (provider.isLoading && provider.shippingOptions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(provider.error!, style: TextStyle(color: colorScheme.error, fontSize: 16), textAlign: TextAlign.center),
          )
      );
    }

    if (provider.shippingOptions.isEmpty) {
      return Center(
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
                '點擊右下角的「新增」按鈕，開始設定您可以提供的運送服務吧！',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshOptions,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 80), // 增加底部 padding，避免被 FAB 遮擋
        itemCount: provider.shippingOptions.length,
        itemBuilder: (context, index) {
          final option = provider.shippingOptions[index];
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
                    '運費: \$${option.cost.toStringAsFixed(0)}',
                    style: textTheme.bodyMedium,
                  ),
                  if (option.description != null && option.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        option.description!,
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
                    onPressed: () => _navigateToUpsertDialog(option: option),
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
      ),
    );
  }
}
