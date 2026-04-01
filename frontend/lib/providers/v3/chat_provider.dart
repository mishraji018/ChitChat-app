import 'package:flutter/material.dart';
import '../../services/v2/api_service.dart';
import '../../services/v2/socket_service.dart';

/// Manages chat list + messages for the active conversation.
/// Use one ChatProvider per conversation screen (via Provider or setState).
///
/// Example in a chat screen:
///   final chatProvider = ChatProvider();
///   await chatProvider.loadMessages(conversationId);
///   chatProvider.listenToSocket(conversationId);
class ChatProvider extends ChangeNotifier {
  List<dynamic> _chats = [];
  List<dynamic> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  bool _isTyping = false;
  String? _typingUserName;

  List<dynamic> get chats => _chats;
  List<dynamic> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  bool get isTyping => _isTyping;
  String? get typingUserName => _typingUserName;

  // ─── Chats List ───────────────────────────────────────────────────────────────

  Future<void> loadChats() async {
    _isLoading = true;
    notifyListeners();
    try {
      _chats = await ApiService.getChats();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> createChat(String participantId) async {
    try {
      final data = await ApiService.createChat(participantId);
      final chat = data['chat'] ?? data;
      // Add to list if not already present
      final exists = _chats.any((c) => c['_id'] == chat['_id']);
      if (!exists) {
        _chats.insert(0, chat);
        notifyListeners();
      }
      return chat;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> createGroupChat({
    required String groupName,
    required List<String> participantIds,
    String? groupAvatar,
  }) async {
    try {
      final data = await ApiService.createGroupChat(
        groupName: groupName,
        participantIds: participantIds,
        groupAvatar: groupAvatar,
      );
      final chat = data['chat'] ?? data;
      _chats.insert(0, chat);
      notifyListeners();
      return chat;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  // ─── Messages ─────────────────────────────────────────────────────────────────

  Future<void> loadMessages(String conversationId, {int page = 1}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final msgs = await ApiService.getMessages(conversationId, page: page);
      if (page == 1) {
        _messages = msgs.reversed.toList(); // newest last for ListView
      } else {
        _messages = [...msgs.reversed.toList(), ..._messages]; // prepend older
      }
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send via Socket (real-time). Optimistically adds message to list.
  void sendMessage({
    required String conversationId,
    required String text,
    String type = 'text',
    String? mediaUrl,
    String? replyTo,
    int? duration,
  }) {
    SocketService.instance.sendMessage(
      conversationId: conversationId,
      text: text,
      type: type,
      mediaUrl: mediaUrl,
      replyTo: replyTo,
      duration: duration,
    );
  }

  Future<void> editMessage(String messageId, String newText) async {
    try {
      final data = await ApiService.editMessage(messageId, newText);
      final updated = data['message'] ?? data;
      final idx = _messages.indexWhere((m) => m['_id'] == messageId);
      if (idx != -1) {
        _messages[idx] = updated;
        notifyListeners();
      }
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await ApiService.deleteMessage(messageId);
      _messages.removeWhere((m) => m['_id'] == messageId);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<void> reactToMessage(String messageId, String emoji) async {
    try {
      await ApiService.reactToMessage(messageId, emoji);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<void> clearChat(String chatId) async {
    try {
      await ApiService.clearChat(chatId);
      _messages = [];
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  // ─── Socket Listeners ─────────────────────────────────────────────────────────

  /// Call this when entering a chat screen
  void listenToSocket(String conversationId) {
    SocketService.instance.joinRoom(conversationId);
    SocketService.instance.markAsRead(conversationId);

    // New incoming message
    SocketService.instance.onNewMessage((data) {
      _messages.add(data);
      notifyListeners();
    });

    // Typing indicators
    SocketService.instance.onTypingStart((data) {
      _isTyping = true;
      _typingUserName = data['userName'];
      notifyListeners();
    });

    SocketService.instance.onTypingStop((data) {
      _isTyping = false;
      _typingUserName = null;
      notifyListeners();
    });

    // Message read/delivered status
    SocketService.instance.onMessageStatus((data) {
      final status = data['status'];
      for (var i = 0; i < _messages.length; i++) {
        _messages[i]['status'] = status;
      }
      notifyListeners();
    });
  }

  /// Call this when leaving a chat screen
  void stopListening(String conversationId) {
    SocketService.instance.leaveRoom(conversationId);
    SocketService.instance.removeAllListeners();
  }

  // ─── Typing Emitters ──────────────────────────────────────────────────────────

  void emitTypingStart(String conversationId) =>
      SocketService.instance.startTyping(conversationId);

  void emitTypingStop(String conversationId) =>
      SocketService.instance.stopTyping(conversationId);

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
