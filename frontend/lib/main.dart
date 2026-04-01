import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart' as legacy; // Using alias to avoid conflict with Riverpod's Provider
import 'app.dart';
import 'core/services/notification_service.dart';
import 'providers/v3/auth_provider.dart';
import 'providers/v3/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  
  await Hive.initFlutter();
  
  // Initialize AuthProvider
  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(
    ProviderScope(
      child: legacy.MultiProvider(
        providers: [
          legacy.ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          legacy.ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: const ChitChatApp(),
      ),
    ),
  );
}
