import 'package:first_flutter_project/widgets/FullBottomConcaveAppBarShape.dart';
import 'package:flutter/material.dart';
// import 'dart:math' as math; // 不再需要
import 'chatroom.dart'; // 確保 ChatRoomScreen 已定義
import '../../theme/app_theme.dart';

// 定義 SegmentedButton 的選項
enum ChatType { buyer, seller }

class ChatRoomSummary {
  final String id;
  final String otherPartyName;
  final String? otherPartyAvatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? otherPartyId;

  ChatRoomSummary({
    required this.id,
    required this.otherPartyName,
    this.otherPartyAvatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.otherPartyId,
  });
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> { // 不再需要 SingleTickerProviderStateMixin
  // 使用 PageController 來控制 PageView
  final PageController _pageController = PageController();
  // 當前選中的 SegmentedButton 的值
  Set<ChatType> _selectedSegment = {ChatType.buyer}; // 默認選中買家

  List<ChatRoomSummary> _buyerChats = [];
  List<ChatRoomSummary> _sellerChats = [];
  bool _isLoadingBuyerChats = true;
  bool _isLoadingSellerChats = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeScreenData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreenData() async {
    // 模擬獲取用戶ID
    await Future.delayed(const Duration(milliseconds: 50));
    if (mounted) {
      setState(() {
        _currentUserId = "user_self_id_chatlist_example";
      });
      if (_currentUserId == null) {
        setState(() {
          _isLoadingBuyerChats = false;
          _isLoadingSellerChats = false;
        });
        return;
      }
      _loadBuyerChats();
      _loadSellerChats();
    }
  }

  Future<void> _loadBuyerChats() async {
    if (!mounted) return;
    setState(() => _isLoadingBuyerChats = true);
    await Future.delayed(const Duration(seconds: 1)); // 模擬網絡請求
    if (!mounted) return;
    setState(() {
      _buyerChats = [
        ChatRoomSummary(id: 'chatroom_b1_with_sellerA', otherPartyName: '熱心賣家A', otherPartyId: 'sellerA_id', lastMessage: '好的，明天發貨！', lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)), unreadCount: 0),
        ChatRoomSummary(id: 'chatroom_b2_with_sellerB', otherPartyName: '專業賣家B', otherPartyId: 'sellerB_id', lastMessage: '請問這個還有貨嗎？', lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)), unreadCount: 2, otherPartyAvatarUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?Text=B'),
      ];
      _isLoadingBuyerChats = false;
    });
  }

  Future<void> _loadSellerChats() async {
    if (!mounted) return;
    setState(() => _isLoadingSellerChats = true);
    await Future.delayed(const Duration(seconds: 1)); // 模擬網絡請求
    if (!mounted) return;
    setState(() {
      _sellerChats = [
        ChatRoomSummary(id: 'chatroom_s1_with_buyerMing', otherPartyName: '買家小明', otherPartyId: 'buyerMing_id', lastMessage: '我已經下單了，謝謝。', lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)), unreadCount: 1, otherPartyAvatarUrl: 'https://via.placeholder.com/150/00FF00/FFFFFF?Text=M'),
      ];
      _isLoadingSellerChats = false;
    });
  }

  void _navigateToChatRoom(BuildContext context, ChatRoomSummary chatSummary) {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('錯誤：無法獲取當前用戶資訊。請重試。')),
      );
      return;
    }
    if (chatSummary.otherPartyId == null || chatSummary.otherPartyId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('錯誤：無法確定聊天對象的ID。')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(
          chatRoomId: chatSummary.id,
          otherUserName: chatSummary.otherPartyName,
          otherUserAvatarUrl: chatSummary.otherPartyAvatarUrl,
          otherUserId: chatSummary.otherPartyId!,
          currentUserId: _currentUserId!,
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context, List<ChatRoomSummary> chats, bool isLoading) {
    if (_currentUserId == null && !isLoading) {
      return const Center(child: Text('無法加載聊天列表。\n請檢查用戶登錄狀態。', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)));
    }
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // 簡化 padding
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: chat.otherPartyAvatarUrl != null && chat.otherPartyAvatarUrl!.isNotEmpty
                ? NetworkImage(chat.otherPartyAvatarUrl!)
                : null,
            child: (chat.otherPartyAvatarUrl == null || chat.otherPartyAvatarUrl!.isEmpty)
                ? Text(chat.otherPartyName.isNotEmpty ? chat.otherPartyName[0].toUpperCase() : '?')
                : null,
          ),
          title: Text(chat.otherPartyName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(chat.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${chat.lastMessageTime.hour.toString().padLeft(2, '0')}:${chat.lastMessageTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (chat.unreadCount > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: lightColorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    chat.unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ] else ...[
                // 保持高度一致性，如果不需要未讀計數器的佔位符，可以移除這個SizedBox
                const SizedBox(height: 4 + 2 + 10 + 2), // 確保高度一致 (大致計算)
              ]
            ],
          ),
          onTap: () => _navigateToChatRoom(context, chat),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        shape: FullBottomConcaveAppBarShape(curveHeight: 20.0),
        backgroundColor: colorScheme.secondary,
        elevation: 8.0,
        shadowColor: Colors.black,
      ),
      body: Column(
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
                _buildChatList(context, _buyerChats, _isLoadingBuyerChats), // 對應 ChatType.buyer
                _buildChatList(context, _sellerChats, _isLoadingSellerChats), // 對應 ChatType.seller
              ],
            ),
          ),
          // SegmentedButton 放在 Column 的底部
          Padding(
            padding: const EdgeInsets.all(16.0), // 給 SegmentedButton 一些邊距
            child: SegmentedButton<ChatType>(
              segments: const <ButtonSegment<ChatType>>[
                ButtonSegment<ChatType>(
                  value: ChatType.buyer,
                  label: Text('與賣家'), // 或 "買家視角"
                  icon: Icon(Icons.storefront_outlined),
                ),
                ButtonSegment<ChatType>(
                  value: ChatType.seller,
                  label: Text('與買家'), // 或 "賣家視角"
                  icon: Icon(Icons.person_outline),
                ),
              ],
              selected: _selectedSegment,
              onSelectionChanged: (Set<ChatType> newSelection) {
                if (newSelection.isNotEmpty) { // SegmentedButton 至少要有一個選中
                  setState(() {
                    _selectedSegment = newSelection;
                    // 根據選中的 segment 切換 PageView
                    if (newSelection.first == ChatType.buyer) {
                      _pageController.jumpToPage(0); // 或 animateToPage
                    } else {
                      _pageController.jumpToPage(1); // 或 animateToPage
                    }
                  });
                }
              },
              // 您可以進一步自定義 SegmentedButton 的樣式
              style: SegmentedButton.styleFrom(
                backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
                foregroundColor: colorScheme.primary, // 未選中時的文字和圖標顏色
                selectedForegroundColor: colorScheme.onPrimary, // 選中時的文字和圖標顏色
                selectedBackgroundColor: colorScheme.secondary, // 選中時的背景顏色
                // minimumSize: Size(double.infinity, 48), // 可以讓按鈕橫向填滿
              ),
              showSelectedIcon: false, // 通常在 SegmentedButton 中不顯示選中圖標的額外標記
            ),
          ),
        ],
      ),
    );
  }
}

// --- Placeholder for ChatRoomScreen (ensure it's defined elsewhere) ---
class ChatRoomScreen extends StatelessWidget {
  final String chatRoomId;
  final String otherUserName;
  final String? otherUserAvatarUrl;
  final String otherUserId;
  final String currentUserId;

  const ChatRoomScreen({
    super.key,
    required this.chatRoomId,
    required this.otherUserName,
    this.otherUserAvatarUrl,
    required this.otherUserId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("與 $otherUserName 的聊天"),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('聊天室 ID: $chatRoomId', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('與: $otherUserName (ID: $otherUserId)', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('您的ID: $currentUserId', style: const TextStyle(fontSize: 16)),
              if (otherUserAvatarUrl != null && otherUserAvatarUrl!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Center(child: CircleAvatar(radius: 50, backgroundImage: NetworkImage(otherUserAvatarUrl!))),
              ]
            ],
          ),
        ),
      ),
      backgroundColor: colorScheme.background,
    );
  }
}
