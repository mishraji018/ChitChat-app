import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../models/chat_model.dart';

class ChatNotifier extends StateNotifier<AsyncValue<List<ChatModel>>> {
  ChatNotifier(this._api) : super(const AsyncValue.loading()) {
    loadChats();
  }

  final ApiService _api;

  Future<void> loadChats() async {
    state = const AsyncValue.loading();
    try {
      final chats = await _api.getChats();
      state = AsyncValue.data(chats);
    } catch (_) {
      state = const AsyncValue.data([]);
    }
  }

  // Stubs for actions (Error 5 cleanup)
  void archiveChat(String id) {}
  void deleteChat(String id) {}
  void pinChat(String id) {}
  void muteChat(String id) {}
}

// chatProvider — main provider
final chatProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<List<ChatModel>>>((ref) {
  return ChatNotifier(ref.read(apiServiceProvider));
});

// chatListProvider — alias for home_shell (ERROR 5 FIX)
final chatListProvider = chatProvider;