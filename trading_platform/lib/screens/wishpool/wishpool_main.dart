import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishpool_provider.dart';
import '../../models/wishpool/wishpool.dart';
import '../../models/product/product.dart';
import 'wishpool_create.dart';
import 'wishpool_manage.dart';

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
        title: const Text(''),
        centerTitle: true,
        backgroundColor: const Color(0xFF004E98),
        shape: const FullBottomConcaveAppBarShape(curveHeight: 25.0),
        elevation: 6.0,
        shadowColor: Colors.black.withValues(alpha: 0.3),
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
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: provider.loadWishPools,
        child: ListView.builder(
          padding:
          const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          itemCount: wishPools.length,
          itemBuilder: (context, i) {
            final wish = wishPools[i];
            return _WishCard(wish: wish);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
    final productProvider = context.read<ProductProvider>();
    await productProvider.fetchSellerProducts(); // 抓取賣家商品
    final myProducts = productProvider.sellerProducts;

    if (myProducts.isEmpty) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('尚未上架任何商品'),
          content: const Text('要發送邀請前，請先在商品頁上架商品。'),
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

    Product? selectedProduct;
    final TextEditingController msgCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('對「${wish.title}」發出邀請'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Product>(
                    value: selectedProduct,
                    decoration: const InputDecoration(labelText: '選擇商品'),
                    items: myProducts
                        .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text('${p.name}（\$${p.price.toInt()}）'),
                    ))
                        .toList(),
                    onChanged: (p) => setState(() => selectedProduct = p),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: msgCtrl,
                    decoration: const InputDecoration(
                      labelText: '留言（選填）',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: selectedProduct == null
                  ? null
                  : () async {
                final sellerId = 1; // TODO: 改為實際登入使用者 ID
                await context.read<WishPoolProvider>().sendInvite(
                  wishPoolId: wish.id,
                  sellerId: sellerId,
                  productId: selectedProduct!.id,
                  message: msgCtrl.text,
                );

                if (context.mounted) {
                  Navigator.pop(ctx); // 關閉對話框

                  // ✅ 成功彈窗（點任意地方關閉）
                  await showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        color: Colors.black54,
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.check_circle,
                                  color: Colors.green, size: 60),
                              SizedBox(height: 12),
                              Text(
                                '邀請已成功送出！',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '點擊任意地方關閉',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
              child: const Text('送出邀請'),
            ),
          ],
        );
      },
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
          // ✅ 點擊卡片 → 進入詳情頁（你已經有的）
          Navigator.pushNamed(context, '/wishpool/detail', arguments: wish);
        },
        leading: CircleAvatar(
          backgroundImage: wish.user?.avatarUrl != null
              ? NetworkImage(wish.user!.avatarUrl!)
              : null,
          child: wish.user?.avatarUrl == null
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(wish.title),
        subtitle: Text(wish.description ?? '（無描述）'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'like') {
              final userId = 1; // TODO: 改成實際使用者ID
              context.read<WishPoolProvider>().toggleFavorite(wish.id, userId);
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
