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
import '../../features/chat/screens/contact_info_screen.dart';
import '../../features/contacts/screens/contacts_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/chat/screens/new_chat_screen.dart';
import '../../features/chat/screens/new_group_screen.dart';
import '../../features/chat/screens/new_group_info_screen.dart';

import '../../core/services/storage_service.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) async {
      final token = await StorageService.getToken();
      final isAuthPath = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/signup' || 
                         state.matchedLocation == '/otp' ||
                         state.matchedLocation == '/forgot-passkey';
      final isSplash = state.matchedLocation == '/splash';

      if (isSplash) return null;

      if (token == null) {
        return isAuthPath ? null : null; // Dev mode: allow all
      }

      if (isAuthPath) {
        return '/home/chats';
      }

      return null;
    },
    routes: [
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
        builder: (context, state) => const ProfileScreen(), // Assuming ProfileScreen in settings_screens doesn't conflict
      ),
      GoRoute(
        path: '/contact-info/:userId',
        name: 'contact-info',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['userId'] ?? '';
          return ContactInfoScreen(userId: id);
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
    ],
  );
});
