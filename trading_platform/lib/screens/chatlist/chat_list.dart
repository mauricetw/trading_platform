import 'package:flutter/material.dart';
import 'chatroom.dart'; // 假設 chatroom.dart 存在且 ChatRoomScreen 已定義

// 假設您的 ChatRoomSummary 模型在這裡 (如果還在 ChatListScreen 文件中)
class ChatRoomSummary {
  final String id; // 這將作為 chatRoomId
  final String otherPartyName;
  final String? otherPartyAvatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? otherPartyId; // <--- 確保這個字段存在並且被正確填充

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
  // 如果 currentUserId 是從父組件傳遞的:
  // final String currentUserId;
  // const ChatListScreen({super.key, required this.currentUserId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<ChatRoomSummary> _buyerChats = [];
  List<ChatRoomSummary> _sellerChats = [];
  bool _isLoadingBuyerChats = true;
  bool _isLoadingSellerChats = true;

  // 用於存儲當前登錄用戶的ID
  String? _currentUserId; // 初始化為 null

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeScreenData();
  }

  Future<void> _initializeScreenData() async {
    // --- 在這裡獲取當前登錄用戶的 ID ---
    // 這是一個關鍵步驟，您需要用您的實際邏輯替換它

    // 方法3: 模擬獲取 (用於測試，請務必替換)
    await Future.delayed(const Duration(milliseconds: 100)); // 模擬異步獲取
    if (mounted) { // 檢查組件是否還掛載
      setState(() {
        _currentUserId = "user_self_id_chatlist_example"; // <<<<---- ！！！請用您的實際邏輯替換這個！！！
      });

      if (_currentUserId == null) {
        print("ChatListScreen: Current User ID is null after attempting to fetch.");
        if (mounted) { // 再次檢查
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('無法獲取用戶資訊，請嘗試重新登錄。')),
          );
          setState(() { // 停止加載指示器
            _isLoadingBuyerChats = false;
            _isLoadingSellerChats = false;
          });
        }
        return;
      }
      // 確保在獲取到 _currentUserId 後再加載聊天數據
      _loadBuyerChats();
      _loadSellerChats();
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBuyerChats() async {
    if (_currentUserId == null) return; // 如果沒有用戶ID，則不加載
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
    if (_currentUserId == null) return;
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
    // 確保 _currentUserId 已經被賦值
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('錯誤：無法獲取當前用戶資訊。請重試。')),
      );
      print("Navigation Error: _currentUserId is null.");
      return;
    }

    // 確保 otherPartyId 存在
    if (chatSummary.otherPartyId == null || chatSummary.otherPartyId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('錯誤：無法確定聊天對象的ID。')),
      );
      print("Navigation Error: chatSummary.otherPartyId is null or empty for chatRoomId: ${chatSummary.id}");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen( // 確保 ChatRoomScreen 已正確導入並且構造函數匹配
          chatRoomId: chatSummary.id, // chatRoomId
          otherUserName: chatSummary.otherPartyName,
          otherUserAvatarUrl: chatSummary.otherPartyAvatarUrl,
          otherUserId: chatSummary.otherPartyId!,   // <--- 傳遞對方用戶ID
          currentUserId: _currentUserId!,          // <--- 傳遞當前登錄用戶ID
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
              ] else ... [
                const SizedBox(height: 4 + 10 + 4), // 保持高度一致性 (近似值)
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
    // 定義您想要的 AppBar 顏色
    const Color appBarBackgroundColor = Color(0xFF004E98);
    // 定義 AppBar 內容的顏色 (例如文字和圖標)
    const Color appBarContentColor = Colors.white;


    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '我的聊天', // 您可以將標題文字放在這裡
          style: TextStyle(color: appBarContentColor), // 設置標題文字顏色
        ),
        backgroundColor: appBarBackgroundColor, // <--- 設置 AppBar 的背景顏色
        elevation: 0, // 可選：移除 AppBar 下方的陰影，使其更扁平
        iconTheme: const IconThemeData(color: appBarContentColor), // 確保返回按鈕等圖標顏色一致
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '與賣家溝通'),
            Tab(text: '與買家溝通'),
          ],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          labelColor: appBarContentColor, // 選中標籤的文字顏色
          unselectedLabelColor: appBarContentColor.withOpacity(0.7), // 未選中標籤的文字顏色
          indicatorColor: appBarContentColor, // 指示器的顏色
          indicatorWeight: 3.0, // 指示器的厚度
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