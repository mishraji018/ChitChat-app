import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/models/chat_model.dart';
import '../../../../shared/widgets/glass_widgets.dart';
import 'dart:ui';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    final selected = ref.read(selectedChatsProvider);
    final newSelected = Set<String>.from(selected);
    
    if (newSelected.contains(id)) {
      newSelected.remove(id);
      if (newSelected.isEmpty) {
        ref.read(isSelectionModeProvider.notifier).state = false;
      }
    } else {
      newSelected.add(id);
    }
    
    ref.read(selectedChatsProvider.notifier).state = newSelected;
  }

  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(filteredChatListProvider);
    final isSearchExpanded = ref.watch(isSearchExpandedProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        isDark: isDark,
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 20),
            if (isSearchExpanded) _buildSearchBar(theme, colorScheme, isDark),
            _buildFilterChips(theme, colorScheme, isDark),
            Expanded(
              child: chats.isEmpty
                  ? _buildEmptyState(colorScheme)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      children: [
                        GlassCard(
                          isDark: isDark,
                          padding: EdgeInsets.zero,
                          radius: 28,
                          child: Column(
                            children: List.generate(chats.length, (index) {
                              final chat = chats[index];
                              return Column(
                                children: [
                                  _buildChatTile(chat, theme, colorScheme, isDark),
                                  if (index < chats.length - 1)
                                    Divider(
                                      height: 1,
                                      indent: 84,
                                      endIndent: 16,
                                      color: isDark 
                                          ? Colors.white.withValues(alpha: 0.05) 
                                          : Colors.black.withValues(alpha: 0.03),
                                    ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/new-chat'),
        backgroundColor: colorScheme.primary,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Icon(Icons.add_rounded, color: colorScheme.onPrimary, size: 32),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, ColorScheme colorScheme, bool isDark) {
    final selectedFilter = ref.watch(selectedFilterProvider);
    final filters = ['All', 'Unread', 'Pinned', 'Archived'];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;

          return Center(
            child: GestureDetector(
              onTap: () {
                ref.read(selectedFilterProvider.notifier).state = filter;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        isDark: isDark,
        padding: EdgeInsets.zero,
        radius: 30,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: colorScheme.onSurface),
            onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
            decoration: InputDecoration(
              hintText: "Search chats...",
              hintStyle: TextStyle(color: colorScheme.secondary.withValues(alpha: 0.5)),
              prefixIcon: Icon(Icons.search, color: colorScheme.primary),
              suffixIcon: IconButton(
                icon: Icon(Icons.close, color: colorScheme.secondary.withValues(alpha: 0.5)),
                onPressed: () {
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                  ref.read(isSearchExpandedProvider.notifier).state = false;
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, color: colorScheme.primary, size: 80),
          const SizedBox(height: 16),
          Text('No chats yet', style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Tap + to start a new conversation', style: TextStyle(color: colorScheme.secondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildChatTile(ChatModel chat, ThemeData theme, ColorScheme colorScheme, bool isDark) {
    final isSelectionMode = ref.watch(isSelectionModeProvider);
    final selectedChats = ref.watch(selectedChatsProvider);
    final isSelected = selectedChats.contains(chat.id);

    return Slidable(
      key: ValueKey(chat.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => ref.read(chatListProvider.notifier).archiveChat(chat.id),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: 'Archive',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => ref.read(chatListProvider.notifier).deleteChat(chat.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (isSelectionMode) {
            _toggleSelection(chat.id);
          } else {
            context.push('/chat/${chat.id}');
          }
        },
        child: Container(
          height: 84,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: isSelected ? colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          child: Row(
            children: [
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? colorScheme.primary : colorScheme.secondary.withValues(alpha: 0.4),
                  ),
                ),
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.tertiary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (chat.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? const Color(0xff0D0D1A) : Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (chat.isPinned)
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Icon(Icons.push_pin, color: colorScheme.primary.withValues(alpha: 0.6), size: 14),
                          ),
                        Expanded(
                          child: Text(
                            chat.name,
                            style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          chat.timestamp,
                          style: TextStyle(
                            color: chat.unreadCount > 0 ? colorScheme.primary : colorScheme.secondary.withValues(alpha: 0.4),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (chat.messageStatus.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: _buildMessageStatusIcon(chat.messageStatus, colorScheme),
                          ),
                        Expanded(
                          child: Text(
                            chat.lastMessage,
                            style: TextStyle(color: colorScheme.secondary.withValues(alpha: 0.8), fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (chat.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                            decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(10)),
                            alignment: Alignment.center,
                            child: Text(
                              '${chat.unreadCount}',
                              style: TextStyle(color: colorScheme.onPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageStatusIcon(String status, ColorScheme colorScheme) {
    IconData iconData;
    Color color = colorScheme.secondary.withValues(alpha: 0.4);
    switch (status) {
      case 'sent': iconData = Icons.check; break;
      case 'delivered': iconData = Icons.done_all; break;
      case 'read': iconData = Icons.done_all; color = Colors.blue; break;
      default: return const SizedBox.shrink();
    }
    return Icon(iconData, size: 16, color: color);
  }
}
