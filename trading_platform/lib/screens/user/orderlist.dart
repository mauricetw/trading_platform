// --- FILE: lib/screens/user/orderlist.dart ---
import 'package:first_flutter_project/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order/order.dart';
import '../../providers/order_provider.dart';
import 'order_tracking.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

// --- 以下 Enums 和 Helpers 完整保留組員的設計 ---
enum OrderListFilterValue {
  all,
  established,
  delivering,
  completed,
  cancelled,
}

String orderListFilterValueToString(OrderListFilterValue filterVal) {
  switch (filterVal) {
    case OrderListFilterValue.all:
      return '全部';
    case OrderListFilterValue.established:
      return orderStatusToDisplayString(OrderStatus.established);
    case OrderListFilterValue.delivering:
      return orderStatusToDisplayString(OrderStatus.delivering);
    case OrderListFilterValue.completed:
      return orderStatusToDisplayString(OrderStatus.completed);
    case OrderListFilterValue.cancelled:
      return orderStatusToDisplayString(OrderStatus.cancelled);
  }
}

OrderStatus? orderListFilterToOrderStatus(OrderListFilterValue filterVal) {
  switch (filterVal) {
    case OrderListFilterValue.all:
      return null;
    case OrderListFilterValue.established:
      return OrderStatus.established;
    case OrderListFilterValue.delivering:
      return OrderStatus.delivering;
    case OrderListFilterValue.completed:
      return OrderStatus.completed;
    case OrderListFilterValue.cancelled:
      return OrderStatus.cancelled;
  }
}
// --- Helpers 結束 ---

class _OrderListScreenState extends State<OrderListScreen> {
  OrderListFilterValue _currentFilter = OrderListFilterValue.all;

  final List<OrderListFilterValue> _filterOptions = [
    OrderListFilterValue.all,
    OrderListFilterValue.delivering,
    OrderListFilterValue.completed,
    OrderListFilterValue.established,
    OrderListFilterValue.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    // 確保 build 完成後再獲取資料，避免錯誤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 頁面初始化時，立即從後端獲取訂單列表
      _refreshOrders();
    });
  }

  // REFACTORED: 抽離出刷新邏輯，呼叫 Provider
  Future<void> _refreshOrders() async {
    try {
      await context.read<OrderProvider>().fetchMyOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('無法載入訂單: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- 關鍵修正：實現真實的導航 ---
  void _navigateToOrderTracking(BuildContext context, Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(orderId: order.orderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Consumer 來獲取並監聽 OrderProvider 的狀態
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        // REFACTORED: 根據 Provider 的狀態動態計算要顯示的訂單列表
        final allOrders = provider.orders;
        final displayedOrders = _getDisplayedOrders(allOrders);

        return Scaffold(
          appBar: AppBar(
            title: const Text('我的訂單'),
            centerTitle: true,
            backgroundColor: primaryCS.secondary,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshOrders,
                tooltip: '刷新列表',
              )
            ],
          ),
          body: Column(
            children: [
              _buildFilterBar(allOrders),
              Expanded(child: _buildOrderList(provider, displayedOrders)),
            ],
          ),
        );
      },
    );
  }

  // REFACTORED: 本地篩選邏輯，處理來自 Provider 的資料
  List<Order> _getDisplayedOrders(List<Order> allOrders) {
    final selectedOrderStatus = orderListFilterToOrderStatus(_currentFilter);
    if (selectedOrderStatus == null) {
      return allOrders;
    }
    return allOrders.where((order) => order.status == selectedOrderStatus).toList();
  }

  // --- 以下 UI Builder Widgets 完整保留組員的設計，並適配新模型 ---

  Widget _buildFilterBar(List<Order> allOrders) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      color: Theme.of(context).canvasColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ToggleButtons(
          isSelected: _filterOptions.map((option) => _currentFilter == option).toList(),
          onPressed: (int index) {
            if (!mounted) return;
            setState(() {
              _currentFilter = _filterOptions[index];
            });
          },
          borderRadius: BorderRadius.circular(20.0),
          selectedBorderColor: Theme.of(context).primaryColor,
          selectedColor: Colors.white,
          fillColor: Theme.of(context).primaryColor,
          color: Theme.of(context).primaryColorDark,
          splashColor: Theme.of(context).primaryColor.withOpacity(0.12),
          hoverColor: Theme.of(context).primaryColor.withOpacity(0.04),
          constraints: const BoxConstraints(minHeight: 38.0, minWidth: 90.0),
          children: _filterOptions.map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(orderListFilterValueToString(option), style: const TextStyle(fontWeight: FontWeight.w500)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderList(OrderProvider provider, List<Order> ordersToDisplay) {
    if (provider.isListLoading && ordersToDisplay.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.listError != null && ordersToDisplay.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(provider.listError!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                  onPressed: _refreshOrders,
                  icon: const Icon(Icons.refresh),
                  label: const Text("重試")
              )
            ],
          ),
        ),
      );
    }

    if (ordersToDisplay.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_outlined, color: Colors.grey[400], size: 60),
              const SizedBox(height: 16),
              Text(
                _currentFilter == OrderListFilterValue.all
                    ? '您還沒有任何訂單'
                    : '在此篩選條件下沒有訂單',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: ordersToDisplay.length,
        itemBuilder: (context, index) {
          final order = ordersToDisplay[index];
          return _buildOrderItemCard(context, order);
        },
      ),
    );
  }

  Widget _buildOrderItemCard(BuildContext context, Order order) {
    // REFACTORED: 適配新的 Order 模型
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final firstProduct = firstItem?.product;
    final displayProductName = firstProduct != null
        ? '${firstProduct.name}${order.items.length > 1 ? '...等 ${order.items.length} 件商品' : ''}'
        : '商品資訊錯誤';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 7.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _navigateToOrderTracking(context, order),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '訂單號: #${order.orderId}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(order.status),
                ],
              ),
              const Divider(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      image: firstProduct != null && firstProduct.imageUrls.isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(firstProduct.imageUrls.first),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: (firstProduct == null || firstProduct.imageUrls.isEmpty)
                        ? Icon(Icons.photo_size_select_actual_outlined, color: Colors.grey[500], size: 35)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayProductName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '下單於: ${DateFormat('yyyy-MM-dd').format(order.createdAt.toLocal())}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '合計: \$${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// MODIFIED HERE
  Widget _buildStatusChip(OrderStatus status) {
    Color chipColor;
    Color textColor = Colors.white;
    String statusText = orderStatusToDisplayString(status); // 使用 orderStatusToDisplayString
    IconData iconData = getOrderStatusIcon(status);

    switch (status) {
      case OrderStatus.established:
        chipColor = Colors.blueGrey;
        break;
      case OrderStatus.paid: // Added for completeness
        chipColor = Colors.teal;
        break;
      case OrderStatus.preparing: // Added for completeness
        chipColor = Colors.purpleAccent;
        break;
      case OrderStatus.delivering:
        chipColor = Colors.blueAccent;
        break;
      case OrderStatus.completed:
        chipColor = Colors.green.shade600;
        break;
      case OrderStatus.cancelled:
        chipColor = Colors.redAccent.shade400;
        break;
      case OrderStatus.refunded: // Added for completeness
        chipColor = Colors.amber.shade700;
        break;
      default:
        chipColor = Colors.orangeAccent;
    }

    return Chip(
      avatar: Icon(iconData, size: 15, color: textColor.withOpacity(0.9)),
      label: Text(statusText, style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w500)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
      labelPadding: const EdgeInsets.only(left: 1, right: 5),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}