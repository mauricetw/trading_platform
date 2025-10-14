import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/wishpool/wishpool.dart';
import '../../models/user/user.dart';
import '../../providers/wishpool_invite_provider.dart';
import '../../providers/auth_provider.dart'; // ← 你若有 auth provider

class WishPoolDetail extends StatelessWidget {
  final WishPool wish;
  const WishPoolDetail({super.key, required this.wish});

  @override
  Widget build(BuildContext context) {
    final inviteProvider = context.watch<WishPoolInviteProvider>();
    final isLoading = inviteProvider.isLoading;

    // 假設從 AuthProvider 取得目前使用者
    final currentUser = context.read<AuthProvider>().currentUser as User;

    final isMyWish = wish.userId == currentUser.id;
    final isSeller = currentUser.isSeller;

    return Scaffold(
      appBar: AppBar(title: const Text('願望詳情')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 標題與描述 ---
            Text(
              wish.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(wish.description ?? '（無描述內容）'),

            const SizedBox(height: 12),

            // --- 類別與標籤 ---
            if (wish.tags != null && wish.tags!.isNotEmpty)
              Wrap(
                spacing: 6,
                children: wish.tags!
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),

            const SizedBox(height: 20),

            // --- 發布者資訊 ---
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: wish.user?.avatarUrl != null
                      ? NetworkImage(wish.user!.avatarUrl!)
                      : null,
                  child: wish.user?.avatarUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(wish.user?.username ?? '未知使用者'),
              ],
            ),

            const Spacer(),

            // --- 操作按鈕 ---
            _buildBottomButtons(
              context: context,
              isLoading: isLoading,
              isMyWish: isMyWish,
              isSeller: isSeller,
              wish: wish,
              currentUser: currentUser,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons({
    required BuildContext context,
    required bool isLoading,
    required bool isMyWish,
    required bool isSeller,
    required WishPool wish,
    required User currentUser,
  }) {
    if (isMyWish) {
      return const SizedBox(); // 自己的願望不顯示按鈕
    }

    if (!isSeller) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        child: const Text(
          '此為他人願望，您目前為買家身分',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.send),
        label: isLoading
            ? const Text('發送中...')
            : const Text('發送邀請'),
        onPressed: isLoading
            ? null
            : () async {
          final inviteProvider =
          context.read<WishPoolInviteProvider>();

          try {
            await inviteProvider.sendInvite(
              wishPoolId: wish.id,
              sellerId: currentUser.id,
              productId: wish.matchedItemId ?? 0, // 可選
              message: '我這邊有符合你需求的商品喔！',
            );

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('邀請已成功發送！')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('發送失敗：$e')),
              );
            }
          }
        },
      ),
    );
  }
}
