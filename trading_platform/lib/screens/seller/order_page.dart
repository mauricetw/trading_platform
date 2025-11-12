// --- FILE: lib/screens/seller/order_page.dart ---
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order/order.dart';      // 1. 引入官方的 Order 模型
import '../../providers/seller_provider.dart'; // 2. 引入 SellerProvider

// 3. 移除本地的 Order 模型和 OrderStatus enum

// 主要的訂單管理頁面
class SellerOrderPage extends StatefulWidget {
  const SellerOrderPage({super.key});

  @override
  State<SellerOrderPage> createState() => _SellerOrderPageState();
}

class _SellerOrderPageState extends State<SellerOrderPage> {
  int _selectedFilterIndex = 0;

  // --- [BUG 修正 2] ---
  // 擴充篩選器，使其包含所有可能的狀態
  final List<String> _filterOptions = [
    '待確認',    // pending
    '待出貨',    // preparing
    '已出貨',    // delivering
    '已完成',    // completed
    '不成立',    // failed
    '已取消',    // cancelled
  ];

  // 5. 對應的 OrderStatus，注意順序要和 _filterOptions 一致
  final List<OrderStatus?> _filterStatuses = [
    OrderStatus.pending,
    OrderStatus.preparing,
    OrderStatus.delivering,
    OrderStatus.completed,
    OrderStatus.failed,
    OrderStatus.cancelled,
  ];
  // --- [BUG 修正 2 結束] ---


