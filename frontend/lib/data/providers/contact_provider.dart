import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/user_repository.dart';
import '../repositories/chat_repository.dart';
import '../../core/services/api_service.dart';

final userRepositoryProvider = Provider((ref) => UserRepository(ref.watch(apiServiceProvider)));
final chatRepositoryProvider = Provider((ref) => ChatRepository(ref.watch(apiServiceProvider)));

class ContactState {
  final bool isLoading;
  final bool isMuted;
  final bool isBlocked;
  final String? error;

  ContactState({
    this.isLoading = false,
    this.isMuted = false,
    this.isBlocked = false,
    this.error,
  });

  ContactState copyWith({
    bool? isLoading,
    bool? isMuted,
    bool? isBlocked,
    String? error,
  }) {
    return ContactState(
      isLoading: isLoading ?? this.isLoading,
      isMuted: isMuted ?? this.isMuted,
      isBlocked: isBlocked ?? this.isBlocked,
      error: error,
    );
  }
}

class ContactNotifier extends StateNotifier<ContactState> {
  final UserRepository _userRepo;
  final ChatRepository _chatRepo;
  final String userId;
  final String? conversationId;

  ContactNotifier(this._userRepo, this._chatRepo, this.userId, this.conversationId) : super(ContactState()) {
    fetchInitialState();
  }

  Future<void> fetchInitialState() async {
    state = state.copyWith(isLoading: true);
    final result = await _userRepo.getUserById(userId);
    if (result['success']) {
      final userData = result['data'];
      // These fields come from the updated User model in backend
      final isBlocked = (userData['blockedByMe'] == true); 
      final isMuted = (userData['isMuted'] == true);
      state = state.copyWith(
        isLoading: false,
        isBlocked: isBlocked,
        isMuted: isMuted,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleMute() async {
    if (conversationId == null) return;
    state = state.copyWith(isLoading: true);
    final result = state.isMuted 
        ? await _userRepo.unmuteConversation(conversationId!) 
        : await _userRepo.muteConversation(conversationId!);
    
    if (result['success']) {
      state = state.copyWith(isLoading: false, isMuted: !state.isMuted);
    } else {
      state = state.copyWith(isLoading: false, error: result['message']);
    }
  }

  Future<void> toggleBlock() async {
    state = state.copyWith(isLoading: true);
    final result = state.isBlocked 
        ? await _userRepo.unblockUser(userId) 
        : await _userRepo.blockUser(userId);
    
    if (result['success']) {
      state = state.copyWith(isLoading: false, isBlocked: !state.isBlocked);
    } else {
      state = state.copyWith(isLoading: false, error: result['message']);
    }
  }

  Future<bool> clearChat() async {
    if (conversationId == null) return false;
    state = state.copyWith(isLoading: true);
    final result = await _chatRepo.clearChat(conversationId!);
    state = state.copyWith(isLoading: false);
    return result['success'] == true;
  }
}

final contactProvider = StateNotifierProvider.family<ContactNotifier, ContactState, (String, String?)>((ref, params) {
  final userRepo = ref.watch(userRepositoryProvider);
  final chatRepo = ref.watch(chatRepositoryProvider);
  return ContactNotifier(userRepo, chatRepo, params.$1, params.$2);
});
