import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishpool_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/wishpool/wishpool.dart';
import 'wishpool_create.dart';
import 'wishpool_edit.dart';
import 'wishpool_detail.dart'; // [新增] 用於點擊跳轉
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
    // [修改] 只要 2 個分頁：我的願望、已完成
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishPoolProvider>().loadWishPools();
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
            tabs: const [
              Tab(text: '我的願望'),
              Tab(text: '已完成'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _WishListTab(),
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

// ==================== 分頁 1: 我的願望 ====================
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
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => WishPoolDetail(wish: wish)));
              },
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
                  Row(
                    children: [
                      Text('${wish.likeCount} 人收藏', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(width: 12),
                      Text('\$${wish.price}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
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


// ==================== 分頁 2: 已完成 ====================
class _CompletedTab extends StatelessWidget {
  const _CompletedTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WishPoolProvider>();
    final authProvider = context.watch<AuthProvider>();

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
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => WishPoolDetail(wish: wish)));
            },
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
                if (wish.matchedItem != null)
                  Text('匹配商品：${wish.matchedItem!.name}',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)
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