import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../../shared/widgets/glass_widgets.dart';

final blockedUsersProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getBlockedUsers();
});

class BlockedContactsScreen extends ConsumerWidget {
  const BlockedContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final blockedUsers = ref.watch(blockedUsersProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: glassAppBar(title: 'Blocked Contacts', isDark: isDark),
      body: GlassBackground(
        isDark: isDark,
        child: SafeArea(
          child: blockedUsers.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (users) {
              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.block, size: 80, color: colorScheme.secondary.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Text(
                        'No blocked contacts',
                        style: TextStyle(color: colorScheme.secondary, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return GlassCard(
                    isDark: isDark,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(user['avatar'] ?? 'https://cdn-icons-png.flaticon.com/512/149/149071.png'),
                      ),
                      title: Text(user['name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(user['status'] ?? 'Hey there!', style: const TextStyle(fontSize: 12)),
                      trailing: TextButton(
                        onPressed: () async {
                          await ref.read(apiServiceProvider).unblockUser(user['_id']);
                          ref.invalidate(blockedUsersProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User unblocked')),
                            );
                          }
                        },
                        child: const Text('UNBLOCK'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
