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
          _messagesByRoom[roomId]!.add(newMessage);
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

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _webSocketService.sendMessage(text.trim());
  }
}