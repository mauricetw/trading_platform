import 'package:flutter/material.dart';

// 資料模型
class Order {
  final String id;
  final String title;
  final int price;
  final int quantity;
  final OrderStatus status;
  final String dueTime;
  final String paymentMethod;

  Order({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.status,
    required this.dueTime,
    required this.paymentMethod,
  });
}

enum OrderStatus {
  pending,    // 待出貨
  failed,     // 不成立
  completed,  // 已完成
  rejected,   // 未接受
}

// 主要的訂單管理頁面
class SellerOrderPage extends StatefulWidget {
  const SellerOrderPage({super.key});

  @override
  State<SellerOrderPage> createState() => _SellerOrderPageState();
}

class _SellerOrderPageState extends State<SellerOrderPage> {
  int selectedFilterIndex = 0;

  final List<String> filterOptions = ['待出貨', '不成立', '已完成', '未接受'];

  final List<Order> orders = [
    Order(
      id: '123456',
      title: '大二下專業必修課...',
      price: 1039,
      quantity: 1,
      status: OrderStatus.pending,
      dueTime: '2024-12-31',
      paymentMethod: '現場面交',
    ),
    Order(
      id: '123457',
      title: '高等微積分教科書...',
      price: 850,
      quantity: 1,
      status: OrderStatus.failed,
      dueTime: '2024-12-25',
      paymentMethod: '銀行轉帳',
    ),
    Order(
      id: '123458',
      title: '計算機概論講義...',
      price: 650,
      quantity: 2,
      status: OrderStatus.completed,
      dueTime: '2024-12-20',
      paymentMethod: '信用卡',
    ),
    Order(
      id: '123459',
      title: '統計學習教材...',
      price: 750,
      quantity: 1,
      status: OrderStatus.rejected,
      dueTime: '2024-12-28',
      paymentMethod: '現場面交',
    ),
  ];

  List<Order> get filteredOrders {
    switch (selectedFilterIndex) {
      case 0:
        return orders.where((order) => order.status == OrderStatus.pending).toList();
      case 1:
        return orders.where((order) => order.status == OrderStatus.failed).toList();
      case 2:
        return orders.where((order) => order.status == OrderStatus.completed).toList();
      case 3:
        return orders.where((order) => order.status == OrderStatus.rejected).toList();
      default:
        return orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '訂單管理',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 訂單列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return OrderCard(
                  order: order,
                  onTap: () => _showOrderDetails(order),
                );
              },
            ),
          ),

          // 底部篩選按鈕
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(filterOptions.length, (index) {
                final isSelected = selectedFilterIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilterIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.blue[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        filterOptions[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      builder: (context) => OrderDetailsSheet(
        order: order,
        onOrderUpdated: (updatedOrder) {
          setState(() {
            final index = orders.indexWhere((o) => o.id == updatedOrder.id);
            if (index != -1) {
              orders[index] = updatedOrder;
            }
          });
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
            // 商品圖片
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.book,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // 商品資訊
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'X${order.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onTap,
                        child: const Row(
                          children: [
                            Text(
                              '訂單詳細',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: Colors.grey,
                            ),
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
                        '\$${order.price}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        order.dueTime,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
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
  final Function(Order) onOrderUpdated;

  const OrderDetailsSheet({
    super.key,
    required this.order,
    required this.onOrderUpdated,
  });

  @override
  State<OrderDetailsSheet> createState() => _OrderDetailsSheetState();
}

class _OrderDetailsSheetState extends State<OrderDetailsSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
              const Text(
                '訂單詳細資料',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildDetailRow('訂單編號', widget.order.id),
          _buildDetailRow('商品名稱', widget.order.title),
          _buildDetailRow('賣家累付金額', '\$${widget.order.price}'),
          _buildDetailRow('狀態', _getStatusText(widget.order.status)),
          _buildDetailRow('物流方式', widget.order.paymentMethod),
          _buildDetailRow('數量', '${widget.order.quantity}'),
          _buildDetailRow('到期時間', widget.order.dueTime),

          const SizedBox(height: 20),

          // 根據訂單狀態顯示不同的操作按鈕
          _buildStatusActionButtons(widget.order),
        ],
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
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusActionButtons(Order order) {
    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleShipOrder(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('確認出貨', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleCancelOrder(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('取消訂單', style: TextStyle(color: Colors.white)),
              ),
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
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '此訂單已取消或不成立',
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

      case OrderStatus.rejected:
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
    }
  }

  void _handleShipOrder(Order order) {
    Navigator.of(context).pop();
    _showConfirmationDialog(
      '確認出貨',
      '確定要將訂單 ${order.id} 標記為已出貨嗎？',
          () => _updateOrderStatus(order, OrderStatus.completed),
    );
  }

  void _handleCancelOrder(Order order) {
    Navigator.of(context).pop();
    _showConfirmationDialog(
      '取消訂單',
      '確定要取消訂單 ${order.id} 嗎？此操作無法復原。',
          () => _updateOrderStatus(order, OrderStatus.failed),
    );
  }

  void _handleReactivateOrder(Order order) {
    Navigator.of(context).pop();
    _showConfirmationDialog(
      '重新啟用訂單',
      '確定要重新啟用訂單 ${order.id} 嗎？',
          () => _updateOrderStatus(order, OrderStatus.pending),
    );
  }

  void _handleAcceptOrder(Order order) {
    Navigator.of(context).pop();
    _showConfirmationDialog(
      '接受訂單',
      '確定要接受訂單 ${order.id} 嗎？',
          () => _updateOrderStatus(order, OrderStatus.pending),
    );
  }

  void _handleViewReceipt(Order order) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看訂單 ${order.id} 的收據')),
    );
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

  void _updateOrderStatus(Order order, OrderStatus newStatus) {
    final updatedOrder = Order(
      id: order.id,
      title: order.title,
      price: order.price,
      quantity: order.quantity,
      status: newStatus,
      dueTime: order.dueTime,
      paymentMethod: order.paymentMethod,
    );

    widget.onOrderUpdated(updatedOrder);

    String message = '';
    switch (newStatus) {
      case OrderStatus.completed:
        message = '訂單已標記為完成';
        break;
      case OrderStatus.failed:
        message = '訂單已取消';
        break;
      case OrderStatus.pending:
        message = '訂單已更新為待處理';
        break;
      case OrderStatus.rejected:
        message = '訂單已拒絕';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return '待出貨';
      case OrderStatus.failed:
        return '不成立';
      case OrderStatus.completed:
        return '已完成';
      case OrderStatus.rejected:
        return '未接受';
    }
  }
}