import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';

class ChitChatApp extends ConsumerWidget {
  const ChitChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeModeStr = ref.watch(themeProvider);

    ThemeData? theme;
    ThemeMode mode = ThemeMode.system;

    switch (themeModeStr) {
      case AppThemeMode.light:
        mode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        mode = ThemeMode.dark;
        break;
      case AppThemeMode.ocean:
        theme = AppTheme.oceanTheme;
        mode = ThemeMode.dark; // Override to use custom theme logic if needed, but here we provide a full theme
        break;
      case AppThemeMode.pink:
        theme = AppTheme.pinkTheme;
        mode = ThemeMode.light;
        break;
      case AppThemeMode.system:
        mode = ThemeMode.system;
        break;
    }

    return MaterialApp.router(
      title: 'ChitChat',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: theme ?? AppTheme.lightTheme,
      darkTheme: mode == ThemeMode.system ? AppTheme.darkTheme : theme ?? AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
