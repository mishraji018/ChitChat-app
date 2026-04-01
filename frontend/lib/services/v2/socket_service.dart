import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';

/// Manages the Socket.IO connection and all real-time events.
/// Usage:
///   await SocketService.instance.connect();
///   SocketService.instance.joinRoom(conversationId);
///   SocketService.instance.sendMessage(...);
///   SocketService.instance.onNewMessage((msg) { ... });
class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  // ─── Connect ──────────────────────────────────────────────────────────────────

  Future<void> connect() async {
    if (isConnected) return;

    final token = await ApiService.getToken();
    if (token == null) {
      print('⚠️  SocketService: No token found. Cannot connect.');
      return;
    }

    // 🔧 CHANGE THIS to match your ApiService.baseUrl host (without /api)
    // Android Emulator:  http://10.0.2.2:5000
    // Physical Device:   http://YOUR_LOCAL_IP:5000
    // Production:        https://your-deployed-backend.com
    const serverUrl = 'http://10.0.2.2:5000';

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('✅ Socket connected: ${_socket!.id}');
    });

    _socket!.onDisconnect((_) {
      print('🔌 Socket disconnected');
    });

    _socket!.onConnectError((err) {
      print('❌ Socket connect error: $err');
    });

    _socket!.onError((err) {
      print('❌ Socket error: $err');
    });
  }

  // ─── Disconnect ───────────────────────────────────────────────────────────────

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // ─── Rooms ────────────────────────────────────────────────────────────────────

  void joinRoom(String conversationId) {
    _socket?.emit('join_room', {'conversationId': conversationId});
  }

  void leaveRoom(String conversationId) {
    _socket?.emit('leave_room', {'conversationId': conversationId});
  }

  // ─── Messaging ────────────────────────────────────────────────────────────────

  /// Send a message via Socket (real-time, preferred over REST)
  void sendMessage({
    required String conversationId,
    required String text,
    String type = 'text',
    String? mediaUrl,
    String? replyTo,
    int? duration,
  }) {
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

  // ─── Read Receipts ────────────────────────────────────────────────────────────

  void markAsRead(String conversationId) {
    _socket?.emit('message_read', {'conversationId': conversationId});
  }

  // ─── Listeners ────────────────────────────────────────────────────────────────

  /// Called when a new message arrives in any joined room
  void onNewMessage(Function(dynamic) callback) {
    _socket?.on('new_message', callback);
  }

  /// Called when someone starts typing
  void onTypingStart(Function(dynamic) callback) {
    _socket?.on('typing_start', callback);
  }

  /// Called when someone stops typing
  void onTypingStop(Function(dynamic) callback) {
    _socket?.on('typing_stop', callback);
  }

  /// Called when message status changes (delivered/read)
  void onMessageStatus(Function(dynamic) callback) {
    _socket?.on('message_status', callback);
  }

  /// Called when any user's online status changes
  void onUserStatusChange(Function(dynamic) callback) {
    _socket?.on('user_status_change', callback);
  }

  // ─── Remove Listeners ─────────────────────────────────────────────────────────

  void offNewMessage() => _socket?.off('new_message');
  void offTypingStart() => _socket?.off('typing_start');
  void offTypingStop() => _socket?.off('typing_stop');
  void offMessageStatus() => _socket?.off('message_status');
  void offUserStatusChange() => _socket?.off('user_status_change');

  /// Remove all listeners at once (call when leaving a screen)
  void removeAllListeners() {
    offNewMessage();
    offTypingStart();
    offTypingStop();
    offMessageStatus();
    offUserStatusChange();
  }
}
