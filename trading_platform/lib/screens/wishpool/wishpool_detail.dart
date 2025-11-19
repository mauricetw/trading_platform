import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/wishpool/wishpool.dart';
import '../../models/wishpool/wishpool_invite.dart';
import '../../providers/wishpool_invite_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';
import 'invite_dialog.dart';

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
    if (authProvider.isLoggedIn && authProvider.currentUser?.id == widget.wish.userId) {
      _isMyWish = true;
      Future.microtask(() =>
          context.read<WishPoolInviteProvider>().loadReceivedInvites()
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inviteProvider = context.watch<WishPoolInviteProvider>();
    final currentUser = context.watch<AuthProvider>().currentUser;
    final isSeller = currentUser != null;

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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfoHeader(),
                  const SizedBox(height: 16),
                  _buildWishContent(),
                  const Divider(height: 32),

                  if (_isMyWish) ...[
                    Text('收到的報價 (${_getMyInvites(inviteProvider).length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 8),
                    _buildReceivedInvitesList(inviteProvider),
                  ],
                ],
              ),
            ),
          ),

          if (!_isMyWish && isSeller)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
              ),
              child: _buildSellerActionButton(context),
            ),
        ],
      ),
    );
  }

  List<WishPoolInvite> _getMyInvites(WishPoolInviteProvider provider) {
    return provider.receivedInvites.where((i) => i.wishPoolId == widget.wish.id).toList();
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
        if (widget.wish.priceMin != null || widget.wish.priceMax != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '預算: \$${widget.wish.priceMin ?? 0} ~ \$${widget.wish.priceMax ?? '不限'}',
              style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w500),
            ),
          ),
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

  Widget _buildReceivedInvitesList(WishPoolInviteProvider provider) {
    final invites = _getMyInvites(provider);

    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (invites.isEmpty) return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: Text('目前還沒有人提供報價喔！')),
    );

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: invites.length,
      itemBuilder: (context, index) {
        final invite = invites[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('賣家: ${invite.seller?.username ?? "未知"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    _buildInviteStatusBadge(invite.status),
                  ],
                ),
                const Divider(),
                // --- [修正] 商品資訊區塊：如果 product 為 null，則隱藏或顯示特定文字 ---
                if (invite.product != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 50, height: 50,
                      color: Colors.grey[200],
                      child: invite.product!.imageUrls.isNotEmpty
                          ? Image.network(invite.product!.imageUrls.first, fit: BoxFit.cover)
                          : const Icon(Icons.image),
                    ),
                    title: Text(invite.product!.name),
                    subtitle: Text('\$${invite.product!.price.toInt()}'),
                  )
                else
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('賣家僅傳送訊息', style: TextStyle(color: Colors.grey)),
                  ),
                // -----------------------------------------------------------

                if (invite.message != null && invite.message!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('留言: ${invite.message}', style: TextStyle(color: Colors.grey[700])),
                  ),
                const SizedBox(height: 12),
                if (invite.status == 'pending')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _handleRejectInvite(provider, invite.id),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('拒絕'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _handleAcceptInvite(provider, invite.id),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        child: const Text('接受報價'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInviteStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'accepted': color = Colors.green; text = "已接受"; break;
      case 'rejected': color = Colors.red; text = "已拒絕"; break;
      default: color = Colors.orange; text = "待處理";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSellerActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.message), // Icon 改為訊息
        label: const Text('發送訊息 / 邀請'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        onPressed: () => _showSellerInviteDialog(context),
      ),
    );
  }

  // --- [修正] 直接顯示對話框，無需讀取商品 ---
  void _showSellerInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => InviteDialog(
        wishPoolId: widget.wish.id,
        wishTitle: widget.wish.title,
      ),
    );
  }

  Future<void> _handleAcceptInvite(WishPoolInviteProvider provider, int inviteId) async {
    try {
      await provider.acceptInvite(inviteId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已接受報價！訂單已成立。'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失敗: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _handleRejectInvite(WishPoolInviteProvider provider, int inviteId) async {
    try {
      await provider.rejectInvite(inviteId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已拒絕報價')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失敗: $e'), backgroundColor: Colors.red));
    }
  }
}