// --- FILE: lib/providers/chat_provider.dart ---
import 'dart:async';
import 'package:flutter/foundation.dart';
// 1. 引入 crypto 來生成本地 ID (或使用 'uuid' 套件)
import 'dart:math';
import 'dart:convert';

import '../models/chat/chat_room.dart';
import '../models/chat/message.dart';
import '../services/chat_service.dart';
import '../services/websocket_service.dart';
import 'auth_provider.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService;
  final WebSocketService _webSocketService;
  AuthProvider? _authProvider;

  // --- 列表狀態 ---
  List<ChatRoom> _buyerChats = [];
  List<ChatRoom> _sellerChats = [];
  bool _isLoadingLists = false;
  String? _listError;

  // --- 聊天室狀態 ---
  // 3. 使用 Map<String, Message>，key 是 'localId' 或 'id'
  Map<int, Map<String, Message>> _messagesByRoom = {};
  bool _isLoadingMessages = false;
  String? _messageError;
  int? _activeRoomId;
  // 4. 新增：儲存當前聊天室的對方 ID
  int? _activeRoomReceiverId;
  StreamSubscription? _messageSubscription;

  // 儲存 'localId' 到 'serverId' 的映射
  Map<String, String> _localIdToServerIdMap = {};

  // --- Getters ---
  List<ChatRoom> get buyerChats => _buyerChats;
  List<ChatRoom> get sellerChats => _sellerChats;
  bool get isLoadingLists => _isLoadingLists;
  String? get listError => _listError;

  // 5. Getter：將 Map 轉換為排序後的 List
  List<Message> get activeRoomMessages {
    if (_activeRoomId == null || !_messagesByRoom.containsKey(_activeRoomId)) {
      return [];
    }
    final messagesList = _messagesByRoom[_activeRoomId]!.values.toList();
    // 根據時間戳排序
    messagesList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messagesList;
  }
  bool get isLoadingMessages => _isLoadingMessages;
  String? get messageError => _messageError;

  ChatProvider(this._chatService, this._webSocketService, this._authProvider) {
    _updateDependencies();
  }

  void update(AuthProvider newAuthProvider) {
    if (newAuthProvider.isLoggedIn != _authProvider?.isLoggedIn) {
      _authProvider = newAuthProvider;
      _updateDependencies();
    }
  }

  // 2. 輔助函式：生成隨機的 localId
  String _generateLocalId() {
    return 'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';
  }

  void _updateDependencies() {
    if (_authProvider?.isLoggedIn == true) {
      fetchChatLists();
    } else {
      _buyerChats = [];
      _sellerChats = [];
      _messagesByRoom = {};
      _messageSubscription?.cancel();
      _webSocketService.disconnect();
      _localIdToServerIdMap.clear();
      notifyListeners();
    }
  }

  Future<void> fetchChatLists() async {
    if (!(_authProvider?.isLoggedIn ?? false)) return;
    _isLoadingLists = true;
    _listError = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _chatService.getChatRooms(role: 'buyer'),
        _chatService.getChatRooms(role: 'seller'),
      ]);
      _buyerChats = results[0];
      _sellerChats = results[1];
    } catch (e) {
      _listError = "無法載入聊天列表: $e";
      debugPrint('[ChatProvider] fetchChatLists Error: $e');
    } finally {
      _isLoadingLists = false;
      notifyListeners();
    }
  }

  // 6. 修改：enterChatRoom 需接收 receiverId
  Future<void> enterChatRoom(int roomId, int receiverId) async {
    final token = _authProvider?.token;
    if (token == null) return;

    // 如果已經在這個聊天室，不要重做所有事情
    if (_activeRoomId == roomId && _messagesByRoom.containsKey(roomId)) {
      debugPrint('[ChatProvider] 已經在聊天室 $roomId');
      // 確保 WebSocket 仍在連線
      _webSocketService.connect(roomId, token);
      return;
    }

    // 離開上一個房間
    // (如果 _activeRoomId 不是 null，呼叫 leaveChatRoom)
    // 這裡簡化：假設UI導航會自動呼叫 leaveChatRoom
    _messageSubscription?.cancel();
    _localIdToServerIdMap.clear(); // 清除上個房間的ID映射

    _activeRoomId = roomId;
    _activeRoomReceiverId = receiverId; // 儲存對方 ID
    _isLoadingMessages = true;
    _messageError = null;
    notifyListeners();

    try {
      final messages = await _chatService.getMessages(roomId);
      // 7. 將 List<Message> 轉換為 Map<String, Message>
      _messagesByRoom[roomId] = {
        for (var msg in messages) (msg.id!.toString()): msg
      };

      // 連接 WebSocket 並開始監聽
      _webSocketService.connect(roomId, token);

      _messageSubscription = _webSocketService.messages?.listen(
              (newMessage) {
            // --- [Optimistic UI 修正] ---
            // 這是 WebSocket 收到廣播訊息的地方
            if (!_messagesByRoom.containsKey(roomId)) return;

            final serverId = newMessage.id!.toString();
            final senderId = newMessage.senderId;
            final currentUserId = _authProvider?.currentUser?.id;

            // 檢查這是不是「自己」傳送訊息的「廣播確認」
            if (senderId == currentUserId) {
              // 找出是哪一則 'localId' 對應到這則 'serverId'
              // 簡單起見：我們假設最後一則 pending 的訊息就是它
              // (更穩健的作法是後端回傳 localId)

              String? pendingLocalId;
              for (var entry in _messagesByRoom[roomId]!.entries) {
                if (entry.value.isPending && entry.value.text == newMessage.text) {
                  pendingLocalId = entry.key;
                  break;
                }
              }

              if (pendingLocalId != null) {
                // 找到了！這是一則「傳送中」訊息的確認
                // 1. 從 Map 中移除「傳送中」的訊息
                _messagesByRoom[roomId]!.remove(pendingLocalId);
                // 2. 將「已確認的」伺服器訊息加入 Map
                _messagesByRoom[roomId]![serverId] = newMessage; // (newMessage 已經是 isPending: false)
              } else {
                // 雖然是自己傳的，但找不到對應的 pending 訊息
                // (可能已被處理)，直接加入
                _messagesByRoom[roomId]![serverId] = newMessage;
              }

            } else {
              // 這是一則「對方」傳來的全新訊息
              _messagesByRoom[roomId]![serverId] = newMessage;
            }

            notifyListeners();
          },
          onError: (error) {
            _messageError = "連線錯誤: $error";
            debugPrint('[ChatProvider] WebSocket Stream Error: $error');
            notifyListeners();
          }
      );

    } catch (e) {
      _messageError = "無法載入歷史訊息: $e";
      debugPrint('[ChatProvider] enterChatRoom Error: $e');
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<int> findOrCreateChatRoomByProduct(int productId) async {
    final room = await _chatService.findOrCreateChatRoom(productId);
    // 順便更新列表
    fetchChatLists();
    return room.id;
  }

  void leaveChatRoom() {
    debugPrint('[ChatProvider] 離開聊天室...');
    _webSocketService.disconnect();
    _messageSubscription?.cancel();
    _activeRoomId = null;
    _activeRoomReceiverId = null; // 清除對方 ID
    _localIdToServerIdMap.clear(); // 清除 ID 映射
    // 離開時刷新列表，以更新未讀計數
    fetchChatLists();
  }

  // 10. --- [Optimistic UI 關鍵] ---
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // 11. 檢查是否在聊天室中
    final roomId = _activeRoomId;
    final receiverId = _activeRoomReceiverId;
    final senderId = _authProvider?.currentUser?.id;

    if (roomId == null || receiverId == null || senderId == null) {
      debugPrint('[ChatProvider] Error: 不在聊天室內或無法發送 (roomId, receiverId, senderId 之一為 null)');
      return;
    }

    // 12. 建立一個「本地的」、「傳送中」的訊息
    final localId = _generateLocalId();
    final pendingMessage = Message(
        localId: localId,
        id: null, // 伺服器 ID 尚未存在
        chatRoomId: roomId,
        senderId: senderId,
        receiverId: receiverId,
        text: text.trim(),
        timestamp: DateTime.now(), // 使用本地的當前時間
        isPending: true // 標記為傳送中
    );

    // 13. [Optimistic UI] 立刻將這則訊息加入狀態並更新 UI
    if (!_messagesByRoom.containsKey(roomId)) {
      _messagesByRoom[roomId] = {};
    }
    _messagesByRoom[roomId]![localId] = pendingMessage;
    notifyListeners(); // UI 立刻顯示 "傳送中" 的訊息

    // 14. [背景執行] 真正透過 WebSocket 傳送文字
    //     後端會儲存它，然後透過 WebSocket 廣播「真實的」Message JSON 回來
    try {
      _webSocketService.sendMessage(text.trim());
    } catch (e) {
      debugPrint('[ChatProvider] sendMessage Error: $e');
      // 如果 WebSocket 傳送失敗，我們需要更新 UI
      _messagesByRoom[roomId]![localId] = pendingMessage.copyWith(
          isPending: false,
          text: "${pendingMessage.text} (傳送失敗)" // 範例：顯示失敗
      );
      notifyListeners();
    }
  }
}