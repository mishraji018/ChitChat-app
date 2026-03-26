import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static IO.Socket? _socket;
  static bool _isConnected = false;

  static bool get isConnected => _isConnected;

  // Connect to socket server
  static void connect(String token) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      'http://10.0.2.2:5000',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setAuth({'token': token})
        .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      print('✅ Socket connected');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('❌ Socket disconnected');
    });

    _socket!.onConnectError((error) {
      print('Socket connect error: $error');
    });
  }

  // Disconnect
  static void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  // Join conversation room
  static void joinRoom(String conversationId) {
    _socket?.emit('join_room', {'conversationId': conversationId});
  }

  // Leave room
  static void leaveRoom(String conversationId) {
    _socket?.emit('leave_room', {'conversationId': conversationId});
  }

  // Send message
  static void sendMessage({
    required String conversationId,
    required String receiverId,
    required String type,
    String? text,
    String? mediaUrl,
    String? replyToId,
  }) {
    _socket?.emit('send_message', {
      'conversationId': conversationId,
      'receiverId': receiverId,
      'type': type,
      'text': text,
      'mediaUrl': mediaUrl,
      'replyToId': replyToId,
    });
  }

  // Typing indicators
  static void startTyping(String conversationId) {
    _socket?.emit('typing_start', {'conversationId': conversationId});
  }

  static void stopTyping(String conversationId) {
    _socket?.emit('typing_stop', {'conversationId': conversationId});
  }

  // Message delivered
  static void messageDelivered(String messageId) {
    _socket?.emit('message_delivered', {'messageId': messageId});
  }

  // Message read
  static void messageRead(String conversationId) {
    _socket?.emit('message_read', {'conversationId': conversationId});
  }

  // Listen for new messages
  static void onNewMessage(Function(Map<String, dynamic>) callback) {
    _socket?.on('new_message', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  // Listen for message status
  static void onMessageStatus(Function(Map<String, dynamic>) callback) {
    _socket?.on('message_status', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  // Listen for typing
  static void onTypingStart(Function(Map<String, dynamic>) callback) {
    _socket?.on('typing_start', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  static void onTypingStop(Function(Map<String, dynamic>) callback) {
    _socket?.on('typing_stop', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  // Listen for user online/offline
  static void onUserOnline(Function(String) callback) {
    _socket?.on('user_online', (data) {
      callback(data['userId'] as String);
    });
  }

  static void onUserOffline(Function(Map<String, dynamic>) callback) {
    _socket?.on('user_offline', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  // Listen for message edited
  static void onMessageEdited(Function(Map<String, dynamic>) callback) {
    _socket?.on('message_edited', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  // Listen for message deleted
  static void onMessageDeleted(Function(Map<String, dynamic>) callback) {
    _socket?.on('message_deleted', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  // Remove all listeners
  static void removeAllListeners() {
    _socket?.clearListeners();
  }

  // Remove specific listener
  static void off(String event) {
    _socket?.off(event);
  }
}
