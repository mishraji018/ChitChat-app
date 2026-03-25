import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasskeyScreen extends StatelessWidget {
  const ForgotPasskeyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text(
          'Forgot Passkey Screen\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 18),
        ),
      ),
    );
  }
}
