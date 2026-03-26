import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/forgot_passkey_screen.dart';

import '../../features/home/screens/home_shell.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/calls/screens/calls_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/contacts/screens/contacts_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/privacy_screen.dart';
import '../../features/settings/screens/security_screen.dart';
import '../../features/settings/screens/notifications_screen.dart';
import '../../features/chat/screens/new_chat_screen.dart';
import '../../features/chat/screens/new_group_screen.dart';
import '../../features/chat/screens/new_group_info_screen.dart';
import '../../features/chat/screens/contact_profile_screen.dart';
import '../../features/settings/screens/app_lock_settings_screen.dart';
import '../../features/auth/screens/app_lock_verify_screen.dart';


final isAppUnlockedProvider = StateProvider<bool>((ref) => false);

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

// Stable GoRouter provider — does NOT rebuild on state change
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == '/' || path.isEmpty) return '/splash';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/splash',
      ),
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final email = state.extra as String?;
          return OtpScreen(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-passkey',
        name: 'forgot-passkey',
        builder: (context, state) => const ForgotPasskeyScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return HomeShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home/chats',
            name: 'chats',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/home/calls',
            name: 'calls',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const CallsScreen(),
          ),
          GoRoute(
            path: '/home/contacts',
            name: 'contacts',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const ContactsScreen(),
          ),
          GoRoute(
            path: '/home/settings',
            name: 'settings',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const SettingsScreen(),
          ),
        ]
      ),
      GoRoute(
        path: '/chat/:conversationId',
        name: 'chat',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['conversationId'] ?? '';
          return ChatScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/contact-info/:userId',
        name: 'contact-info',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['userId'] ?? '';
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ContactProfileScreen(
            userId: id,
            conversationId: extra['conversationId'],
            name: extra['name'] ?? 'Contact',
            avatar: extra['avatar'] ?? 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
            about: extra['about'] ?? 'Hey there! I am using ChitChat.',
          );
        },
      ),
      GoRoute(
        path: '/new-chat',
        name: 'new-chat',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NewChatScreen(),
      ),
      GoRoute(
        path: '/new-group',
        name: 'new-group',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NewGroupScreen(),
      ),
      GoRoute(
        path: '/new-group-info',
        name: 'new-group-info',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NewGroupInfoScreen(),
      ),
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: '/security',
        name: 'security',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SecurityScreen(),
      ),
      GoRoute(
        path: '/app-lock-settings',
        name: 'app-lock-settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AppLockSettingsScreen(),
      ),
      GoRoute(
        path: '/app-lock-verify',
        name: 'app-lock-verify',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AppLockVerifyScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});
