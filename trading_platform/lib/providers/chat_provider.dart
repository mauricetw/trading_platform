// --- FILE: lib/providers/chat_provider.dart ---
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:math';

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
  Map<int, Map<String, Message>> _messagesByRoom = {};
  bool _isLoadingMessages = false;
  String? _messageError;
  int? _activeRoomId;
  int? _activeRoomReceiverId;
  StreamSubscription? _messageSubscription;

  Map<String, String> _localIdToServerIdMap = {};

  // --- Getters ---
  List<ChatRoom> get buyerChats => _buyerChats;
  List<ChatRoom> get sellerChats => _sellerChats;
  bool get isLoadingLists => _isLoadingLists;
  String? get listError => _listError;

  List<Message> get activeRoomMessages {
    if (_activeRoomId == null || !_messagesByRoom.containsKey(_activeRoomId)) {
      return [];
    }
    final messagesList = _messagesByRoom[_activeRoomId]!.values.toList();
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

  Future<void> enterChatRoom(int roomId, int receiverId) async {
    final token = _authProvider?.token;
    if (token == null) return;

    if (_activeRoomId == roomId && _messagesByRoom.containsKey(roomId)) {
      debugPrint('[ChatProvider] 已經在聊天室 $roomId');
      _webSocketService.connect(roomId, token);
      // --- [修正] 重新進入時也標記為已讀 ---
      await _chatService.markAsRead(roomId);
      return;
    }

    _messageSubscription?.cancel();
    _localIdToServerIdMap.clear();

    _activeRoomId = roomId;
    _activeRoomReceiverId = receiverId;
    _isLoadingMessages = true;
    _messageError = null;
    notifyListeners();

    try {
      final messages = await _chatService.getMessages(roomId);
      _messagesByRoom[roomId] = {
        for (var msg in messages) (msg.id!.toString()): msg
      };

      // --- [關鍵修正] 進入聊天室後立即標記為已讀 ---
      await _chatService.markAsRead(roomId);

      _webSocketService.connect(roomId, token);

      _messageSubscription = _webSocketService.messages?.listen(
              (newMessage) {
            if (!_messagesByRoom.containsKey(roomId)) return;

            final serverId = newMessage.id!.toString();
            final senderId = newMessage.senderId;
            final currentUserId = _authProvider?.currentUser?.id;

            if (senderId == currentUserId) {
              String? pendingLocalId;
              for (var entry in _messagesByRoom[roomId]!.entries) {
                if (entry.value.isPending && entry.value.text == newMessage.text) {
                  pendingLocalId = entry.key;
                  break;
                }
              }

              if (pendingLocalId != null) {
                _messagesByRoom[roomId]!.remove(pendingLocalId);
                _messagesByRoom[roomId]![serverId] = newMessage;
              } else {
                _messagesByRoom[roomId]![serverId] = newMessage;
              }
            } else {
              // --- [修正] 當收到對方訊息時，也立即標記為已讀 ---
              _messagesByRoom[roomId]![serverId] = newMessage;
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

  Future<int> findOrCreateChatRoomByProduct(int productId) async {
    final room = await _chatService.findOrCreateChatRoom(productId);
    fetchChatLists();
    return room.id;
  }

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
    Future.delayed(const Duration(milliseconds: 500), () {
      fetchChatLists();
    });
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final roomId = _activeRoomId;
    final receiverId = _activeRoomReceiverId;
    final senderId = _authProvider?.currentUser?.id;

    if (roomId == null || receiverId == null || senderId == null) {
      debugPrint('[ChatProvider] Error: 不在聊天室內或無法發送');
      return;
    }

    final localId = _generateLocalId();
    final pendingMessage = Message(
        localId: localId,
        id: null,
        chatRoomId: roomId,
        senderId: senderId,
        receiverId: receiverId,
        text: text.trim(),
        timestamp: DateTime.now(),
        isPending: true
    );

    if (!_messagesByRoom.containsKey(roomId)) {
      _messagesByRoom[roomId] = {};
    }
    _messagesByRoom[roomId]![localId] = pendingMessage;
    notifyListeners();

    try {
      _webSocketService.sendMessage(text.trim());
    } catch (e) {
      debugPrint('[ChatProvider] sendMessage Error: $e');
      _messagesByRoom[roomId]![localId] = pendingMessage.copyWith(
          isPending: false,
          text: "${pendingMessage.text} (傳送失敗)"
      );
      notifyListeners();
    }
  }
}