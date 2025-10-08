// --- FILE: lib/screens/chatlist/chatroom.dart ---
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chat/message.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart'; // 1. 引入 AuthProvider

class ChatRoomScreen extends StatefulWidget {
  final int chatRoomId;
  final int otherUserId;
  final String otherUserName;
  final String? otherUserAvatarUrl;

  const ChatRoomScreen({
    super.key,
    required this.chatRoomId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatarUrl,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 2. 進入頁面時，呼叫 Provider 載入歷史訊息並連接 WebSocket
      context.read<ChatProvider>().enterChatRoom(widget.chatRoomId);
    });
  }

  @override
  void dispose() {
    // 3. 離開頁面時，呼叫 Provider 斷開連線
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChatProvider>().leaveChatRoom();
      }
    });
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // 4. 發送訊息的任務完全交給 Provider
    context.read<ChatProvider>().sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom({bool isInitialLoad = false}) {
    if (_scrollController.hasClients) {
      // 延遲一點執行，確保 ListView builder 完成佈局
      Future.delayed(Duration(milliseconds: isInitialLoad ? 300 : 100), () {
        if (_scrollController.hasClients) { // 再次檢查，因為 Future 可能在 dispose 後執行
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 5. 使用 Consumer 來獲取並監聽 ChatProvider 的狀態
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        final messages = provider.activeRoomMessages;
        // 6. 從 AuthProvider 獲取當前使用者 ID
        final currentUserId = context.read<AuthProvider>().currentUser?.id;

        // 7. 監聽訊息列表的變化，並在有新訊息時自動滾動到底部
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollToBottom();
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                if (widget.otherUserAvatarUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(backgroundImage: NetworkImage(widget.otherUserAvatarUrl!), radius: 18),
                  ),
                Expanded(child: Text(widget.otherUserName, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: (provider.isLoadingMessages && messages.isEmpty)
                    ? const Center(child: CircularProgressIndicator())
                    : (messages.isEmpty)
                    ? Center(child: Text('開始對話吧！', style: TextStyle(color: Colors.grey[600])))
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    // 8. 傳遞 currentUserId 給 UI builder
                    return _buildMessageItem(message, currentUserId);
                  },
                ),
              ),
              _buildMessageInputArea(),
            ],
          ),
        );
      },
    );
  }

  // 9. UI Builder 現在接收 currentUserId 來判斷訊息方向
  Widget _buildMessageItem(Message message, int? currentUserId) {
    final bool isMe = message.senderId == currentUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor.withOpacity(0.9) : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message.text ?? '',
          style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildMessageInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: '輸入訊息...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Colors.grey[800],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                ),
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}