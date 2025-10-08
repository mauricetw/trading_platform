// --- FILE: lib/screens/chatlist/chat_list.dart ---
import 'package:first_flutter_project/widgets/FullBottomConcaveAppBarShape.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // 用於日期格式化

import 'chatroom.dart';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart'; // 1. 引入 ChatProvider
import '../../models/chat/chat_room.dart'; // 2. 引入真實的 ChatRoom 模型

enum ChatType { buyer, seller }

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final PageController _pageController = PageController();
  Set<ChatType> _selectedSegment = {ChatType.buyer};

  @override
  void initState() {
    super.initState();
    // 確保 build 完成後再獲取資料
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshChats();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshChats() async {
    try {
      await context.read<ChatProvider>().fetchChatLists();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('無法刷新聊天列表: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('訊息'),
        shape: const FullBottomConcaveAppBarShape(curveHeight: 20.0),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        elevation: 8.0,
        centerTitle: true,
      ),
      body: Consumer<ChatProvider>( // 3. 使用 Consumer 監聽 ChatProvider
        builder: (context, provider, child) {
          return Column(
            children: <Widget>[
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedSegment = {ChatType.values[index]};
                    });
                  },
                  children: [
                    _buildChatList(context, provider.buyerChats, provider.isLoadingLists, provider.listError),
                    _buildChatList(context, provider.sellerChats, provider.isLoadingLists, provider.listError),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SegmentedButton<ChatType>(
                  segments: const <ButtonSegment<ChatType>>[
                    ButtonSegment<ChatType>(value: ChatType.buyer, label: Text('與賣家'), icon: Icon(Icons.storefront_outlined)),
                    ButtonSegment<ChatType>(value: ChatType.seller, label: Text('與買家'), icon: Icon(Icons.person_outline)),
                  ],
                  selected: _selectedSegment,
                  onSelectionChanged: (Set<ChatType> newSelection) {
                    if (newSelection.isNotEmpty) {
                      setState(() {
                        _selectedSegment = newSelection;
                        _pageController.jumpToPage(newSelection.first == ChatType.buyer ? 0 : 1);
                      });
                    }
                  },
                  style: SegmentedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
                    foregroundColor: colorScheme.primary,
                    selectedForegroundColor: colorScheme.onPrimary,
                    selectedBackgroundColor: colorScheme.secondary,
                  ),
                  showSelectedIcon: false,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatList(BuildContext context, List<ChatRoom> chats, bool isLoading, String? error) {
    if (isLoading && chats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && chats.isEmpty) {
      return Center(child: Text(error, style: const TextStyle(color: Colors.red)));
    }
    if (chats.isEmpty) {
      return Center(
        child: Text(
          _selectedSegment.first == ChatType.buyer ? '目前沒有與賣家的聊天' : '目前沒有與買家的聊天',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refreshChats,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return _buildChatTile(context, chat);
        },
      ),
    );
  }

  // UI Builder，現在接收真實的 ChatRoom 物件
  Widget _buildChatTile(BuildContext context, ChatRoom chat) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (chat.otherParty.avatarUrl != null && chat.otherParty.avatarUrl!.isNotEmpty)
            ? NetworkImage(chat.otherParty.avatarUrl!)
            : null,
        child: (chat.otherParty.avatarUrl == null || chat.otherParty.avatarUrl!.isEmpty)
            ? Text(chat.otherParty.name.isNotEmpty ? chat.otherParty.name[0].toUpperCase() : '?')
            : null,
      ),
      title: Text(chat.otherParty.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(chat.lastMessage?.text ?? '...', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.lastMessage != null ? DateFormat('HH:mm').format(chat.lastMessage!.timestamp.toLocal()) : '',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              chatRoomId: chat.id,
              otherUserId: chat.otherParty.id,
              otherUserName: chat.otherParty.name,
              otherUserAvatarUrl: chat.otherParty.avatarUrl,
            ),
          ),
        );
      },
    );
  }
}