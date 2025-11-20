import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishpool_provider.dart';
import '../../providers/wishpool_invite_provider.dart';
import '../../providers/auth_provider.dart'; // 用於檢查登入狀態
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

    // 進入頁面時，同時載入「願望列表」、「收到的邀請」和「發出的邀請」
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contextRead = context.read;
      contextRead<WishPoolProvider>().loadWishPools();
      contextRead<WishPoolInviteProvider>().loadReceivedInvites();
      contextRead<WishPoolInviteProvider>().loadSentInvites();
    });
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
            isScrollable: true,
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

// ==================== 分頁 1: 我的願望 (保持不變) ====================
class _WishListTab extends StatelessWidget {
  const _WishListTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WishPoolProvider>();
    final authProvider = context.watch<AuthProvider>();

    final myWishes = provider.wishPools
        .where((w) => w.userId == authProvider.currentUser?.id && w.status == 'open')
        .toList();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (myWishes.isEmpty) {
      return const Center(
          child: Text('你還沒有發布任何進行中的願望', style: TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: provider.loadWishPools,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: myWishes.length,
        itemBuilder: (context, i) {
          final wish = myWishes[i];
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
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wish.description ?? '（無描述）',
                    style: const TextStyle(color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${wish.likeCount} 人收藏',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
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
                    _confirmDelete(context, wish.id);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('編輯')),
                  PopupMenuItem(value: 'delete', child: Text('刪除', style: TextStyle(color: Colors.red))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int wishId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('確認刪除'),
        content: const Text('確定要刪除這個願望嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('刪除', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<WishPoolProvider>().removeWishPool(wishId);
    }
  }
}

// ==================== 分頁 2: 收到邀請 (買家視角) ====================
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

    return RefreshIndicator(
      onRefresh: inviteProvider.loadReceivedInvites,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: invites.length,
        itemBuilder: (context, i) {
          return _InviteCard(invite: invites[i]);
        },
      ),
    );
  }
}

// ==================== 分頁 3: 發出邀請 (賣家視角) ====================

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

    return RefreshIndicator(
      onRefresh: inviteProvider.loadSentInvites,
      child: ListView.builder(
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
              // [UI 修改] 移除商品顯示，改為顯示願望標題或賣家訊息
              title: Text(
                '對願望：${invite.wishpool?.title ?? "#${invite.wishPoolId}"}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (invite.message != null && invite.message!.isNotEmpty)
                    Text('我的留言：${invite.message}', maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('狀態：${_statusText(invite.status)}',
                      style: TextStyle(color: _statusColor(invite.status), fontWeight: FontWeight.w500)
                  ),
                ],
              ),
              trailing: _buildStatusIcon(invite.status),
            ),
          );
        },
      ),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'accepted': return '已接受';
      case 'rejected': return '已拒絕';
      default: return '待回覆';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'accepted': return const Icon(Icons.check_circle, color: Colors.green);
      case 'rejected': return const Icon(Icons.cancel, color: Colors.red);
      default: return const Icon(Icons.hourglass_empty, color: Colors.orange);
    }
  }
}

// ==================== 分頁 4: 已完成 (保持不變) ====================
class _CompletedTab extends StatelessWidget {
  const _CompletedTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WishPoolProvider>();
    final authProvider = context.watch<AuthProvider>();

    // 篩選出我的且狀態為 matched 或 closed 的願望
    final completed = provider.wishPools
        .where((w) =>
    w.userId == authProvider.currentUser?.id &&
        (w.status == 'closed' || w.status == 'matched'))
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('狀態：${wish.status == 'matched' ? '已媒合' : '已關閉'}',
                    style: const TextStyle(color: Colors.black54)
                ),
                // 這裡也不再顯示 "匹配商品"，因為現在是純邀請
                const Text('邀請已接受，請透過聊天聯繫賣家',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)
                ),
              ],
            ),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
        );
      },
    );
  }
}

// ==================== 元件: 邀請卡片 (買家視角) ====================
class _InviteCard extends StatelessWidget {
  final WishPoolInvite invite;
  const _InviteCard({required this.invite});

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'accepted': return '已接受';
      case 'rejected': return '已拒絕';
      default: return '待回覆';
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
                // --- [UI 修正] 顯示賣家名稱而非商品 ---
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: invite.seller?.avatarUrl != null
                            ? NetworkImage(invite.seller!.avatarUrl!)
                            : null,
                        child: invite.seller?.avatarUrl == null
                            ? const Icon(Icons.person, size: 20)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        invite.seller?.username ?? '未知賣家',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8),
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
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // --- [UI 修正] 移除商品名稱和價格，只顯示留言 ---
            const Text(
              '賣家留言：',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              (invite.message != null && invite.message!.isNotEmpty)
                  ? invite.message!
                  : '（賣家未留訊息）',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
            ),

            // 操作按鈕 (僅在待處理狀態顯示)
            if (status == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        try {
                          await provider.rejectInvite(invite.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已拒絕邀請')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('操作失敗: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('拒絕'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await provider.acceptInvite(invite.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已接受邀請！請聯絡賣家進行交易。'), backgroundColor: Colors.green),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('操作失敗: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004E98),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('接受並聯繫'),
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