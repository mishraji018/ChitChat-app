import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';

class MessageNotifier extends StateNotifier<List<MessageModel>> {
  MessageNotifier() : super(_dummyMessages);

  void sendMessage(MessageModel message) {
    state = [message, ...state];
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

  void forwardMessage(String id) {
    // Logic for forwarding
  }
}

final messagesProvider = StateNotifierProvider<MessageNotifier, List<MessageModel>>((ref) {
  return MessageNotifier();
});

final isTypingProvider = StateProvider<bool>((ref) => false);
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
