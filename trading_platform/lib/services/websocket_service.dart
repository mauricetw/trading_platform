// --- FILE: lib/services/websocket_service.dart ---
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/api_config.dart';
import '../models/chat/message.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Stream<Message>? _messageStream;

  Stream<Message>? get messages => _messageStream;

  void connect(int chatRoomId, String token) {
    // 斷開舊的連線以確保只有一個活動連線
    disconnect();

    // 將 http:// 替換為 ws://
    final wsUrl = APIConfig.baseUrl.replaceFirst('http', 'ws');
    final url = Uri.parse('$wsUrl/chats/ws/$chatRoomId/$token');

    debugPrint('[WebSocketService] Connecting to: $url');

    _channel = WebSocketChannel.connect(url);

    // 建立一個廣播 (broadcast) stream，允許多個監聽者
    _messageStream = _channel!.stream.asBroadcastStream().map((data) {
      debugPrint('[WebSocketService] Received raw data: $data');
      final json = jsonDecode(data);
      return Message.fromJson(json);
    }).handleError((error) {
      debugPrint('[WebSocketService] Stream error: $error');
      // 可以在此處實作重連邏輯
    });
  }

  void sendMessage(String text) {
    if (_channel != null && _channel!.sink != null) {
      debugPrint('[WebSocketService] Sending message: $text');
      _channel!.sink.add(text);
    } else {
      debugPrint('[WebSocketService] Error: Cannot send message, channel is not connected.');
    }
  }

  void disconnect() {
    if (_channel != null && _channel!.sink != null) {
      debugPrint('[WebSocketService] Disconnecting...');
      _channel!.sink.close();
      _channel = null;
      _messageStream = null;
    }
  }
}