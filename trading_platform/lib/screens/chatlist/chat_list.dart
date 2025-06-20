import 'package:flutter/material.dart';
import 'chatroom.dart'; // 假設 chatroom.dart 存在且 ChatRoomScreen 已定義

// ChatRoomSummary class (假設和之前一樣)
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

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController; // 用於同步 TabBarView

  // --- 顏色定義 ---
  static const Color appBarColor = Color(0xFF004E98); // AppBar 固定深藍色
  static const Color activeTabBackgroundColor = Color(0xFFFF8D36); // 選中 Tab 的背景色 (橘色)
  static const Color inactiveTabBackgroundColor = Color(0xFF004E98); // 未選中 Tab 的背景色 (灰色)

  static const Color appBarTextColor = Colors.white; // AppBar 文字顏色
  static const Color activeTabTextColor = Colors.white;    // 選中 Tab 的文字顏色 (在橘色背景上建議用白色)
  static const Color inactiveTabTextColor = Colors.black54;  // 未選中 Tab 的文字顏色 (在灰色背景上建議用深灰色或黑色)
  // ---           ---

  int _selectedTabIndex = 0; // 用於追蹤自訂 Tab 的選中狀態

  // 模擬數據和狀態 (和之前一樣)
  List<ChatRoomSummary> _buyerChats = [];
  List<ChatRoomSummary> _sellerChats = [];
  bool _isLoadingBuyerChats = true;
  bool _isLoadingSellerChats = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _selectedTabIndex) {
        if (mounted) {
          setState(() {
            _selectedTabIndex = _tabController.index;
          });
        }
      }
    });
    _initializeScreenData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreenData() async {
    await Future.delayed(const Duration(milliseconds: 100)); // 模擬獲取用戶ID
    if (mounted) {
      setState(() {
        _currentUserId = "user_self_id_chatlist_example"; // 模擬用戶ID
      });
      if (_currentUserId == null) {
        // 實際應用中可能需要錯誤處理或重試
        print("錯誤：無法獲取 currentUserId");
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
    await Future.delayed(const Duration(seconds: 1)); // 模擬網絡延遲
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
    await Future.delayed(const Duration(seconds: 1));
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
      return const Center(child: Text('目前沒有相關聊天', style: TextStyle(fontSize: 16, color: Colors.grey)));
    }
    return ListView.builder(
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
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    chat.unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 4 + 2 + 10 + 2), // 保持佔位高度
              ]
            ],
          ),
          onTap: () => _navigateToChatRoom(context, chat),
        );
      },
    );
  }

  // 自訂的 Tab 按鈕 Widget
  Widget _buildCustomTab({
    required String text,
    required int index,
  }) {
    bool isSelected = _selectedTabIndex == index;
    Color backgroundColor = isSelected ? activeTabBackgroundColor : inactiveTabBackgroundColor;
    Color textColor = isSelected ? activeTabTextColor : inactiveTabTextColor;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (mounted) {
            setState(() {
              _selectedTabIndex = index;
              _tabController.animateTo(index); // 同步 TabBarView
            });
          }
        },
        child: Container(
          height: kToolbarHeight, // 和 AppBar bottom 的預期高度一致
          color: backgroundColor,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '我的聊天',
          style: TextStyle(color: appBarTextColor),
        ),
        backgroundColor: appBarColor, // AppBar 固定深藍色
        elevation: 0,
        iconTheme: const IconThemeData(color: appBarTextColor), // AppBar 圖標顏色
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight), // Tab 區域的高度
          child: Row(
            children: <Widget>[
              _buildCustomTab(
                text: '與賣家溝通', // 買家視角
                index: 0,
              ),
              _buildCustomTab(
                text: '與買家溝通', // 賣家視角
                index: 1,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(context, _buyerChats, _isLoadingBuyerChats),
          _buildChatList(context, _sellerChats, _isLoadingSellerChats),
        ],
      ),
    );
  }
}

// 再次提醒: 您需要有一個 ChatRoomScreen 的實現
// class ChatRoomScreen extends StatelessWidget {
//   final String chatRoomId;
//   final String otherUserName;
//   final String? otherUserAvatarUrl;
//   final String otherUserId;
//   final String currentUserId;

//   const ChatRoomScreen({
//     Key? key,
//     required this.chatRoomId,
//     required this.otherUserName,
//     this.otherUserAvatarUrl,
//     required this.otherUserId,
//     required this.currentUserId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("與 ${otherUserName} 的聊天")),
//       body: Center(
//         child: Text(
//             '聊天室 ID: $chatRoomId\n與: $otherUserName (ID: $otherUserId)\n您的ID: $currentUserId'),
//       ),
//     );
//   }
// }