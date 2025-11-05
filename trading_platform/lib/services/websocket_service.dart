// --- FILE: lib/services/websocket_service.dart ---
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/api_config.dart';
import '../models/chat/message.dart'; // 確保 Message 模型路徑正確

class WebSocketService {
  WebSocketChannel? _channel;
  Stream<Message>? _messageStream;

  Stream<Message>? get messages => _messageStream;

  void connect(int chatRoomId, String token) {
    // 斷開舊的連線以確保只有一個活動連線
    disconnect();

    // 將 http:// 替換為 ws://
    final wsUrl = APIConfig.baseUrl.replaceFirst('http', 'ws');

    // 修正 (Bug Fix):
    // 將 token 從路徑參數 (path parameter) 改為查詢參數 (query parameter)
    // 舊: '$wsUrl/chats/ws/$chatRoomId/$token'
    // 新: '$wsUrl/chats/ws/$chatRoomId?token=$token'
    final url = Uri.parse('$wsUrl/chats/ws/$chatRoomId?token=$token');

    debugPrint('[WebSocketService] 正在連線到: $url');

    try {
      _channel = WebSocketChannel.connect(url);

      // 建立一個廣播 (broadcast) stream，允許多個監聽者
      _messageStream = _channel!.stream.asBroadcastStream().map((data) {
        // 來自後端的 data 應該是一個 JSON 字串 (e.g., '{"id": 1, ...}')
        debugPrint('[WebSocketService] 收到原始資料: $data');
        final json = jsonDecode(data);
        return Message.fromJson(json as Map<String, dynamic>);
      }).handleError((error) {
        debugPrint('[WebSocketService] Stream 發生錯誤: $error');
        // 可以在此處實作重連邏輯
        // 例如：呼叫 disconnect() 並嘗試重新 connect()
        disconnect(); // 發生錯誤時先關閉
      });

      debugPrint('[WebSocketService] 連線已建立。');

    } catch (e) {
      debugPrint('[WebSocketService] 連線失敗: $e');
    }
  }

  void sendMessage(String text) {
    if (text.isEmpty) return; // 不發送空訊息

    if (_channel != null && _channel!.sink != null) {
      debugPrint('[WebSocketService] 正在傳送訊息: $text');
      _channel!.sink.add(text);
    } else {
      debugPrint('[WebSocketService] 錯誤: 無法傳送訊息，channel 未連線。');
    }
  }

  void disconnect() {
    if (_channel != null && _channel!.sink != null) {
      debugPrint('[WebSocketService] 正在斷線...');
      _channel!.sink.close(1000, '用戶正常斷線'); // 使用標準 WebSocket 關閉碼
      _channel = null;
      _messageStream = null;
    }
  }
}