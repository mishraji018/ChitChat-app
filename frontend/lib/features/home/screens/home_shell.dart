import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/router/app_router.dart';

class HomeShell extends ConsumerStatefulWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> with WidgetsBindingObserver {
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;
      if (userId != null) {
        // Store userId in settings so setString(app_pin) can use it
        ref.read(settingsProvider.notifier).setCurrentUserId(userId);
        await ref.read(settingsProvider.notifier).loadSecurePinForUser(userId);
      }
      ref.read(settingsProvider.notifier).syncSettingsFromBackend();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // On resume, if app lock is enabled relock by resetting isAppUnlocked
    if (state == AppLifecycleState.resumed) {
      final appLockEnabled = ref.read(appLockEnabledProvider);
      if (appLockEnabled) {
        ref.read(isAppUnlockedProvider.notifier).state = false;
        if (mounted) context.go('/app-lock-verify');
      }
      if (_wasOffline) {
        _wasOffline = false;
        // Relock on coming back online
        if (appLockEnabled) {
          ref.read(isAppUnlockedProvider.notifier).state = false;
          if (mounted) context.go('/app-lock-verify');
        }
      }
    } else if (state == AppLifecycleState.paused) {
      _wasOffline = true;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home/chats');
        break;
      case 1:
        context.go('/home/calls');
        break;
      case 2:
        context.go('/home/contacts');
        break;
      case 3:
        context.go('/home/settings');
        break;
    }
  }

  void _exitSelectionMode() {
    ref.read(isSelectionModeProvider.notifier).state = false;
    ref.read(selectedChatsProvider.notifier).state = {};
  }

  void _bulkArchive() {
    final notifier = ref.read(chatListProvider.notifier);
    final selected = ref.read(selectedChatsProvider);
    for (final id in selected) {
      notifier.archiveChat(id);
    }
    _exitSelectionMode();
  }

  void _bulkDelete() {
    final notifier = ref.read(chatListProvider.notifier);
    final selected = ref.read(selectedChatsProvider);
    for (final id in selected) {
      notifier.deleteChat(id);
    }
    _exitSelectionMode();
  }

  void _bulkPin() {
    final notifier = ref.read(chatListProvider.notifier);
    final selected = ref.read(selectedChatsProvider);
    for (final id in selected) {
      notifier.pinChat(id);
    }
    _exitSelectionMode();
  }

  void _bulkMute() {
    final notifier = ref.read(chatListProvider.notifier);
    final selected = ref.read(selectedChatsProvider);
    for (final id in selected) {
      notifier.muteChat(id);
    }
    _exitSelectionMode();
  }

  @override
  Widget build(BuildContext context) {
    // Verification log as requested
    final brightness = MediaQuery.of(context).platformBrightness;
    debugPrint('Device brightness: $brightness');

    final location = GoRouterState.of(context).uri.path;
    int selectedIndex = 0;
    if (location.startsWith('/home/calls')) {
      selectedIndex = 1;
    } else if (location.startsWith('/home/contacts')) selectedIndex = 2;
    else if (location.startsWith('/home/settings')) selectedIndex = 3;
    final isSelectionMode = ref.watch(isSelectionModeProvider);
    final selectedChatsCount = ref.watch(selectedChatsProvider).length;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent, // Let GlassBackground handle it
      appBar: isSelectionMode
          ? AppBar(
              backgroundColor: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.55),
              elevation: 0,
              flexibleSpace: ClipRect(
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(color: Colors.transparent)),
              ),
              leading: IconButton(
                icon: Icon(Icons.close, color: colorScheme.onSurface),
                onPressed: _exitSelectionMode,
              ),
              title: Text('$selectedChatsCount', style: TextStyle(color: colorScheme.onSurface)),
              actions: [
                IconButton(icon: Icon(Icons.push_pin_outlined, color: colorScheme.onSurface), onPressed: _bulkPin),
                IconButton(icon: Icon(Icons.volume_off_outlined, color: colorScheme.onSurface), onPressed: _bulkMute),
                IconButton(icon: Icon(Icons.archive_outlined, color: colorScheme.onSurface), onPressed: _bulkArchive),
                IconButton(icon: Icon(Icons.delete_outline, color: colorScheme.onSurface), onPressed: _bulkDelete),
              ],
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: AppBar(
                    title: Row(
                      children: [
                        const Text('🐻', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text('ChitChat',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            )),
                      ],
                    ),
                    backgroundColor: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.55),
                    elevation: 0,
                    actions: selectedIndex == 0 ? [
                      IconButton(
                        icon: Icon(Icons.search, color: colorScheme.primary),
                        onPressed: () {
                          final current = ref.read(isSearchExpandedProvider);
                          ref.read(isSearchExpandedProvider.notifier).state = !current;
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: colorScheme.primary),
                        color: isDark ? const Color(0xFF121212) : colorScheme.surface,
                        onSelected: (value) {
                          switch (value) {
                            case 'new_group':
                              context.push('/new-group');
                              break;
                            case 'new_broadcast':
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Broadcast coming soon!'), backgroundColor: Colors.orange),
                              );
                              break;
                            case 'linked_devices':
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Linked Devices coming soon!'), backgroundColor: Colors.orange),
                              );
                              break;
                            case 'starred_messages':
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Starred Messages coming soon!'), backgroundColor: Colors.orange),
                              );
                              break;
                            case 'settings':
                              context.go('/home/settings');
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem(value: 'new_group', child: Text('New Group', style: TextStyle(color: colorScheme.onSurface))),
                          PopupMenuItem(value: 'new_broadcast', child: Text('New Broadcast', style: TextStyle(color: colorScheme.onSurface))),
                          PopupMenuItem(value: 'linked_devices', child: Text('Linked Devices', style: TextStyle(color: colorScheme.onSurface))),
                          PopupMenuItem(value: 'starred_messages', child: Text('Starred Messages', style: TextStyle(color: colorScheme.onSurface))),
                          PopupMenuItem(value: 'settings', child: Text('Settings', style: TextStyle(color: colorScheme.onSurface))),
                        ],
                      ),
                    ] : [],
                  ),
                ),
              ),
            ),
      body: widget.child,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.65),
              border: Border(top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.9), width: 0.5)),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.secondary.withValues(alpha: 0.5),
              selectedFontSize: 11,
              unselectedFontSize: 11,
              elevation: 0,
              currentIndex: selectedIndex,
              onTap: (index) => _onItemTapped(index, context),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline, size: 24), activeIcon: Icon(Icons.chat_bubble, size: 26), label: 'Chats'),
                BottomNavigationBarItem(icon: Icon(Icons.phone_outlined, size: 24), activeIcon: Icon(Icons.phone, size: 26), label: 'Calls'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 24), activeIcon: Icon(Icons.person, size: 26), label: 'Contacts'),
                BottomNavigationBarItem(icon: Icon(Icons.settings_outlined, size: 24), activeIcon: Icon(Icons.settings, size: 26), label: 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
