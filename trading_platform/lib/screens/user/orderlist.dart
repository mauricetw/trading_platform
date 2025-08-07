import 'package:first_flutter_project/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:first_flutter_project/models/order/order.dart';
import 'order_tracking.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

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
      return orderStatusToDisplayString(OrderStatus.established); // 使用 orderStatusToDisplayString
    case OrderListFilterValue.delivering:
      return orderStatusToDisplayString(OrderStatus.delivering); // 使用 orderStatusToDisplayString
    case OrderListFilterValue.completed:
      return orderStatusToDisplayString(OrderStatus.completed); // 使用 orderStatusToDisplayString
    case OrderListFilterValue.cancelled:
      return orderStatusToDisplayString(OrderStatus.cancelled); // 使用 orderStatusToDisplayString
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


class _OrderListScreenState extends State<OrderListScreen> {
  List<OrderModel> _allFetchedOrders = []; // 存儲從API獲取的完整列表
  bool _isLoading = true;
  String _error = '';
  OrderListFilterValue _currentFilter = OrderListFilterValue.all; // 當前選中的篩選條件

  // 預定義的篩選選項及其順序
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
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      final fetchedOrdersFromServer = [
        OrderModel(
          orderId: 'ORD-20231027-001',
          productName: 'Flutter開發實戰手冊 (第2版)',
          totalPrice: 49.99,
          orderDate: DateTime.now().subtract(const Duration(days: 5)),
          currentStatus: OrderStatus.completed,
          statusHistory: [
            OrderStatusUpdate(status: OrderStatus.established, timestamp: DateTime.now().subtract(const Duration(days: 5, hours: 2))),
            OrderStatusUpdate(status: OrderStatus.delivering, timestamp: DateTime.now().subtract(const Duration(days: 4)), description: "已發貨"),
            OrderStatusUpdate(status: OrderStatus.completed, timestamp: DateTime.now().subtract(const Duration(days: 3)), description: "已簽收"),
          ],
        ),
        OrderModel(
          orderId: 'ORD-20231026-003',
          productName: 'Dart編程高級指南 + 配套鼠標墊',
          totalPrice: 79.50,
          orderDate: DateTime.now().subtract(const Duration(days: 2)),
          currentStatus: OrderStatus.delivering,
          statusHistory: [
            OrderStatusUpdate(status: OrderStatus.established, timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 2))),
            OrderStatusUpdate(status: OrderStatus.delivering, timestamp: DateTime.now().subtract(const Duration(hours: 5)), description: "您的包裹已由快遞員攬收"),
          ],
        ),
        OrderModel(
            orderId: 'ORD-20231028-001',
            productName: '酷炫無線藍牙耳機Pro Max',
            totalPrice: 129.00,
            orderDate: DateTime.now().subtract(const Duration(hours: 3)),
            currentStatus: OrderStatus.established,
            statusHistory: [
              OrderStatusUpdate(status: OrderStatus.established, timestamp: DateTime.now().subtract(const Duration(hours: 3))),
            ]
        ),
        OrderModel(
          orderId: 'ORD-20231025-002',
          productName: '精美UI設計模板包 (企業版)',
          totalPrice: 25.00,
          orderDate: DateTime.now().subtract(const Duration(days: 10)),
          currentStatus: OrderStatus.cancelled,
        ),
        OrderModel(
            orderId: 'ORD-20231029-001',
            productName: '智能家居控制中心',
            totalPrice: 199.00,
            orderDate: DateTime.now().subtract(const Duration(minutes: 30)),
            currentStatus: OrderStatus.established,
            statusHistory: [
              OrderStatusUpdate(status: OrderStatus.established, timestamp: DateTime.now().subtract(const Duration(minutes: 30))),
            ]
        ),
        OrderModel(
          orderId: 'ORD-20231020-005',
          productName: '經典文學名著全集',
          totalPrice: 88.88,
          orderDate: DateTime.now().subtract(const Duration(days: 15)),
          currentStatus: OrderStatus.completed,
        ),
      ];

      if (mounted) {
        setState(() {
          _allFetchedOrders = fetchedOrdersFromServer;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '獲取訂單列表失敗: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<OrderModel> get _displayedOrders {
    final selectedOrderStatus = orderListFilterToOrderStatus(_currentFilter);
    if (selectedOrderStatus == null) {
      return _allFetchedOrders;
    }
    return _allFetchedOrders.where((order) => order.currentStatus == selectedOrderStatus).toList();
  }

  void _navigateToOrderTracking(BuildContext context, OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(orderId: order.orderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的訂單'),
        centerTitle: true,
        backgroundColor: primaryCS.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
            tooltip: '刷新列表',
          )
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildOrderList()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
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

  Widget _buildOrderList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(_error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                  onPressed: _fetchOrders,
                  icon: const Icon(Icons.refresh),
                  label: const Text("重試")
              )
            ],
          ),
        ),
      );
    }

    final ordersToDisplay = _displayedOrders;

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
              if (_currentFilter == OrderListFilterValue.all)
                Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: Text(
                    '快去選購您喜歡的商品吧！',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
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

  Widget _buildOrderItemCard(BuildContext context, OrderModel order) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 7.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          _navigateToOrderTracking(context, order);
        },
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
                      '訂單號: ${order.orderId}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(order.currentStatus),
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
                    ),
                    child: Icon(Icons.photo_size_select_actual_outlined, color: Colors.grey[500], size: 35),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.productName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '下單於: ${order.orderDate.toLocal().toString().substring(0, 10)}',
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
                  '合計: \$${order.totalPrice.toStringAsFixed(2)}',
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