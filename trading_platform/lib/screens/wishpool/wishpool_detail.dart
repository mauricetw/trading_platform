import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/wishpool/wishpool.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';
import 'fulfill_dialog.dart';
import '../chatlist/chatroom.dart';

class WishPoolDetail extends StatefulWidget {
  final WishPool wish;
  const WishPoolDetail({super.key, required this.wish});

  @override
  State<WishPoolDetail> createState() => _WishPoolDetailState();
}

class _WishPoolDetailState extends State<WishPoolDetail> {
  bool _isMyWish = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    // 判斷是否為自己的願望
    if (authProvider.isLoggedIn && authProvider.currentUser?.id == widget.wish.userId) {
      _isMyWish = true;
    }
  }

  // --- [功能] 開啟聊天 ---
  Future<void> _startChat(BuildContext context) async {
    try {
      final chatProvider = context.read<ChatProvider>();
      // 顯示 Loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // 建立或獲取通用聊天室
      final roomId = await chatProvider.startGeneralChat(widget.wish.userId);

      if (context.mounted) {
        Navigator.pop(context); // 關閉 Loading
        // 跳轉到聊天室
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              chatRoomId: roomId,
              otherUserId: widget.wish.userId,
              otherUserName: widget.wish.user?.username ?? '未知',
              otherUserAvatarUrl: widget.wish.user?.avatarUrl,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // 關閉 Loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('開啟聊天失敗: $e')));
      }
    }
  }

  // --- [功能] 顯示接單對話框 ---
  void _showFulfillDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => FulfillDialog(
        wishPoolId: widget.wish.id,
        wishTitle: widget.wish.title,
        wishPrice: widget.wish.price,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    // 只要有登入且不是自己的願望，就視為潛在賣家
    final isSeller = currentUser != null && !_isMyWish;

    return Scaffold(
      appBar: AppBar(
        title: const Text('願望詳情'),
        centerTitle: true,
        backgroundColor: const Color(0xFF004E98),
        foregroundColor: Colors.white,
        shape: const FullBottomConcaveAppBarShape(curveHeight: 25.0),
      ),
      body: Column(
        children: [
          // 上半部：願望資訊
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfoHeader(),
                  const SizedBox(height: 16),
                  _buildWishContent(),
                ],
              ),
            ),
          ),

          // 下半部：操作按鈕 (僅對非擁有者的賣家顯示，且願望必須是開放狀態)
          if (isSeller && widget.wish.status == 'open')
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
              ),
              child: Row(
                children: [
                  // 1. 聊聊按鈕
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('聊聊/議價'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      onPressed: () => _startChat(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 2. 接單按鈕
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('立即接單'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _showFulfillDialog(context),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfoHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: widget.wish.user?.avatarUrl != null
              ? NetworkImage(widget.wish.user!.avatarUrl!)
              : null,
          child: widget.wish.user?.avatarUrl == null ? const Icon(Icons.person) : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.wish.user?.username ?? '未知使用者',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('yyyy-MM-dd').format(widget.wish.createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const Spacer(),
        if (widget.wish.status == 'matched')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
            child: const Text('已媒合', style: TextStyle(color: Colors.white, fontSize: 12)),
          )
        else if (widget.wish.status == 'closed')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(12)),
            child: const Text('已關閉', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildWishContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.wish.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '期望價格: \$${widget.wish.price}',
              style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('數量: ${widget.wish.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.wish.description ?? '無詳細描述',
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 12),
        if (widget.wish.tags != null && widget.wish.tags!.isNotEmpty)
          Wrap(
            spacing: 8,
            children: widget.wish.tags!.map((tag) => Chip(
              label: Text(tag),
              backgroundColor: Colors.grey[200],
            )).toList(),
          ),
      ],
    );
  }
}