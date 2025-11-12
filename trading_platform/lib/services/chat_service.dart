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
  Future<List<Message>> getMessages(int chatRoomId) async {
    debugPrint('[ChatService] API: Getting messages for room #$chatRoomId');
    final responseBody = await _apiClient.get('/chats/$chatRoomId/messages');
    final List<dynamic> messagesJson = responseBody;
    return messagesJson.map((json) => Message.fromJson(json)).toList();
  }

  /// 根據商品 ID 尋找或建立聊天室
  Future<ChatRoom> findOrCreateChatRoom(int productId) async {
    debugPrint('[ChatService] API: Finding or creating chat for product #$productId');
    final responseBody = await _apiClient.post(
      '/chats',
      body: {'product_id': productId},
    );
    return ChatRoom.fromJson(responseBody);
  }

  /// 標記聊天室為已讀
  Future<void> markAsRead(int chatRoomId) async {
    debugPrint('[ChatService] API: Marking chat room #$chatRoomId as read');
    try {
      // --- [修正] 現在可以不傳 body ---
      await _apiClient.post('/chats/$chatRoomId/read');
    } catch (e) {
      debugPrint('[ChatService] Error marking as read: $e');
      // 不拋出錯誤，讓應用繼續運行
    }
  }
}