// --- FILE: lib/services/chat_service.dart ---
import 'package:flutter/foundation.dart';
import '../models/chat/chat_room.dart';
import '../models/chat/message.dart';
import 'api_client.dart';

class ChatService {
  final ApiClient _apiClient;
  ChatService(this._apiClient);

  /// 獲取聊天室列表
  Future<List<ChatRoom>> getChatRooms({required String role}) async {
    debugPrint('[ChatService] API: Getting chat rooms for role: $role');
    final responseBody = await _apiClient.get('/chats', queryParams: {'role': role});
    final List<dynamic> roomsJson = responseBody;
    return roomsJson.map((json) => ChatRoom.fromJson(json)).toList();
  }

  /// 獲取指定聊天室的歷史訊息
  /// (後端會在獲取訊息的同時，自動將訊息標記為已讀)
  Future<List<Message>> getMessages(int chatRoomId) async {
    debugPrint('[ChatService] API: Getting messages for room #$chatRoomId');
    final responseBody = await _apiClient.get('/chats/$chatRoomId/messages');
    final List<dynamic> messagesJson = responseBody;
    return messagesJson.map((json) => Message.fromJson(json)).toList();
  }

  /// 根據商品 ID 尋找或建立聊天室 (從商品頁發起)
  Future<ChatRoom> findOrCreateChatRoom(int productId) async {
    debugPrint('[ChatService] API: Finding or creating chat for product #$productId');
    // 對應後端: POST /chats (body: product_id)
    final responseBody = await _apiClient.post(
      '/chats',
      body: {'product_id': productId},
    );
    return ChatRoom.fromJson(responseBody);
  }

  /// [新功能] 與賣家開啟通用聊天 (不綁定商品，從個人頁發起)
  Future<ChatRoom> startGeneralChat(int sellerId) async {
    debugPrint('[ChatService] API: Starting general chat with seller #$sellerId');
    // 對應後端: POST /chats (body: seller_id)
    final responseBody = await _apiClient.post(
      '/chats',
      body: {'seller_id': sellerId},
    );
    return ChatRoom.fromJson(responseBody);
  }

  /// 標記聊天室為已讀
  /// 注意：目前的後端在 getMessages 時會自動標記已讀。
  /// 如果你的後端沒有獨立的 /read 路由，這個函式可能會回傳 404，可以視情況移除或保留。
  Future<void> markAsRead(int chatRoomId) async {
    // debugPrint('[ChatService] API: Marking chat room #$chatRoomId as read');
    // try {
    //   await _apiClient.post('/chats/$chatRoomId/read');
    // } catch (e) {
    //   debugPrint('[ChatService] Error marking as read: $e');
    // }
  }
}