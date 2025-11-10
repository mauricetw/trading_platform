// --- FILE: lib/providers/chat_provider.dart ---
import 'dart:async';
import 'package:flutter/foundation.dart';

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
  Map<int, List<Message>> _messagesByRoom = {};
  bool _isLoadingMessages = false;
  String? _messageError;
  int? _activeRoomId;
  StreamSubscription? _messageSubscription;

  // --- Getters ---
  List<ChatRoom> get buyerChats => _buyerChats;
  List<ChatRoom> get sellerChats => _sellerChats;
  bool get isLoadingLists => _isLoadingLists;
  String? get listError => _listError;

  List<Message> get activeRoomMessages => _messagesByRoom[_activeRoomId] ?? [];
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

  void _updateDependencies() {
    if (_authProvider?.isLoggedIn == true) {
      fetchChatLists();
    } else {
      _buyerChats = [];
      _sellerChats = [];
      _messagesByRoom = {};
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
    } finally {
      _isLoadingLists = false;
      notifyListeners();
    }
  }

  Future<void> enterChatRoom(int roomId) async {
    final token = _authProvider?.token;
    if (token == null) return;

    _activeRoomId = roomId;
    _isLoadingMessages = true;
    _messageError = null;
    notifyListeners();

    try {
      final messages = await _chatService.getMessages(roomId);
      _messagesByRoom[roomId] = messages;

      // 連接 WebSocket 並開始監聽
      _webSocketService.connect(roomId, token);
      _messageSubscription?.cancel(); // 取消舊的監聽
      _messageSubscription = _webSocketService.messages?.listen((newMessage) {
        if (_messagesByRoom.containsKey(roomId)) {
          // 檢查是否已存在相同 ID 的訊息（避免重複）
          final existingIndex = _messagesByRoom[roomId]!.indexWhere(
                  (msg) => msg.id == newMessage.id
          );

          if (existingIndex == -1) {
            // 新訊息，直接添加
            _messagesByRoom[roomId]!.add(newMessage);
            debugPrint('ChatProvider: WebSocket 收到新訊息 (ID: ${newMessage.id})');
          } else {
            // 已存在，更新該訊息（從臨時 ID 更新為真實 ID）
            _messagesByRoom[roomId]![existingIndex] = newMessage;
            debugPrint('ChatProvider: 更新訊息 (臨時ID -> 真實ID: ${newMessage.id})');
          }
          notifyListeners();
        }
      }, onError: (error) {
        _messageError = "連線錯誤: $error";
        notifyListeners();
      });

    } catch (e) {
      _messageError = "無法載入歷史訊息: $e";
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<int> findOrCreateChatRoomByProduct(int productId) async {
    final room = await _chatService.findOrCreateChatRoom(productId);
    return room.id;
  }

  void leaveChatRoom() {
    _webSocketService.disconnect();
    _messageSubscription?.cancel();
    _activeRoomId = null;
    // 離開時刷新列表，以更新未讀計數
    fetchChatLists();
  }

  // ✨ 修正後的 sendMessage 方法 - 使用樂觀更新
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final trimmedText = text.trim();
    final currentUserId = _authProvider?.currentUser?.id;
    final roomId = _activeRoomId;

    if (currentUserId == null || roomId == null) {
      debugPrint('ChatProvider: 無法發送訊息 - 使用者未登入或未進入聊天室');
      return;
    }

    // 獲取對方的 ID
    final receiverId = _getReceiverIdForRoom(roomId);

    // 樂觀更新：立即添加訊息到本地列表
    final optimisticMessage = Message(
      id: -DateTime.now().millisecondsSinceEpoch, // 使用負數作為臨時 ID
      chatRoomId: roomId,
      senderId: currentUserId,
      receiverId: receiverId,
      text: trimmedText,
      timestamp: DateTime.now(),
      type: MessageType.text,
      isRead: false,
      isEdited: false,
    );

    // 添加到本地列表
    if (_messagesByRoom.containsKey(roomId)) {
      _messagesByRoom[roomId]!.add(optimisticMessage);
      notifyListeners(); // 🔥 立即通知 UI 更新
      debugPrint('ChatProvider: 已添加樂觀訊息到本地列表 (臨時ID: ${optimisticMessage.id})');
    }

    // 發送到後端
    _webSocketService.sendMessage(trimmedText);
    debugPrint('ChatProvider: 已透過 WebSocket 發送訊息');
  }

  // 輔助方法：從聊天室列表中獲取對方的 ID
  int _getReceiverIdForRoom(int roomId) {
    try {
      // 先在買家列表中尋找
      final buyerChat = _buyerChats.firstWhere(
            (chat) => chat.id == roomId,
        orElse: () => throw Exception('not found in buyer chats'),
      );
      return buyerChat.otherParty.id;
    } catch (e) {
      // 如果買家列表找不到，再找賣家列表
      try {
        final sellerChat = _sellerChats.firstWhere(
              (chat) => chat.id == roomId,
          orElse: () => throw Exception('not found in seller chats'),
        );
        return sellerChat.otherParty.id;
      } catch (e) {
        // 如果都找不到，返回 0（臨時值，WebSocket 會更新）
        debugPrint('ChatProvider: 無法找到 roomId=$roomId 的接收者，使用預設值 0');
        return 0;
      }
    }
  }
}