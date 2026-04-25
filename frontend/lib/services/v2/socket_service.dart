import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';
import 'dart:io'; // Platform check karne ke liye

class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  // ─── Connect ──────────────────────────────────────────────────────────────────

  Future<void> connect() async {
    // Agar pehle se connected hai, toh dobara connect na karein
    if (isConnected) {
      print('ℹ️ SocketService: Already connected.');
      return;
    }

    final token = await ApiService.getToken();
    if (token == null) {
      print('⚠️ SocketService: No token found. Cannot connect.');
      return;
    }

    // 💡 AUTO-DETECT SERVER URL
    // Agar Emulator hai toh 10.0.2.2, agar real phone hai toh apna IP yahan dalo
    String serverUrl = Platform.isAndroid ? 'http://10.0.2.2:5000' : 'http://localhost:5000';
    
    // AGAR AAP REAL PHONE USE KAR RAHE HAIN, TOH NICHE WALI LINE UNCOMMENT KAREIN:
    // serverUrl = 'http://192.168.1.5:5000'; // Apne PC ka IP dalo

    print('🌐 Attempting to connect to: $serverUrl');

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // FASTEST: Use only websocket
          .setAuth({'token': token})    // Backend middleware ke liye zaroori hai
          .enableForceNew()             // Har baar fresh connection banaye
          .disableAutoConnect()         // Hum manually .connect() call karenge
          .enableReconnection()         // Internet jane par auto-reconnect
          .setReconnectionAttempts(10)
          .setReconnectionDelay(3000)
          .build(),
    );

    // Manual Connection
    _socket!.connect();

    // ─── Event Listeners ───

    _socket!.onConnect((_) {
      print('✅ Socket connected successfully: ${_socket!.id}');
    });

    _socket!.onConnectError((err) {
      print('❌ Socket connect error: $err');
      // Agar "Invalid namespace" ya "auth error" aaye toh backend terminal check karein
    });

    _socket!.onDisconnect((_) {
      print('🔌 Socket disconnected from server');
    });

    _socket!.onError((err) {
      print('❌ General Socket error: $err');
    });
  }

  // ─── Disconnect ───────────────────────────────────────────────────────────────

  void disconnect() {
    print('🔌 Manually disconnecting socket...');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // ─── Rooms ────────────────────────────────────────────────────────────────────

  void joinRoom(String conversationId) {
    if (isConnected) {
      _socket?.emit('join_room', {'conversationId': conversationId});
      print('🏠 Joined room: $conversationId');
    }
  }

  void leaveRoom(String conversationId) {
    if (isConnected) {
      _socket?.emit('leave_room', {'conversationId': conversationId});
      print('🏠 Left room: $conversationId');
    }
  }

  void markAsRead(String conversationId) {
    if (isConnected) {
      _socket?.emit('message_read', {'conversationId': conversationId});
      print('📖 Marked as read: $conversationId');
    }
  }

  // ─── Messaging ────────────────────────────────────────────────────────────────

  void sendMessage({
    required String conversationId,
    required String text,
    String type = 'text',
    String? mediaUrl,
    String? replyTo,
    int? duration,
  }) {
    if (!isConnected) {
      print('❌ Cannot send message: Socket not connected');
      return;
    }

    _socket?.emit('send_message', {
      'conversationId': conversationId,
      'text': text,
      'type': type,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (replyTo != null) 'replyTo': replyTo,
      if (duration != null) 'duration': duration,
    });
  }

  // ─── Typing ───────────────────────────────────────────────────────────────────

  void startTyping(String conversationId) {
    _socket?.emit('typing_start', {'conversationId': conversationId});
  }

  void stopTyping(String conversationId) {
    _socket?.emit('typing_stop', {'conversationId': conversationId});
  }

  // ─── Listeners ────────────────────────────────────────────────────────────────

  void onNewMessage(Function(dynamic) callback) {
    _socket?.on('new_message', callback);
  }

  void onUserStatusChange(Function(dynamic) callback) {
    _socket?.on('user_status_change', callback);
  }

  void onTypingStart(Function(dynamic) callback) => _socket?.on('typing_start', callback);
  void onTypingStop(Function(dynamic) callback) => _socket?.on('typing_stop', callback);

  void onMessageStatus(Function(dynamic) callback) {
    _socket?.on('message_status', callback);
  }

  void onMessageRead(Function(dynamic) callback) {
    _socket?.on('message_read', callback);
  }

  // ─── Cleanup ──────────────────────────────────────────────────────────────────

  void removeAllListeners() {
    _socket?.off('new_message');
    _socket?.off('typing_start');
    _socket?.off('typing_stop');
    _socket?.off('user_status_change');
    _socket?.off('message_status');
    _socket?.off('message_read');
    print('🧹 All socket listeners removed');
  }
}