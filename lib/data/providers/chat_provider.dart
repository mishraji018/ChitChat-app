import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_model.dart';

final selectedFilterProvider = StateProvider<String>((ref) => 'All');
final searchQueryProvider = StateProvider<String>((ref) => '');

// UI State providers for AppBar sharing between HomeShell and ChatListScreen
final isSearchExpandedProvider = StateProvider<bool>((ref) => false);
final isSelectionModeProvider = StateProvider<bool>((ref) => false);
final selectedChatsProvider = StateProvider<Set<String>>((ref) => {});

class ChatListNotifier extends StateNotifier<List<ChatModel>> {
  ChatListNotifier() : super(_initialData);

  static final List<ChatModel> _initialData = [
    ChatModel(id: '1', name: 'Priya Sharma', lastMessage: 'Haan bhai, kal milte hain 😊', timestamp: '2 min ago', unreadCount: 3, isOnline: true, isPinned: false, isMuted: false, isArchived: false, messageStatus: ''),
    ChatModel(id: '2', name: 'Rahul Verma', lastMessage: 'Photo dekhi? Bahut sahi thi!', timestamp: '10 min ago', unreadCount: 0, isOnline: false, isPinned: false, isMuted: false, isArchived: false, messageStatus: 'read'),
    ChatModel(id: '3', name: 'Anjali Singh', lastMessage: 'Meeting 5 baje hai', timestamp: '1 hr ago', unreadCount: 1, isOnline: true, isPinned: false, isMuted: false, isArchived: false, messageStatus: ''),
    ChatModel(id: '4', name: 'Tech Support', lastMessage: 'Your issue has been resolved', timestamp: '2 hr ago', unreadCount: 0, isOnline: false, isPinned: false, isMuted: false, isArchived: false, messageStatus: 'delivered'),
    ChatModel(id: '5', name: 'Vikram Bhai', lastMessage: 'Kab aa raha hai? 🔥', timestamp: 'Yesterday', unreadCount: 7, isOnline: true, isPinned: false, isMuted: false, isArchived: false, messageStatus: ''),
    ChatModel(id: '6', name: 'Mom ❤️', lastMessage: 'Khana kha liya?', timestamp: 'Yesterday', unreadCount: 2, isOnline: false, isPinned: false, isMuted: false, isArchived: false, messageStatus: ''),
    ChatModel(id: '7', name: 'Riya Kapoor', lastMessage: '👍', timestamp: 'Monday', unreadCount: 0, isOnline: false, isPinned: false, isMuted: false, isArchived: false, messageStatus: 'read'),
    ChatModel(id: '8', name: 'Arjun Dev', lastMessage: 'Game khelte hain aaj?', timestamp: 'Sunday', unreadCount: 0, isOnline: true, isPinned: false, isMuted: false, isArchived: false, messageStatus: 'sent'),
    ChatModel(id: '9', name: 'Neha Gupta', lastMessage: 'Thanks bhai!', timestamp: 'Sunday', unreadCount: 0, isOnline: false, isPinned: false, isMuted: false, isArchived: false, messageStatus: 'read'),
    ChatModel(id: '10', name: 'Office Group', lastMessage: 'Kal holiday hai 🎉', timestamp: 'Saturday', unreadCount: 15, isOnline: true, isPinned: false, isMuted: false, isArchived: false, messageStatus: ''),
  ];

  void archiveChat(String id) {
    state = state.map((chat) {
      if (chat.id == id) {
        return chat.copyWith(isArchived: !chat.isArchived);
      }
      return chat;
    }).toList();
  }

  void deleteChat(String id) {
    state = state.where((chat) => chat.id != id).toList();
  }

  void pinChat(String id) {
    state = state.map((chat) {
      if (chat.id == id) {
        return chat.copyWith(isPinned: !chat.isPinned);
      }
      return chat;
    }).toList();
  }

  void muteChat(String id) {
    state = state.map((chat) {
      if (chat.id == id) {
        return chat.copyWith(isMuted: !chat.isMuted);
      }
      return chat;
    }).toList();
  }
}

final chatListProvider = StateNotifierProvider<ChatListNotifier, List<ChatModel>>((ref) {
  return ChatListNotifier();
});

final filteredChatListProvider = Provider<List<ChatModel>>((ref) {
  final chats = ref.watch(chatListProvider);
  final filter = ref.watch(selectedFilterProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  var filtered = chats.where((chat) {
    if (query.isNotEmpty) {
      return chat.name.toLowerCase().contains(query) || chat.lastMessage.toLowerCase().contains(query);
    }
    return true;
  }).toList();

  if (filter == 'Unread') {
    filtered = filtered.where((chat) => chat.unreadCount > 0 && !chat.isArchived).toList();
  } else if (filter == 'Pinned') {
    filtered = filtered.where((chat) => chat.isPinned && !chat.isArchived).toList();
  } else if (filter == 'Archived') {
    filtered = filtered.where((chat) => chat.isArchived).toList();
  } else {
    // Show non-archived for "All"
    filtered = filtered.where((chat) => !chat.isArchived).toList();
  }

  // Ensure pinned chats stay at top
  filtered.sort((a, b) {
    if (a.isPinned && !b.isPinned) return -1;
    if (!a.isPinned && b.isPinned) return 1;
    return 0; // maintain implicit order
  });

  return filtered;
});
