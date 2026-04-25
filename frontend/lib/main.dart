import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'providers/v3/auth_provider.dart';
import 'providers/v3/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  
  await Hive.initFlutter();
  
  // Initialize AuthProvider
  final auth = AuthProvider();
  await auth.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const ChitChatApp(),
    ),
  );
}
