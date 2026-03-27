import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../../shared/widgets/glass_widgets.dart';

class AppLockVerifyScreen extends ConsumerStatefulWidget {
  const AppLockVerifyScreen({super.key});

  @override
  ConsumerState<AppLockVerifyScreen> createState() => _AppLockVerifyScreenState();
}

class _AppLockVerifyScreenState extends ConsumerState<AppLockVerifyScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometrics();
    });
  }

  Future<void> _checkBiometrics() async {
    final biometricsEnabled = ref.read(appBiometricsEnabledProvider);
    if (!biometricsEnabled) return;

    try {
      setState(() => _isChecking = true);
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to unlock ChitChat',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuthenticate) {
        _unlock();
      }
    } catch (_) {
      // Fallback to PIN gracefully
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _unlock() {
    ref.read(isAppUnlockedProvider.notifier).state = true;
    context.go('/home/chats');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final savedPin = ref.watch(appPinProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        isDark: isDark,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Lock Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.tertiary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lock_person_rounded, size: 54, color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'ChitChat Locked',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your privacy is our priority',
                    style: TextStyle(
                      color: colorScheme.secondary.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Glass PIN Card
                  GlassCard(
                    isDark: isDark,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Text(
                          'ENTER CHIT CHAT PIN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: colorScheme.secondary.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Pinput(
                          length: 4,
                          obscureText: true,
                          autofocus: true,
                          onCompleted: (pin) {
                            if (pin == savedPin) {
                              _unlock();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('❌ Incorrect PIN'),
                                  backgroundColor: colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          },
                          defaultPinTheme: PinTheme(
                            width: 60,
                            height: 60,
                            textStyle: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.03),
                              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2), width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 60,
                            height: 60,
                            textStyle: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              border: Border.all(color: colorScheme.primary, width: 2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (ref.watch(appBiometricsEnabledProvider))
                    TextButton.icon(
                      onPressed: _isChecking ? null : _checkBiometrics,
                      icon: Icon(Icons.fingerprint_rounded, size: 32, color: colorScheme.primary),
                      label: Text(
                        'Unlock with Biometrics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
