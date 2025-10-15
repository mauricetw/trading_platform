// --- FILE: lib/screens/user/order_tracking.dart ---
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart'; // 確保已在 pubspec.yaml 加入 timeline_tile

import '../../providers/order_provider.dart';
import '../../models/order/order.dart';

class OrderTrackingScreen extends StatefulWidget {
  // 修正：ID 類型應為 int
  final int orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // REFACTORED: 移除所有本地狀態 (_order, _isLoading, _error)

  // 保留組員的設計：定義步驟條的顯示順序
  final List<OrderStatus> _allPossibleStatuses = [
    OrderStatus.pending,
    OrderStatus.preparing,
    OrderStatus.delivering,
    OrderStatus.completed,
  ];

  @override
  void initState() {
    super.initState();
    // REFACTORED: 透過 Provider 獲取訂單詳情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrderById(widget.orderId);
    });
  }

  // REFACTORED: 刷新邏輯
  Future<void> _refreshOrder() async {
    await context.read<OrderProvider>().fetchOrderById(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    // REFACTORED: 使用 Consumer 來監聽 Provider 的狀態
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        final order = provider.selectedOrder;

        return Scaffold(
          appBar: AppBar(
            title: Text('訂單追蹤 #${widget.orderId}'),
          ),
          body: RefreshIndicator(
            onRefresh: _refreshOrder,
            child: _buildBody(provider, order),
          ),
        );
      },
    );
  }

  Widget _buildBody(OrderProvider provider, Order? order) {
    if (provider.isDetailLoading && order == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.detailError != null) {
      return Center(child: Text(provider.detailError!, style: const TextStyle(color: Colors.red)));
    }
    if (order == null) {
      return const Center(child: Text('未找到訂單信息。'));
    }

    // 特殊處理已取消或已退款的訂單
    if (order.status == OrderStatus.cancelled || order.status == OrderStatus.refunded) {
      return _buildCancelledOrderView(order);
    }

    int currentStatusIndex = _allPossibleStatuses.indexOf(order.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderSummary(order),
          const SizedBox(height: 24),
          Text('訂單進度', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          if (currentStatusIndex != -1)
            _buildStatusStepper(order, currentStatusIndex),
          const SizedBox(height: 24),
          Text('狀態歷史', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildStatusHistory(order.statusHistory ?? []),
        ],
      ),
    );
  }

  // --- 以下 UI Builder Widgets 完整保留組員的設計，並適配新模型 ---

  Widget _buildCancelledOrderView(Order order) {
    bool isCancelled = order.status == OrderStatus.cancelled;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCancelled ? Icons.cancel_outlined : Icons.settings_backup_restore_outlined,
              size: 60,
              color: isCancelled ? Colors.red : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              orderStatusToDisplayString(order.status),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: isCancelled ? Colors.red : Colors.orange),
            ),
            const SizedBox(height: 8),
            Text("訂單 #${order.orderId} 的當前狀態。", textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(Order order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('訂單號: #${order.orderId}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(height: 16),
            // REFACTORED: 顯示商品列表
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(child: Text('${item.product.name} x ${item.quantity}')),
                  Text('NT\$${(item.priceAtPurchase * item.quantity).toStringAsFixed(0)}'),
                ],
              ),
            )),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('總金額:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'NT\$${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStepper(Order order, int currentStatusIndex) {
    return Column(
      children: List.generate(_allPossibleStatuses.length, (index) {
        final status = _allPossibleStatuses[index];
        bool isActive = index == currentStatusIndex;
        bool isCompleted = index < currentStatusIndex;

        final historyEntry = order.statusHistory?.lastWhere(
              (h) => h.status == status,
          orElse: () => OrderStatusUpdate(status: status, timestamp: DateTime.now(), description: "狀態尚未到達"),
        );

        return _buildStatusStep(
          icon: getOrderStatusIcon(status),
          title: orderStatusToDisplayString(status),
          timestamp: (isCompleted || isActive) && order.statusHistory?.any((h) => h.status == status) == true
              ? historyEntry?.timestamp
              : null,
          description: isActive && order.statusHistory?.any((h) => h.status == status) == true
              ? historyEntry?.description
              : null,
          isFirst: index == 0,
          isLast: index == _allPossibleStatuses.length - 1,
          isActive: isActive,
          isCompleted: isCompleted,
        );
      }),
    );
  }

  Widget _buildStatusStep({
    required IconData icon,
    required String title,
    DateTime? timestamp,
    String? description,
    required bool isFirst,
    required bool isLast,
    required bool isActive,
    required bool isCompleted,
  }) {
    Color activeColor = Theme.of(context).primaryColor;
    Color completedColor = Colors.green;
    Color inactiveColor = Colors.grey[400]!;

    Color circleColor = inactiveColor;
    Color iconColor = Colors.white;
    TextStyle titleStyle = TextStyle(color: inactiveColor, fontSize: 16);
    TextStyle timeStyle = TextStyle(color: Colors.grey[600], fontSize: 12);

    if (isActive) {
      circleColor = activeColor;
      titleStyle = TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 16);
    } else if (isCompleted) {
      circleColor = completedColor;
      titleStyle = TextStyle(color: completedColor, fontSize: 16);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 20,
                  color: isCompleted || isActive ? (isCompleted ? completedColor : activeColor) : inactiveColor,
                ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  border: isActive ? Border.all(color: Colors.white, width: 2) : null,
                  boxShadow: isActive ? [BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 5, spreadRadius: 1)] : null,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? completedColor : inactiveColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: isFirst ? 6 : 24, bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: titleStyle),
                  if (timestamp != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toLocal()),
                        style: timeStyle,
                      ),
                    ),
                  if (description != null && description.isNotEmpty && isActive)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        description,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
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

  Widget _buildStatusHistory(List<OrderStatusUpdate> history) {
    if (history.isEmpty) {
      return const Text('暫無狀態更新記錄。');
    }
    final sortedHistory = List<OrderStatusUpdate>.from(history)..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedHistory.length,
      itemBuilder: (context, index) {
        final entry = sortedHistory[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(getOrderStatusIcon(entry.status), size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(orderStatusToDisplayString(entry.status), style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(entry.timestamp.toLocal()),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    if (entry.description != null && entry.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(entry.description!, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}