import 'package:flutter/material.dart';
import '../../services/v2/api_service.dart';
import '../../services/v2/socket_service.dart';
import '../../data/models/message_model.dart';
import '../../data/models/chat_model.dart';
import 'auth_provider.dart'; // To get current userId
import 'package:provider/provider.dart';

/// Manages chat list + messages for the active conversation.
/// Use one ChatProvider per conversation screen (via Provider or setState).
///
/// Example in a chat screen:
///   final chatProvider = ChatProvider();
///   await chatProvider.loadMessages(conversationId);
///   chatProvider.listenToSocket(conversationId);
class ChatProvider extends ChangeNotifier {
  List<ChatModel> _chats = [];
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  bool _isTyping = false;
  String? _typingUserName;

  List<ChatModel> get chats => _chats;
  List<MessageModel> get messages => _messages;
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
      final chatsJson = await ApiService.getChats();
      _chats = chatsJson.map((c) => ChatModel.fromJson(c)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ChatModel?> createChat(String participantId) async {
    try {
      final data = await ApiService.createChat(participantId);
      final chatJson = data['chat'] ?? data;
      final newChat = ChatModel.fromJson(chatJson);
      
      // Add to list if not already present
      final exists = _chats.any((c) => c.id == newChat.id);
      if (!exists) {
        _chats.insert(0, newChat);
        notifyListeners();
      }
      return newChat;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<ChatModel?> createGroupChat({
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
      final chatJson = data['chat'] ?? data;
      final newChat = ChatModel.fromJson(chatJson);
      _chats.insert(0, newChat);
      notifyListeners();
      return newChat;
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
      final msgsJson = await ApiService.getMessages(conversationId, page: page);
      final msgs = msgsJson.map((m) => MessageModel.fromJson(m)).toList();
      
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

  void sendMessage({
    required BuildContext context, // Added context to get userId
    required String conversationId,
    required String text,
    String type = 'text',
    String? mediaUrl,
    String? replyTo,
    int? duration,
  }) {
    final auth = context.read<AuthProvider>();
    
    // 💡 OPTIMISTIC UPDATE: Add to local list immediately
    final tempMsg = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: auth.userId,
      text: text,
      type: MessageType.values.byName(type),
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      isMe: true,
      mediaUrl: mediaUrl,
      duration: duration,
    );
    
    _messages.add(tempMsg);
    notifyListeners();

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
      final updatedJson = data['message'] ?? data;
      final updated = MessageModel.fromJson(updatedJson);
      final idx = _messages.indexWhere((m) => m.id == messageId);
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
      _messages.removeWhere((m) => m.id == messageId);
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
      _messages.add(MessageModel.fromJson(data));
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
      final statusStr = data['status'];
      final messageId = data['messageId'];
      final status = MessageStatus.values.byName(statusStr);
      
      if (messageId != null) {
        final idx = _messages.indexWhere((m) => m.id == messageId);
        if (idx != -1) {
          _messages[idx] = _messages[idx].copyWith(status: status);
          notifyListeners();
        }
      } else {
        // Bulk update for room
        for (var i = 0; i < _messages.length; i++) {
          if (_messages[i].status != MessageStatus.read) {
            _messages[i] = _messages[i].copyWith(status: status);
          }
        }
        notifyListeners();
      }
    });

    // Listen for room-wide read receipts
    SocketService.instance.onMessageRead((data) {
      for (var i = 0; i < _messages.length; i++) {
        _messages[i] = _messages[i].copyWith(status: MessageStatus.read);
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
