import 'package:flutter/material.dart';
// 假設您的 Message 模型在這裡 (如果路徑不同請修改)
import 'package:first_flutter_project/models/chat/message.dart';
// 假設您的 ChatRoom 模型在這裡 (如果 ChatRoomScreen 內部需要 ChatRoom 模型的實例)
// import 'package:first_flutter_project/models/chat/chat_room.dart';


class ChatRoomScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatarUrl;
  final String currentUserId; // <--- 新增: 當前登錄用戶的ID

  const ChatRoomScreen({
    super.key,
    required this.chatRoomId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatarUrl,
    required this.currentUserId, // <--- 新增
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = []; // 實際使用時，你會用 Message 類型的列表
  bool _isLoading = true;
  // bool _isSending = false; // 可選：用於在發送消息時禁用發送按鈕或顯示進度

  // late Stream<QuerySnapshot> _messageStream; // 如果使用 Firestore Stream

  @override
  void initState() {
    super.initState();
    // widget.currentUserId 已經可用
    print('ChatRoomScreen initialized for room: ${widget.chatRoomId}, with user: ${widget.otherUserName} (ID: ${widget.otherUserId}). Current user: ${widget.currentUserId}');
    _loadInitialMessages();
    // _setupMessageStream(); // 如果使用實時更新
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialMessages() async {
    setState(() => _isLoading = true);
    // TODO: 根據 widget.chatRoomId 從您的後端獲取消息
    // 例如:
    // try {
    //   final fetchedMessages = await YourApiService.getMessagesForChatRoom(widget.chatRoomId);
    //   if (mounted) {
    //     setState(() {
    //       _messages = fetchedMessages;
    //       _isLoading = false;
    //     });
    //     _scrollToBottom(isInitialLoad: true);
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     setState(() => _isLoading = false);
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('加載消息失敗: $e')),
    //     );
    //   }
    // }

    // --- 模擬加載 ---
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        // 創建一些模擬消息，注意 senderId 的使用
        _messages = [
          Message(id: 'm1', chatRoomId: widget.chatRoomId, senderId: widget.otherUserId, receiverId: widget.currentUserId, text: '嗨！你好嗎？', timestamp: DateTime.now().subtract(const Duration(minutes: 5)), type: MessageType.text),
          Message(id: 'm2', chatRoomId: widget.chatRoomId, senderId: widget.currentUserId, receiverId: widget.otherUserId, text: '我很好，謝謝！你呢？', timestamp: DateTime.now().subtract(const Duration(minutes: 4)), type: MessageType.text),
          Message(id: 'm3', chatRoomId: widget.chatRoomId, senderId: widget.otherUserId, receiverId: widget.currentUserId, text: '我也很好。有什麼可以幫你的嗎？', timestamp: DateTime.now().subtract(const Duration(minutes: 3)), type: MessageType.text),
          Message(id: 'm4', chatRoomId: widget.chatRoomId, senderId: widget.currentUserId, receiverId: widget.otherUserId, text: '沒事，只是打個招呼！ 😊', timestamp: DateTime.now().subtract(const Duration(minutes: 2)), type: MessageType.text),
        ];
        _isLoading = false;
      });
      _scrollToBottom(isInitialLoad: true);
    }
    // --- 模擬加載結束 ---
  }

  // void _setupMessageStream() {
  //   // 示例：使用 Firestore
  //   // _messageStream = FirebaseFirestore.instance
  //   //     .collection('chatRooms')
  //   //     .doc(widget.chatRoomId)
  //   //     .collection('messages')
  //   //     .orderBy('timestamp', descending: true) // 通常新消息在列表底部，所以可能是 false
  //   //     .snapshots();
  //   // 在 StreamBuilder 中處理 snapshot 並更新 _messages
  // }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    // if (_isSending) return; // 防止重複發送

    // setState(() => _isSending = true);

    // 1. Get current user ID - 直接從 widget 獲取
    final String currentUserId = widget.currentUserId;

    // 2. 創建消息對象
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 臨時本地ID，後端通常會生成真實ID
      chatRoomId: widget.chatRoomId,
      senderId: currentUserId,
      receiverId: widget.otherUserId,
      text: text,
      timestamp: DateTime.now(),
      type: MessageType.text,
      // isRead: false, // 初始為未讀 (如果由接收方更新)
    );

    // 3. (可選) 樂觀更新UI：立即將消息添加到列表
    if (mounted) {
      setState(() {
        _messages.add(newMessage); // 如果你的列表是時間升序的 (舊消息在前)
        // _messages.insert(0, newMessage); // 如果你的列表是時間降序的 (新消息在前)
      });
      _messageController.clear();
      _scrollToBottom();
    }

    // 4. 發送到後端
    // try {
    //   await YourApiService.sendMessage(newMessage.toJson()); // 假設你的 Message 模型有 toJson()
    //   // 如果後端返回了帶有真實ID的消息，你可能需要更新列表中的臨時消息
    //   print('Message sent successfully to backend.');
    // } catch (e) {
    //   print('Failed to send message: $e');
    //   // 處理發送失敗：可以從列表中移除該消息，或標記為發送失敗
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('消息發送失敗: $e')),
    //     );
    //     setState(() {
    //       _messages.removeWhere((msg) => msg.id == newMessage.id); // 移除樂觀更新的消息
    //     });
    //   }
    // } finally {
    //   // if (mounted) {
    //   //   setState(() => _isSending = false);
    //   // }
    // }

    // --- 模擬發送 ---
    print('模擬發送消息: "${newMessage.text}" from $currentUserId to ${widget.otherUserName}');
    // --- 模擬發送結束 ---
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

  Widget _buildMessageItem(Message message) {
    // 判斷消息是否由當前用戶發送
    final bool isMe = message.senderId == widget.currentUserId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75, // 消息氣泡最大寬度
        ),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor.withOpacity(0.9) : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Text(
          message.text ?? '', // 處理 text 可能為 null 的情況
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.otherUserAvatarUrl != null && widget.otherUserAvatarUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.otherUserAvatarUrl!),
                  radius: 18,
                ),
              ),
            Expanded(child: Text(widget.otherUserName, overflow: TextOverflow.ellipsis)),
          ],
        ),
        // leading: widget.otherUserAvatarUrl != null ? Padding(...) : null, // 另一種顯示頭像的方式
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? Center(
              child: Text(
                '開始對話吧！',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageItem(message);
              },
            ),
            // 如果使用 StreamBuilder:
            // child: StreamBuilder<QuerySnapshot>(
            //   stream: _messageStream,
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return Center(child: CircularProgressIndicator());
            //     }
            //     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            //       return Center(child: Text('No messages yet.'));
            //     }
            //     // 解析 snapshot.data!.docs 到 List<Message>
            //     // _messages = snapshot.data!.docs.map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();
            //     // 如果你的消息是降序的，可能需要 .reversed.toList()
            //     return ListView.builder(...);
            //   },
            // ),
          ),
          _buildMessageInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 2,
            color: Colors.grey.withOpacity(0.15),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // IconButton(
            //   icon: Icon(Icons.add_photo_alternate_outlined, color: Theme.of(context).hintColor),
            //   onPressed: () { /* TODO: 實現選擇圖片功能 */ },
            // ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: '輸入消息...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Colors.grey[800],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                ),
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5, // 允許輸入多行
                onSubmitted: (_) => _sendMessage(),
                // onChanged: (text) { // 可選：用於 "對方正在輸入..." 功能
                //   // TODO: implement typing indicator logic
                // },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: _sendMessage, // _isSending ? null : _sendMessage, // 如果有 _isSending 狀態
            ),
          ],
        ),
      ),
    );
  }
}