import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/socket_service.dart';

// Track online users
final onlineUsersProvider = StateProvider<Set<String>>((ref) => {});

// Socket initialization provider  
final socketInitProvider = Provider<void>((ref) {
  // Listen for online/offline events
  SocketService.onUserOnline((userId) {
    final current = ref.read(onlineUsersProvider);
    ref.read(onlineUsersProvider.notifier).state = {...current, userId};
  });

  SocketService.onUserOffline((data) {
    final userId = data['userId'] as String;
    final current = ref.read(onlineUsersProvider);
    ref.read(onlineUsersProvider.notifier).state = 
      current.where((id) => id != userId).toSet();
  });
});
