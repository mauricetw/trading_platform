import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishpool_provider.dart';
import '../../providers/wishpool_invite_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/wishpool/wishpool.dart';
import '../../models/product/product.dart';
import 'wishpool_create.dart';
import 'wishpool_manage.dart';
import 'wishpool_detail.dart';
import 'invite_dialog.dart';
import '../../widgets/FullBottomConcaveAppBarShape.dart';

class WishPoolMain extends StatefulWidget {
  const WishPoolMain({super.key});

  @override
  State<WishPoolMain> createState() => _WishPoolMainState();
}

class _WishPoolMainState extends State<WishPoolMain> {
  bool showMyManage = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<WishPoolProvider>().loadWishPools());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WishPoolProvider>();
    final wishPools = provider.wishPools;

    if (showMyManage) {
      return const WishPoolManage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('許願池'),
        centerTitle: true,
        backgroundColor: const Color(0xFF004E98),
        shape: const FullBottomConcaveAppBarShape(curveHeight: 25.0),
        elevation: 6.0,
        foregroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.3),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts_outlined),
            tooltip: '我的願望管理',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishPoolManage()),
              );
            },
          ),
        ],
      ),
      body: provider.isLoading && wishPools.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: provider.loadWishPools,
        child: wishPools.isEmpty
            ? const Center(child: Text("目前沒有許願單，快來許願吧！"))
            : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          itemCount: wishPools.length,
          itemBuilder: (context, i) {
            final wish = wishPools[i];
            return _WishCard(wish: wish);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final authProvider = context.read<AuthProvider>();
          if (!authProvider.isLoggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('請先登入才能許願'), backgroundColor: Colors.red),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WishPoolCreate()),
          );
        },
        tooltip: '新增願望',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _WishCard extends StatelessWidget {
  final WishPool wish;
  const _WishCard({required this.wish});

  Future<void> _showInviteDialog(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先登入才能發送邀請'), backgroundColor: Colors.red),
      );
      return;
    }

    if (wish.userId == authProvider.currentUser?.id) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('這是你的願望'),
          content: const Text('你不能向自己的願望發送邀請。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('知道了'),
            ),
          ],
        ),
      );
      return;
    }

    // --- [修正] 移除所有商品檢查邏輯，直接顯示對話框 ---
    showDialog(
      context: context,
      builder: (_) => InviteDialog(
        wishPoolId: wish.id,
        wishTitle: wish.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WishPoolDetail(wish: wish),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundImage: wish.user?.avatarUrl != null && wish.user!.avatarUrl!.isNotEmpty
              ? NetworkImage(wish.user!.avatarUrl!)
              : null,
          child: (wish.user?.avatarUrl == null || wish.user!.avatarUrl!.isEmpty)
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(wish.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(wish.description ?? '（無描述）', maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.favorite, size: 14, color: Colors.red[300]),
                const SizedBox(width: 4),
                Text('${wish.likeCount} 人想要', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 16),
                if (wish.priceMin != null || wish.priceMax != null)
                  Text(
                    '\$${wish.priceMin ?? 0} ~ \$${wish.priceMax ?? '不限'}',
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'like') {
              final auth = context.read<AuthProvider>();
              if (!auth.isLoggedIn) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('請先登入')));
                return;
              }
              context.read<WishPoolProvider>().favoriteWish(wish.id);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已加入收藏！'), duration: Duration(seconds: 1)),
              );
            } else if (value == 'invite') {
              _showInviteDialog(context);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'like', child: Text('我也想要')),
            PopupMenuItem(value: 'invite', child: Text('發送邀請')),
          ],
        ),
      ),
    );
  }
}