  @override
  void initState() {
    super.initState();
    // 6. 頁面初始化時，從 Provider 獲取資料
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFilteredOrders();
    });
  }

  // 7. 獲取訂單的邏輯現在呼叫 Provider
  Future<void> _fetchFilteredOrders() async {
    try {
      final provider = context.read<SellerProvider>();
      // 將 UI 的篩選狀態傳遞給 Provider
      // 確保 _selectedFilterIndex 不會超出範圍
      if (_selectedFilterIndex >= _filterStatuses.length) {
        _selectedFilterIndex = 0;
      }
      await provider.fetchSellerOrders(status: _filterStatuses[_selectedFilterIndex]);
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('載入訂單失敗: $e'), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 8. 使用 Consumer 來監聽 SellerProvider
    return Consumer<SellerProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.orange,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('訂單管理', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: Column(
            children: [
              _buildTopFilterBar(), // 10. 將篩選器改為頂部橫向滾動
              Expanded(
                child: _buildBodyContent(provider),
              ),
              // _buildBottomFilterBar(), // (移除底部篩選器)
            ],
          ),
        );
      },
    );
  }

  // 9. 根據 Provider 的狀態顯示不同的 UI
  Widget _buildBodyContent(SellerProvider provider) {
    if (provider.isLoading && provider.sellerOrders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && provider.sellerOrders.isEmpty) {
      return Center(child: Text('錯誤: ${provider.error}'));
    }
    if (provider.sellerOrders.isEmpty) {
      return Center(child: Text('"${_filterOptions[_selectedFilterIndex]}" 分類下沒有訂單。'));
    }

    return RefreshIndicator(
      onRefresh: _fetchFilteredOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: provider.sellerOrders.length,
        itemBuilder: (context, index) {
          final order = provider.sellerOrders[index];
          return OrderCard(
            order: order,
            onTap: () => _showOrderDetails(order),
          );
        },
      ),
    );
  }

  // 10. 底部篩選器現在會觸發 API 重新獲取 (改為頂部)
  Widget _buildTopFilterBar() {
    return Container(
      height: 60, // 給定一個固定高度
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
              _fetchFilteredOrders(); // 點擊後重新獲取資料
            },
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _filterOptions[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 11. 彈出視窗的邏輯現在呼叫 Provider
  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 讓 Sheet 本身透明
      builder: (context) => Padding(
        // 增加一個 padding，讓鍵盤彈出時不會遮擋
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: OrderDetailsSheet(
          order: order,
          // onOrderUpdated 回呼不再需要，因為 Provider 會自動更新 UI
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order; // 12. 現在使用官方的 Order 模型
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    // 13. 適配新的 Order 模型
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final displayTitle = firstItem?.product.name ?? '商品資訊錯誤';
    final totalQuantity = order.items.fold(0, (sum, item) => sum + item.quantity);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
                image: firstItem != null && firstItem.product.imageUrls.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(firstItem.product.imageUrls.first),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: (firstItem == null || firstItem.product.imageUrls.isEmpty)
                  ? const Icon(Icons.inventory_2_outlined, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$displayTitle${order.items.length > 1 ? '...等 ${order.items.length} 件商品' : ''}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('X$totalQuantity', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onTap,
                        child: const Row(
                          children: [
                            Text('訂單詳細', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NT\$${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('yyyy-MM-dd').format(order.createdAt.toLocal()),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderDetailsSheet extends StatefulWidget {
  final Order order;
  const OrderDetailsSheet({super.key, required this.order});

  @override
  State<OrderDetailsSheet> createState() => _OrderDetailsSheetState();
}

class _OrderDetailsSheetState extends State<OrderDetailsSheet> {

  // 14. 統一的狀態更新方法
  Future<void> _updateOrderStatus(OrderStatus newStatus, {String? description}) async {
    final provider = context.read<SellerProvider>();
    try {
      await provider.updateOrderStatus(widget.order.orderId, newStatus, description: description);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('訂單狀態已更新為 "${orderStatusToDisplayString(newStatus)}"'), backgroundColor: Colors.green),
        );
      }
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失敗: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 15. UI 事件處理函式現在都呼叫 _updateOrderStatus
  void _handleShipOrder(Order order) {
    _showConfirmationDialog(
      '確認出貨',
      '確定要將訂單 #${order.orderId} 標記為已出貨嗎？',
          () => _updateOrderStatus(OrderStatus.delivering), // 狀態改為 delivering
    );
  }

  void _handleCancelOrder(Order order) {
    _showConfirmationDialog(
      '取消訂單',
      '確定要取消訂單 #${order.orderId} 嗎？此為不成立訂單。',
      // --- [BUG 修正 1] ---
      // 「取消」訂單應該使用 'cancelled' 狀態
          () => _updateOrderStatus(OrderStatus.cancelled),
    );
  }

  void _handleReactivateOrder(Order order) {
    _showConfirmationDialog(
      '重新啟用訂單',
      '確定要將訂單 #${order.orderId} 重新啟用為「待出貨」嗎？',
          () => _updateOrderStatus(OrderStatus.preparing),
    );
  }

  void _handleAcceptOrder(Order order) {
    _showConfirmationDialog(
      '接受訂單',
      '確定要接受訂單 #${order.orderId} 嗎？狀態將更新為「待出貨」。',
          () => _updateOrderStatus(OrderStatus.preparing),
    );
  }

  void _handleRejectOrder(Order order) {
    _showConfirmationDialog(
      '拒絕訂單',
      '確定要拒絕訂單 #${order.orderId} 嗎？此操作將使訂單不成立。',
          () => _updateOrderStatus(OrderStatus.failed), // 拒絕訂單 -> failed (這個邏輯是OK的)
    );
  }

  void _handleViewReceipt(Order order) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看訂單 #${order.orderId} 的收據 (功能待實現)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 讓 BottomSheet 內容可以滾動
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('訂單詳細資料', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('訂單編號', '#${widget.order.orderId}'),
            _buildDetailRow('商品名稱', widget.order.items.map((e) => e.product.name).join(', ')),
            _buildDetailRow('總金額', 'NT\$${widget.order.totalAmount.toStringAsFixed(0)}'),
            _buildDetailRow('狀態', orderStatusToDisplayString(widget.order.status)),
            _buildDetailRow('物流方式', widget.order.shippingMethod['name'] ?? '未知'),
            _buildDetailRow('下單時間', DateFormat('yyyy-MM-dd HH:mm').format(widget.order.createdAt.toLocal())),
            const SizedBox(height: 20),
            _buildStatusActionButtons(widget.order),
            const SizedBox(height: 20), // 增加一點空間
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusActionButtons(Order order) {
    // 16. 根據我們優化後的流程，更新按鈕的顯示邏輯
    switch (order.status) {
      case OrderStatus.pending: // 新增：處理 "待確認" 狀態
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleAcceptOrder(order),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('接受訂單', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleRejectOrder(order),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('拒絕訂單', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      case OrderStatus.preparing: // '待出貨' 對應 'preparing'
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleShipOrder(order),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('確認出貨', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleCancelOrder(order),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('取消訂單', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );

      case OrderStatus.cancelled:
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '此訂單已取消', // (文字修正)
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleReactivateOrder(order),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.orange),
                    ),
                    child: const Text('重新啟用', style: TextStyle(color: Colors.orange)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('關閉'),
                  ),
                ),
              ],
            ),
          ],
        );

      case OrderStatus.completed:
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green[600], size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '訂單已完成交易',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleViewReceipt(order),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.green),
                    ),
                    child: const Text('查看收據', style: TextStyle(color: Colors.green)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('關閉'),
                  ),
                ),
              ],
            ),
          ],
        );

      case OrderStatus.failed:
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '訂單未接受或已拒絕',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleAcceptOrder(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('接受訂單', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('關閉'),
                  ),
                ),
              ],
            ),
          ],
        );

    // --- [BUG 修正 2] ---
    // 納入 'delivering' 狀態
      case OrderStatus.delivering:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                '商品已出貨 (狀態: ${orderStatusToDisplayString(order.status)})',
                style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );

      default:
      // 處理 established 等其他狀態
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[800], size: 20),
              const SizedBox(width: 8),
              Text(
                '未知狀態: ${orderStatusToDisplayString(order.status)}',
                style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
    }
  }

  void _showConfirmationDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('確認', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}