import 'package:flutter/material.dart';
import 'package:first_flutter_project/models/order/order.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId; // 傳入要追蹤的訂單 ID

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  OrderModel? _order; // 用於存儲獲取到的訂單數據
  bool _isLoading = true;
  String _error = '';

  // 定義所有可能的訂單流程節點 (即使某些訂單可能跳過某些步驟)
  // 順序很重要，它定義了步驟條的顯示順序
  final List<OrderStatus> _allPossibleStatuses = [
    OrderStatus.established,
    // OrderStatus.paid, // 如果這是一個獨立的明確步驟
    // OrderStatus.preparing, // 如果這是一個獨立的明確步驟
    OrderStatus.delivering,
    OrderStatus.completed,
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      // --- 模擬 API 調用 ---
      await Future.delayed(const Duration(seconds: 1)); // 模擬網絡延遲
      // 在實際應用中，這裡會調用您的 ApiService.getOrderById(widget.orderId)
      // 假設我們獲取到一個模擬的訂單數據
      final fetchedOrder = OrderModel(
        // id: widget.orderId, // 如果 OrderModel 的 id 字段用於 Firestore ID
        orderId: widget.orderId, // 如果 OrderModel 仍有 orderId 字段
        productName: '示例商品 Flutter Pro Max',
        totalPrice: 999.99,
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        currentStatus: OrderStatus.delivering, // 假設當前狀態是配送中
        statusHistory: [ // 模擬狀態歷史
          OrderStatusUpdate(status: OrderStatus.established, timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 2))),
          OrderStatusUpdate(status: OrderStatus.delivering, timestamp: DateTime.now().subtract(const Duration(hours: 5)), description: "包裹已攬收，準備發往目的地"),
        ],
      );
      // --- 模擬結束 ---

      // 為了演示，我們允許手動更新狀態
      // _updateOrderStatus(fetchedOrder, OrderStatus.completed); // 取消註釋以測試 "已完成"

      if (mounted) { // 檢查 widget 是否還在 widget tree 中
        setState(() {
          _order = fetchedOrder;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '獲取訂單詳情失敗: $e';
          _isLoading = false;
        });
      }
    }
  }

  // 可選：用於演示更新訂單狀態的函數
  void _updateOrderStatus(OrderModel order, OrderStatus newStatus) {
    if(mounted){
      setState(() {
        // 使用 copyWith 創建新實例是推薦的做法，特別是如果 OrderModel 字段是 final 的
        final updatedStatusHistory = List<OrderStatusUpdate>.from(order.statusHistory)
          ..add(OrderStatusUpdate(
              status: newStatus,
              timestamp: DateTime.now(),
              description: "狀態手動更新為 ${orderStatusToDisplayString(newStatus)}" // MODIFIED HERE
          ));

        _order = order.copyWith( // 假設 OrderModel 有 copyWith 方法
            currentStatus: newStatus,
            statusHistory: updatedStatusHistory
        );

        // 如果 OrderModel 的 currentStatus 不是 final，可以直接修改，但 copyWith 更好
        // order.currentStatus = newStatus;
        // order.statusHistory.add(
        //     OrderStatusUpdate(status: newStatus, timestamp: DateTime.now(), description: "狀態手動更新為 ${orderStatusToDisplayString(newStatus)}") // MODIFIED HERE
        // );
        // _order = OrderModel( // 創建一個新的實例來觸發UI更新 (如果 OrderModel 是不可變的)
        //     id: order.id,
        //     orderId: order.orderId,
        //     productName: order.productName,
        //     totalPrice: order.totalPrice,
        //     orderDate: order.orderDate,
        //     currentStatus: order.currentStatus,
        //     statusHistory: List.from(order.statusHistory) // 創建新的列表副本
        // );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('訂單追蹤 #${_order?.orderId.substring(0, (_order?.orderId.length ?? 8) > 8 ? 8 : (_order?.orderId.length ?? 0) )}...'), // 只顯示部分ID，並處理 orderId 可能為 null 或太短
      ),
      body: _buildBody(),
      // 可選的刷新按鈕
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchOrderDetails,
        tooltip: '刷新狀態',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(child: Text(_error, style: const TextStyle(color: Colors.red)));
    }
    if (_order == null) {
      return const Center(child: Text('未找到訂單信息。'));
    }

    // 獲取當前訂單狀態在預定義流程中的索引
    int currentStatusIndex = _allPossibleStatuses.indexOf(_order!.currentStatus);
    if (currentStatusIndex == -1 && _order!.currentStatus == OrderStatus.cancelled) {
      // 特殊處理已取消的訂單
      return _buildCancelledOrderView();
    } else if (currentStatusIndex == -1) {
      // 如果當前狀態不在預期流程中（例如，已退款），也可能需要特殊視圖
      return Center(child: Text("訂單狀態: ${orderStatusToDisplayString(_order!.currentStatus)}")); // MODIFIED HERE
    }


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderSummary(_order!),
          const SizedBox(height: 24),
          Text('訂單進度', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildStatusStepper(currentStatusIndex),
          const SizedBox(height: 24),
          Text('狀態歷史', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildStatusHistory(_order!.statusHistory),
          const SizedBox(height: 20),
          // --- 僅為演示添加的測試按鈕 ---
          if (_order!.currentStatus != OrderStatus.completed && _order!.currentStatus != OrderStatus.cancelled)
            ElevatedButton(
              onPressed: () {
                final currentActiveIndex = _allPossibleStatuses.indexOf(_order!.currentStatus);
                if (currentActiveIndex != -1 && currentActiveIndex < _allPossibleStatuses.length - 1) {
                  _updateOrderStatus(_order!, _allPossibleStatuses[currentActiveIndex + 1]);
                }
              },
              child: const Text("模擬更新到下一狀態"),
            ),
          if (_order!.currentStatus != OrderStatus.cancelled)
            TextButton(
              onPressed: () => _updateOrderStatus(_order!, OrderStatus.cancelled),
              child: const Text("模擬取消訂單", style: TextStyle(color: Colors.red)),
            )
          // --- 演示按鈕結束 ---
        ],
      ),
    );
  }

  Widget _buildCancelledOrderView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(getOrderStatusIcon(OrderStatus.cancelled), size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              orderStatusToDisplayString(OrderStatus.cancelled), // MODIFIED HERE
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text("訂單 ${_order!.orderId} 已被取消。", textAlign: TextAlign.center),
            // 可以添加更多關於取消原因或後續操作的提示
          ],
        ),
      ),
    );
  }


  Widget _buildOrderSummary(OrderModel order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('訂單號: ${order.orderId}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('商品: ${order.productName}'),
            const SizedBox(height: 8),
            Text('總金額: \$${order.totalPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('下單時間: ${order.orderDate.toLocal().toString().substring(0, 16)}'), // 簡化日期顯示
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('當前狀態: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Chip(
                  avatar: Icon(getOrderStatusIcon(order.currentStatus), size: 18, color: Colors.white),
                  label: Text(orderStatusToDisplayString(order.currentStatus), style: const TextStyle(color: Colors.white)), // MODIFIED HERE
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 創建步驟條的 Widget
  Widget _buildStatusStepper(int currentStatusIndex) {
    return Column(
      children: List.generate(_allPossibleStatuses.length, (index) {
        final status = _allPossibleStatuses[index];
        bool isActive = index == currentStatusIndex; // 當前活動狀態
        bool isCompleted = index < currentStatusIndex; // 已完成的狀態
        // bool isNext = index == currentStatusIndex + 1; // 下一個可能的狀態 (在原代碼中未使用此變量)

        // 查找此狀態在歷史記錄中的最新時間戳 (如果有的話)
        final historyEntry = _order!.statusHistory.lastWhere(
                (h) => h.status == status,
            // orElse: () => OrderStatusUpdate(status: status, timestamp: DateTime.now()) // 備用，如果找不到，可以考慮不顯示時間戳或給一個明確的null
            orElse: () => OrderStatusUpdate(status: status, timestamp: DateTime.now(), description: "狀態尚未到達") // 提供一個更明確的備用
        );


        return _buildStatusStep(
          status: status,
          icon: getOrderStatusIcon(status),
          title: orderStatusToDisplayString(status), // MODIFIED HERE
          timestamp: (isCompleted || isActive) && _order!.statusHistory.any((h) => h.status == status)
              ? historyEntry.timestamp
              : null, // 只有當狀態真的在歷史中才顯示時間
          description: isActive && _order!.statusHistory.any((h) => h.status == status)
              ? historyEntry.description
              : null, // 同上
          isFirst: index == 0,
          isLast: index == _allPossibleStatuses.length - 1,
          isActive: isActive,
          isCompleted: isCompleted,
          // isNextAfterActive: isNext, // isNext 未在 _buildStatusStep 中使用
        );
      }),
    );
  }

  Widget _buildStatusStep({
    required OrderStatus status,
    required IconData icon,
    required String title,
    DateTime? timestamp,
    String? description,
    required bool isFirst,
    required bool isLast,
    required bool isActive,
    required bool isCompleted,
    // required bool isNextAfterActive, // 未使用
  }) {
    Color activeColor = Theme.of(context).primaryColor;
    Color completedColor = Colors.green;
    Color inactiveColor = Colors.grey[400]!;

    Color circleColor = inactiveColor;
    // Color lineColor = inactiveColor; // line color logic is a bit more complex below
    Color iconColor = Colors.white; // 圖標在圓圈內，所以通常是白色
    TextStyle titleStyle = TextStyle(color: inactiveColor, fontSize: 16);
    TextStyle timeStyle = TextStyle(color: Colors.grey[600], fontSize: 12);

    if (isActive) {
      circleColor = activeColor;
      // lineColor = activeColor;
      titleStyle = TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 16);
    } else if (isCompleted) {
      circleColor = completedColor;
      // lineColor = completedColor;
      titleStyle = TextStyle(color: completedColor, fontSize: 16);
    }

    return IntrinsicHeight( // 確保 Row 中的元素可以正確對齊
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column( // 左側的圓點和線條
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 20, // 線條長度可以調整
                  // 上方線條的顏色應該基於上一個步驟是否完成
                  color: isCompleted || isActive ? (isCompleted ? completedColor : activeColor) : inactiveColor,

                ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  border: isActive ? Border.all(color: Colors.white, width: 2) : null, // 活動狀態加白邊
                  boxShadow: isActive ? [BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 5, spreadRadius: 1)] : null,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              if (!isLast)
                Expanded( // 確保線條填滿剩餘空間
                  child: Container(
                    width: 2,
                    // 下方線條的顏色應該是當前步驟的顏色 (如果已完成或活動)
                    color: isCompleted ? completedColor : (isActive ? activeColor : inactiveColor),

                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded( // 右側的文字內容
            child: Padding(
              padding: EdgeInsets.only(top: isFirst ? 6 : 24, bottom: isLast ? 0 : 20), // 調整頂部間距使文字與圓圈對齊更好
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: titleStyle),
                  if (timestamp != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        timestamp.toLocal().toString().substring(0, 16), // 簡化時間顯示
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
    // 按時間降序排列
    final sortedHistory = List<OrderStatusUpdate>.from(history)..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return ListView.builder(
      shrinkWrap: true, // 重要，在 SingleChildScrollView 內部
      physics: const NeverScrollableScrollPhysics(), // 在 SingleChildScrollView 內部，禁用滾動
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
                    Text(
                      orderStatusToDisplayString(entry.status), // MODIFIED HERE
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      entry.timestamp.toLocal().toString().substring(0, 16),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    if (entry.description != null && entry.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          entry.description!,
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
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