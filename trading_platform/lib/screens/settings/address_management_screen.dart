// --- FILE: lib/screens/settings/address_management_screen.dart ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../models/user/address.dart';
import 'address_form_screen.dart'; // 1. 引入我們即將建立的表單頁面

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  @override
  void initState() {
    super.initState();
    // 2. 進入頁面時，立即獲取地址
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAddresses();
    });
  }

  Future<void> _refreshAddresses() async {
    try {
      await context.read<AddressProvider>().fetchAddresses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('無法載入地址: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 3. 導航到表單頁面
  void _navigateToAddEditAddress({Address? address}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // 傳遞 'address' 參數：
        // - 如果是 null，表單頁面知道是「新增」模式
        // - 如果不是 null，表單頁面知道是「編輯」模式
        builder: (context) => AddressFormScreen(addressToEdit: address),
      ),
    );
  }

  // 4. 顯示刪除確認
  void _showDeleteConfirmation(Address address) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: Text('確定要刪除地址「${address.recipientName} - ${address.city}」嗎？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // 先關閉對話框
                try {
                  await context.read<AddressProvider>().deleteAddress(address.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('地址已刪除'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('刪除失敗: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('刪除'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理我的地址'),
        actions: [
          // "新增" 按鈕
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddEditAddress(address: null),
          ),
        ],
      ),
      // 5. 使用 Consumer 監聽 AddressProvider
      body: Consumer<AddressProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.addresses.isEmpty) {
            return Center(child: Text('錯誤: ${provider.error}'));
          }
          if (provider.addresses.isEmpty) {
            return const Center(child: Text('您尚未新增任何地址。'));
          }

          return RefreshIndicator(
            onRefresh: _refreshAddresses,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: provider.addresses.length,
              itemBuilder: (context, index) {
                final address = provider.addresses[index];
                return _buildAddressCard(address);
              },
            ),
          );
        },
      ),
    );
  }

  // 6. 建立地址卡片 UI
  Widget _buildAddressCard(Address address) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address.recipientName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '預設',
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(address.phoneNumber),
            const SizedBox(height: 4),
            Text(address.displayAddress), // 使用我們在模型中建立的 getter
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                  onPressed: () => _showDeleteConfirmation(address),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor),
                  onPressed: () => _navigateToAddEditAddress(address: address),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}