// --- FILE: lib/providers/chat_provider.dart ---
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:math'; // 用於生成隨機 localId
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
  // 使用 Map<String, Message>，key 是 'localId' 或 'serverId'，確保去重
  Map<int, Map<String, Message>> _messagesByRoom = {};
  bool _isLoadingMessages = false;
  String? _messageError;

  int? _activeRoomId;
  int? _activeRoomReceiverId; // 儲存當前聊天室的對方 ID (用於發送訊息)

  StreamSubscription? _messageSubscription;

  // 儲存 'localId' 到 'serverId' 的映射
  Map<String, String> _localIdToServerIdMap = {};

  // --- Getters ---
  List<ChatRoom> get buyerChats => _buyerChats;
  List<ChatRoom> get sellerChats => _sellerChats;
  bool get isLoadingLists => _isLoadingLists;
  String? get listError => _listError;

  // 將 Map 轉換為排序後的 List 供 UI 使用
  List<Message> get activeRoomMessages {
    if (_activeRoomId == null || !_messagesByRoom.containsKey(_activeRoomId)) {
      return [];
    }
    final messagesList = _messagesByRoom[_activeRoomId]!.values.toList();
    // 根據時間戳排序 (舊的在前，新的在後)
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

  // 生成隨機的 localId，用於 Optimistic UI
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
      _activeRoomId = null;
      notifyListeners();
    }
  }

  /// 獲取聊天列表 (買家 & 賣家)
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

  /// [新功能] 與賣家開啟通用聊天 (從個人頁面發起)
  Future<int> startGeneralChat(int sellerId) async {
    try {
      final room = await _chatService.startGeneralChat(sellerId);
      // 順便更新列表
      fetchChatLists();
      return room.id;
    } catch (e) {
      debugPrint('[ChatProvider] 開啟通用聊天失敗: $e');
      rethrow;
    }
  }

  /// 進入聊天室
  /// [roomId]: 聊天室 ID
  /// [receiverId]: 對方 User ID (用於發送新訊息時指定接收者)
  Future<void> enterChatRoom(int roomId, int receiverId) async {
    final token = _authProvider?.token;
    if (token == null) return;

    // 如果已經在這個聊天室，只確保 WebSocket 連線
    if (_activeRoomId == roomId && _messagesByRoom.containsKey(roomId)) {
      debugPrint('[ChatProvider] 已經在聊天室 $roomId');
      _webSocketService.connect(roomId, token);
      // --- [修正] 重新進入時也標記為已讀 ---
      await _chatService.markAsRead(roomId);
      return;
    }

    // 清理上一個房間的狀態
    _messageSubscription?.cancel();
    _localIdToServerIdMap.clear();

    _activeRoomId = roomId;
    _activeRoomReceiverId = receiverId;
    _isLoadingMessages = true;
    _messageError = null;
    notifyListeners();

    try {
      // 1. 獲取歷史訊息 (後端通常在獲取歷史訊息時會自動標記已讀，但這裡顯式呼叫 markAsRead 更保險)
      final messages = await _chatService.getMessages(roomId);

      // 轉換 List 為 Map，以 Server ID 為 Key
      _messagesByRoom[roomId] = {
        for (var msg in messages) (msg.id!.toString()): msg
      };

      // --- [關鍵修正] 進入聊天室後立即標記為已讀 ---
      await _chatService.markAsRead(roomId);

      // 2. 連接 WebSocket
      _webSocketService.connect(roomId, token);

      // 3. 監聽新訊息
      _messageSubscription = _webSocketService.messages?.listen(
              (newMessage) {
            if (!_messagesByRoom.containsKey(roomId)) return;

            final serverId = newMessage.id!.toString();
            final senderId = newMessage.senderId;
            final currentUserId = _authProvider?.currentUser?.id;

            // [Optimistic UI 處理]
            // 如果這是「自己」傳送的訊息 (WebSocket 廣播回來的確認)
            if (senderId == currentUserId) {
              // 嘗試尋找對應的 pending 訊息 (內容相同且狀態為 pending)
              String? pendingLocalId;
              for (var entry in _messagesByRoom[roomId]!.entries) {
                if (entry.value.isPending && entry.value.text == newMessage.text) {
                  pendingLocalId = entry.key;
                  break;
                }
              }

              if (pendingLocalId != null) {
                // 找到了！移除本地暫存訊息，加入伺服器正式訊息
                _messagesByRoom[roomId]!.remove(pendingLocalId);
                _messagesByRoom[roomId]![serverId] = newMessage;
              } else {
                // 沒找到對應的 pending (可能已被處理或異常)，直接加入
                _messagesByRoom[roomId]![serverId] = newMessage;
              }
            } else {
              // 這是「對方」傳來的新訊息，直接加入
              _messagesByRoom[roomId]![serverId] = newMessage;

              // --- [修正] 當收到對方訊息時，也立即標記為已讀 ---
              // 如果當前正在此聊天室，立即標記為已讀
              if (_activeRoomId == roomId) {
                _chatService.markAsRead(roomId);
              }
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

  /// 根據商品 ID 尋找或建立聊天室 (舊有功能)
  Future<int> findOrCreateChatRoomByProduct(int productId) async {
    final room = await _chatService.findOrCreateChatRoom(productId);
    fetchChatLists(); // 更新列表
    return room.id;
  }

  /// 離開聊天室
  void leaveChatRoom() {
    debugPrint('[ChatProvider] 離開聊天室...');

    // --- [關鍵修正] 離開前再次標記為已讀，確保萬無一失 ---
    if (_activeRoomId != null) {
      _chatService.markAsRead(_activeRoomId!);
    }

    _webSocketService.disconnect();
    _messageSubscription?.cancel();
    _activeRoomId = null;
    _activeRoomReceiverId = null;
    _localIdToServerIdMap.clear();

    // --- [修正] 延遲刷新列表，確保後端已更新未讀計數 ---
    // 因為 markAsRead 是非同步的，給一點時間讓後端處理完再拉列表，未讀數才會變 0
    Future.delayed(const Duration(milliseconds: 500), () {
      fetchChatLists();
    });
  }

  /// 發送訊息 (支援 Optimistic UI)
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final roomId = _activeRoomId;
    final receiverId = _activeRoomReceiverId;
    final senderId = _authProvider?.currentUser?.id;

    if (roomId == null || receiverId == null || senderId == null) {
      debugPrint('[ChatProvider] Error: 無法發送 (roomId=$roomId, receiverId=$receiverId, senderId=$senderId)');
      return;
    }

    // 1. 建立本地「傳送中」訊息
    final localId = _generateLocalId();
    final pendingMessage = Message(
        localId: localId,
        id: null, // 尚未有 Server ID
        chatRoomId: roomId,
        senderId: senderId,
        receiverId: receiverId,
        text: text.trim(),
        timestamp: DateTime.now(),
        isPending: true // 標記為傳送中
    );

    // 2. 立即更新 UI
    if (!_messagesByRoom.containsKey(roomId)) {
      _messagesByRoom[roomId] = {};
    }
    _messagesByRoom[roomId]![localId] = pendingMessage;
    notifyListeners();

    // 3. 透過 WebSocket 發送
    try {
      _webSocketService.sendMessage(text.trim());
    } catch (e) {
      debugPrint('[ChatProvider] sendMessage Error: $e');
      // 發送失敗，更新訊息狀態顯示失敗 (這裡簡單處理為取消 pending)
      // 實務上可以加入 isFailed 狀態
      _messagesByRoom[roomId]![localId] = pendingMessage.copyWith(
          isPending: false,
          text: "${pendingMessage.text} (傳送失敗)"
      );
      notifyListeners();
    }
  }
}