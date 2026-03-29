import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/calls_provider.dart';
import '../../../core/router/app_router.dart'; // ERROR FIX — For isAppUnlockedProvider

// ERROR 3, 4, 6 FIX — Missing providers
final isSearchExpandedProvider = StateProvider<bool>((ref) => false);

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
    if (state == AppLifecycleState.resumed) {
      final appLockEnabled = ref.read(appLockEnabledProvider);
      if (appLockEnabled) {
        ref.read(isAppUnlockedProvider.notifier).state = false;
        if (mounted) context.go('/app-lock-verify');
      }
      if (_wasOffline) {
        _wasOffline = false;
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
      case 0: context.go('/home/chats'); break;
      case 1: context.go('/home/calls'); break;
      case 2: context.go('/home/contacts'); break;
      case 3: context.go('/home/settings'); break;
    }
  }


  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int selectedIndex = 0;
    if (location.startsWith('/home/calls')) {
      selectedIndex = 1;
    } else if (location.startsWith('/home/contacts')) {
      selectedIndex = 2;
    } else if (location.startsWith('/home/settings')) {
      selectedIndex = 3;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
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
              backgroundColor: isDark
                  ? Colors.black.withOpacity(0.45)
                  : Colors.white.withOpacity(0.55),
              elevation: 0,
              actions: [
                if (selectedIndex != 2 && selectedIndex != 3)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'missed_calls') {
                      ref.read(callFilterProvider.notifier).state = 'Missed';
                      return;
                    }
                    if (value == 'call_settings') {
                      context.push('/notifications');
                      return;
                    }
                    switch (value) {
                      case 'new_group':
                        context.push('/new-group');
                        break;
                      case 'new_broadcast':
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('New Broadcast — Coming Soon 🚀'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                        break;
                      case 'linked_devices':
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Linked Devices — Coming Soon 🚀'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                        break;
                      case 'starred':
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('Starred Messages — Coming Soon 🚀'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                        break;
                      case 'payments':
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Payments — Coming Soon 🚀'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                        break;
                      case 'settings':
                        context.go('/home/settings');
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    if (selectedIndex == 1) {
                      return [
                        PopupMenuItem(
                          value: 'missed_calls',
                          child: Row(children: [
                            Icon(Icons.call_missed,
                                color: Theme.of(context).colorScheme.onSurface),
                            const SizedBox(width: 12),
                            const Text('Missed calls'),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'call_settings',
                          child: Row(children: [
                            Icon(Icons.settings_outlined,
                                color: Theme.of(context).colorScheme.onSurface),
                            const SizedBox(width: 12),
                            const Text('Call settings'),
                          ]),
                        ),
                      ];
                    }
                    return [
                      PopupMenuItem(
                        value: 'new_group',
                        child: Row(children: [
                          Icon(Icons.group_add_outlined,
                              color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: 12),
                          const Text('New group'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'new_broadcast',
                        child: Row(children: [
                          Icon(Icons.campaign_outlined,
                              color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: 12),
                          const Text('New broadcast'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'linked_devices',
                        child: Row(children: [
                          Icon(Icons.devices_outlined,
                              color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: 12),
                          const Text('Linked devices'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'starred',
                        child: Row(children: [
                          Icon(Icons.star_outline_rounded,
                              color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: 12),
                          const Text('Starred messages'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'payments',
                        child: Row(children: [
                          Icon(Icons.payments_outlined,
                              color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: 12),
                          const Text('Payments'),
                        ]),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'settings',
                        child: Row(children: [
                          Icon(Icons.settings_outlined,
                              color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: 12),
                          const Text('Settings'),
                        ]),
                      ),
                    ];
                  },
                ),
              ],
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
              color: isDark ? Colors.white.withOpacity(0.07) : Colors.white.withOpacity(0.65),
              border: Border(top: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9), width: 0.5)),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.secondary.withOpacity(0.5),
              elevation: 0,
              currentIndex: selectedIndex,
              onTap: (index) => _onItemTapped(index, context),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
                BottomNavigationBarItem(icon: Icon(Icons.phone_outlined), label: 'Calls'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Contacts'),
                BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
