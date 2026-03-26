import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../../core/services/socket_service.dart';

class MessageNotifier extends StateNotifier<List<MessageModel>> {
  final String conversationId;
  final String currentUserId;

  MessageNotifier({
    required this.conversationId,
    required this.currentUserId,
  }) : super([]) {
    _initSocket();
    _loadDummyMessages();
  }

  void _initSocket() {
    // Listen for new messages
    SocketService.onNewMessage((data) {
      final message = MessageModel.fromJson(data);
      if (message.id.isNotEmpty && !state.any((m) => m.id == message.id)) {
        state = [message, ...state];
        // Mark as delivered
        SocketService.messageDelivered(message.id);
      }
    });

    // Listen for message status updates
    SocketService.onMessageStatus((data) {
      final messageId = data['messageId'] as String;
      final status = data['status'] as String;
      state = state.map((m) {
        if (m.id == messageId) {
          return m.copyWith(
            status: MessageStatus.values.firstWhere(
              (s) => s.name == status,
              orElse: () => m.status,
            ),
          );
        }
        return m;
      }).toList();
    });

    // Listen for edited messages
    SocketService.onMessageEdited((data) {
      final updatedMessage = MessageModel.fromJson(data);
      state = state.map((m) {
        if (m.id == updatedMessage.id) return updatedMessage;
        return m;
      }).toList();
    });

    // Listen for deleted messages
    SocketService.onMessageDeleted((data) {
      final messageId = data['messageId'] as String;
      final forEveryone = data['forEveryone'] as bool;
      if (forEveryone) {
        state = state.map((m) {
          if (m.id == messageId) return m.copyWith(isDeleted: true, text: 'Message deleted');
          return m;
        }).toList();
      }
    });
  }

  void _loadDummyMessages() {
    state = _dummyMessages;
  }

  Future<void> sendTextMessage({
    required String text,
    required String receiverId,
    MessageModel? replyTo,
  }) async {
    // Add optimistic message immediately
    final tempMessage = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUserId,
      text: text,
      type: MessageType.text,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      isMe: true,
      replyTo: replyTo,
      reactions: {},
      isStarred: false,
      isEdited: false,
      isDeleted: false,
    );

    state = [tempMessage, ...state];

    // Send via socket
    SocketService.sendMessage(
      conversationId: conversationId,
      receiverId: receiverId,
      type: 'text',
      text: text,
      replyToId: replyTo?.id,
    );
  }

  void sendTyping() {
    SocketService.startTyping(conversationId);
  }

  void stopTyping() {
    SocketService.stopTyping(conversationId);
  }

  void markAsRead() {
    SocketService.messageRead(conversationId);
  }

  void deleteMessage(String id, bool forEveryone) {
    state = state.map((m) {
      if (m.id == id) {
        return m.copyWith(isDeleted: true, text: forEveryone ? 'Message deleted' : m.text);
      }
      return m;
    }).toList();
  }

  void editMessage(String id, String newText) {
    state = state.map((m) {
      if (m.id == id) {
        return m.copyWith(isEdited: true, text: newText);
      }
      return m;
    }).toList();
  }

  void addReaction(String messageId, String emoji) {
    state = state.map((m) {
      if (m.id == messageId) {
        final newReactions = Map<String, List<String>>.from(m.reactions);
        if (newReactions.containsKey(emoji)) {
          newReactions[emoji] = [...newReactions[emoji]!, 'me'];
        } else {
          newReactions[emoji] = ['me'];
        }
        return m.copyWith(reactions: newReactions);
      }
      return m;
    }).toList();
  }

  void starMessage(String id) {
    state = state.map((m) {
      if (m.id == id) {
        return m.copyWith(isStarred: !m.isStarred);
      }
      return m;
    }).toList();
  }

  @override
  void dispose() {
    SocketService.off('new_message');
    SocketService.off('message_status');
    SocketService.off('message_edited');
    SocketService.off('message_deleted');
    super.dispose();
  }
}

// Provider factory
final messageProvider = StateNotifierProvider.family<MessageNotifier, List<MessageModel>, String>(
  (ref, conversationId) => MessageNotifier(
    conversationId: conversationId,
    currentUserId: 'me', // Dummy user ID for now
  ),
);

final isTypingProvider = StateProvider.family<bool, String>((ref, id) => false);
final replyToMessageProvider = StateProvider<MessageModel?>((ref) => null);
final isRecordingProvider = StateProvider<bool>((ref) => false);
final showScrollToBottomProvider = StateProvider<bool>((ref) => false);

final List<MessageModel> _dummyMessages = [
  MessageModel(
    id: '12',
    senderId: 'me',
    text: 'Meeting_Notes.pdf',
    type: MessageType.pdf,
    timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    status: MessageStatus.read,
    isMe: true,
    mediaUrl: 'meeting_notes.pdf',
  ),
  MessageModel(
    id: '11',
    senderId: 'contact',
    text: 'Perfect! Main aa raha hoon 🏃',
    type: MessageType.text,
    timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    status: MessageStatus.read,
    isMe: false,
  ),
  MessageModel(
    id: '10',
    senderId: 'me',
    text: 'Bhopal, MP',
    type: MessageType.location,
    timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    status: MessageStatus.read,
    isMe: true,
    mediaUrl: 'https://maps.google.com/?q=23.2599,77.4126',
  ),
  MessageModel(
    id: '9',
    senderId: 'contact',
    text: 'Theek hai, shaam ko milte hain! 👍',
    type: MessageType.text,
    timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    status: MessageStatus.read,
    isMe: false,
  ),
  MessageModel(
    id: '8',
    senderId: 'me',
    text: 'Ok sunke batata hoon',
    type: MessageType.text,
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    status: MessageStatus.sent,
    isMe: true,
  ),
  MessageModel(
    id: '7',
    senderId: 'contact',
    type: MessageType.voice,
    timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
    status: MessageStatus.read,
    isMe: false,
    duration: 12,
  ),
  MessageModel(
    id: '6',
    senderId: 'me',
    text: 'Waah! Bahut sahi photo hai 😍',
    type: MessageType.text,
    timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
    status: MessageStatus.delivered,
    isMe: true,
  ),
  MessageModel(
    id: '5',
    senderId: 'contact',
    type: MessageType.image,
    timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    status: MessageStatus.read,
    isMe: false,
    mediaUrl: 'https://picsum.photos/400/300',
  ),
  MessageModel(
    id: '4',
    senderId: 'me',
    text: 'Soch raha hoon movie dekhne jaayein 🎬',
    type: MessageType.text,
    timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
    status: MessageStatus.read,
    isMe: true,
  ),
  MessageModel(
    id: '3',
    senderId: 'contact',
    text: 'Kal ka plan kya hai?',
    type: MessageType.text,
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    status: MessageStatus.read,
    isMe: false,
  ),
  MessageModel(
    id: '2',
    senderId: 'me',
    text: 'Bilkul sahi hoon bhai! Tu bata?',
    type: MessageType.text,
    timestamp: DateTime.now().subtract(const Duration(minutes: 11)),
    status: MessageStatus.read,
    isMe: true,
  ),
  MessageModel(
    id: '1',
    senderId: 'contact',
    text: 'Hey! Kya haal hai? 😊',
    type: MessageType.text,
    timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    status: MessageStatus.read,
    isMe: false,
  ),
];
