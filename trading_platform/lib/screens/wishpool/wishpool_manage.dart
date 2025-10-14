import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishpool_provider.dart';
import '../../providers/wishpool_invite_provider.dart';
import '../../models/wishpool/wishpool.dart';
import '../../models/wishpool/wishpool_invite.dart';
import 'wishpool_create.dart';
import 'wishpool_edit.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';

class WishPoolManage extends StatefulWidget {
  const WishPoolManage({super.key});

  @override
  State<WishPoolManage> createState() => _WishPoolManageState();
}

class _WishPoolManageState extends State<WishPoolManage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() => context.read<WishPoolProvider>().loadWishPools());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Colors.grey.shade100;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('願望管理', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF004E98),
        shape: const FullBottomConcaveAppBarShape(curveHeight: 25.0),
        elevation: 6.0,
        shadowColor: Colors.black.withOpacity(0.25),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.orangeAccent,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
            tabs: const [
              Tab(text: '我的願望'),
              Tab(text: '收到邀請'),
              Tab(text: '發出邀請'),
              Tab(text: '已完成'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _WishListTab(),
          _InviteTab(),
          _SentInviteTab(),
          _CompletedTab(),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          return _tabController.index == 0
              ? FloatingActionButton.extended(
            backgroundColor: const Color(0xFF004E98),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('新增願望', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WishPoolCreate(),
                ),
              );
            },
          )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}

// ==================== 分頁 ====================

class _WishListTab extends StatelessWidget {
  const _WishListTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WishPoolProvider>();
    final wishPools = provider.wishPools;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (wishPools.isEmpty) {
      return const Center(
          child: Text('你還沒有發布任何願望', style: TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: provider.loadWishPools,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: wishPools.length,
        itemBuilder: (context, i) {
          final wish = wishPools[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              title: Text(
                wish.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                wish.description ?? '（無描述）',
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WishPoolEdit(wish: wish),
                      ),
                    );
                  } else if (value == 'delete') {
                    context.read<WishPoolProvider>().removeWishPool(wish.id);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('編輯')),
                  PopupMenuItem(value: 'delete', child: Text('刪除')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InviteTab extends StatelessWidget {
  const _InviteTab();

  @override
  Widget build(BuildContext context) {
    final inviteProvider = context.watch<WishPoolInviteProvider>();
    final invites = inviteProvider.receivedInvites;
    final isLoading = inviteProvider.isLoading;

    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (invites.isEmpty) {
      return const Center(
          child: Text('目前沒有收到任何邀請', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: invites.length,
      itemBuilder: (context, i) {
        return _InviteCard(invite: invites[i]);
      },
    );
  }
}

class _SentInviteTab extends StatelessWidget {
  const _SentInviteTab();

  @override
  Widget build(BuildContext context) {
    final inviteProvider = context.watch<WishPoolInviteProvider>();
    final invites = inviteProvider.sentInvites;
    final isLoading = inviteProvider.isLoading;

    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (invites.isEmpty) {
      return const Center(
          child: Text('目前沒有發出的邀請', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: invites.length,
      itemBuilder: (context, i) {
        final invite = invites[i];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            title: Text(invite.product?.name ?? '未知商品'),
            subtitle: Text('對願望 #${invite.wishPoolId}\n狀態：${invite.status}'),
            trailing: Text(
              invite.status == 'pending'
                  ? '待回覆'
                  : invite.status == 'accepted'
                  ? '✔ 已接受'
                  : '✖ 已拒絕',
              style: TextStyle(
                color: invite.status == 'accepted'
                    ? Colors.green
                    : (invite.status == 'rejected'
                    ? Colors.red
                    : Colors.orange),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CompletedTab extends StatelessWidget {
  const _CompletedTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WishPoolProvider>();
    final completed = provider.wishPools
        .where((w) => w.status == 'closed' || w.status == 'matched')
        .toList();

    if (completed.isEmpty) {
      return const Center(
          child: Text('目前沒有已完成的願望', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: completed.length,
      itemBuilder: (context, i) {
        final wish = completed[i];
        return Card(
          color: Colors.green.shade50,
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            title: Text(
              wish.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('狀態：${wish.status}', style: const TextStyle(color: Colors.black54)),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
        );
      },
    );
  }
}

class _InviteCard extends StatelessWidget {
  final WishPoolInvite invite;
  const _InviteCard({required this.invite});

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'accepted':
        return '已接受';
      case 'rejected':
        return '已拒絕';
      default:
        return '待回覆';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WishPoolInviteProvider>();
    final status = invite.status;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題列
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invite.product?.name ?? '未知商品',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusText(status),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: invite.seller?.avatarUrl != null
                      ? NetworkImage(invite.seller!.avatarUrl!)
                      : null,
                  child: invite.seller?.avatarUrl == null
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(invite.seller?.username ?? '未知賣家'),
              ],
            ),
            if (invite.message?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('留言：${invite.message}',
                    style: TextStyle(color: Colors.grey.shade700)),
              ),
            if (status == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await provider.respondToInvite(invite.id, 'rejected');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已拒絕邀請')),
                          );
                        }
                      },
                      child: const Text('拒絕'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await provider.respondToInvite(invite.id, 'accepted');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已接受邀請')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004E98),
                      ),
                      child: const Text('接受'),
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
