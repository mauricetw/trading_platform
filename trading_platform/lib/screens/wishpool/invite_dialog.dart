import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishpool_invite_provider.dart';

class InviteDialog extends StatefulWidget {
  final int wishPoolId;
  final String wishTitle;

  const InviteDialog({
    super.key,
    required this.wishPoolId,
    required this.wishTitle,
  });

  @override
  State<InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<InviteDialog> {
  final TextEditingController _msgCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('對「${widget.wishTitle}」發送訊息'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '您可以直接聯絡買家，不需要選擇商品。',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _msgCtrl,
              decoration: const InputDecoration(
                labelText: '留言訊息',
                border: OutlineInputBorder(),
                hintText: '你好，我有你需要的東西...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          // 只有正在發送時停用按鈕
          onPressed: _isSending
              ? null
              : () async {
            if (_msgCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('請輸入留言內容')),
              );
              return;
            }

            setState(() => _isSending = true);
            try {
              // 直接傳送訊息，productId 為 null
              await context.read<WishPoolInviteProvider>().sendInvite(
                wishPoolId: widget.wishPoolId,
                message: _msgCtrl.text,
                productId: null,
              );

              if (mounted) {
                Navigator.pop(context); // 關閉對話框
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('訊息已送出！'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                setState(() => _isSending = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('發送失敗: $e'), backgroundColor: Colors.red),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF004E98),
            foregroundColor: Colors.white,
          ),
          child: _isSending
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('送出'),
        ),
      ],
    );
  }
}