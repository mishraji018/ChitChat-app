import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/models/chat_model.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  String _filter = 'All';
  String _search = '';
  final _searchCtrl = TextEditingController();

  final _filters = ['All', 'Unread', 'Pinned', 'Archived'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncChats = ref.watch(chatProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) =>
                          setState(() => _search = v.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Search chats...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.5),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    onPressed: () => context.push('/new-chat'),
                    elevation: 0,
                    child: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
            ),

            // Filter chips
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  final selected = _filter == f;
                  return FilterChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = f),
                    showCheckmark: false,
                  );
                },
              ),
            ),

            // Chat list
            Expanded(
              child: asyncChats.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.wifi_off_rounded, size: 48),
                    const SizedBox(height: 12),
                    const Text('Could not load chats'),
                    TextButton(
                      onPressed: () =>
                          ref.read(chatProvider.notifier).loadChats(),
                      child: const Text('Retry'),
                    ),
                  ]),
                ),
                data: (chats) {
                  // Filter logic
                  List<ChatModel> filtered = chats;

                  if (_filter == 'Unread') {
                    filtered = chats.where((c) => c.unreadCount > 0).toList();
                  }

                  if (_search.isNotEmpty) {
                    filtered = filtered
                        .where((c) => c.name.toLowerCase().contains(_search))
                        .toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('💬', style: theme.textTheme.displayMedium),
                        const SizedBox(height: 12),
                        Text(
                          chats.isEmpty
                              ? 'No chats yet\nStart a new conversation!'
                              : 'No results found',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ]),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(chatProvider.notifier).loadChats(),
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (_, i) => _ChatTile(chat: filtered[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chat Tile ─────────────────────────────────────────────────────

class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Stack(clipBehavior: Clip.none, children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage:
              chat.avatar.isNotEmpty ? NetworkImage(chat.avatar) : null,
          child: chat.avatar.isEmpty
              ? Text(
                  chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                )
              : null,
        ),
        if (chat.isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border:
                    Border.all(color: theme.scaffoldBackgroundColor, width: 2),
              ),
            ),
          ),
      ]),
      title: Row(children: [
        Expanded(
          child: Text(
            chat.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          chat.time,
          style: theme.textTheme.bodySmall?.copyWith(
            color: chat.unreadCount > 0
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ]),
      subtitle: Row(children: [
        Expanded(
          child: Text(
            chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (chat.unreadCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              chat.unreadCount > 99 ? '99+' : '${chat.unreadCount}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
      ]),
      onTap: () => context.push('/chat/${chat.id}'),
    );
  }
}