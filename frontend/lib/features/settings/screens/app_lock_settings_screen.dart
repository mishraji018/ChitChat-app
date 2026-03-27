import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:local_auth/local_auth.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../../shared/widgets/glass_widgets.dart';

class AppLockSettingsScreen extends ConsumerStatefulWidget {
  const AppLockSettingsScreen({super.key});

  @override
  ConsumerState<AppLockSettingsScreen> createState() => _AppLockSettingsScreenState();
}

class _AppLockSettingsScreenState extends ConsumerState<AppLockSettingsScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();
      setState(() {
        _canCheckBiometrics = canCheck || isDeviceSupported;
      });
    } catch (_) {
      setState(() => _canCheckBiometrics = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final appLockEnabled = ref.watch(appLockEnabledProvider);
    final biometricsEnabled = ref.watch(appBiometricsEnabledProvider);
    final hasPin = ref.watch(appPinProvider).isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: glassAppBar(title: 'App Lock', isDark: isDark),
      body: GlassBackground(
        isDark: isDark,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              // Hero lock icon tile
              Center(
                child: GlassCard(
                  isDark: isDark,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [colorScheme.primary, colorScheme.tertiary],
                          ),
                          boxShadow: [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 4)],
                        ),
                        child: Icon(appLockEnabled ? Icons.lock_rounded : Icons.lock_open_rounded, size: 44, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        appLockEnabled ? 'App Lock is ON' : 'App Lock is OFF',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Protect your chats with a PIN or fingerprint.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: colorScheme.secondary),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Toggle Card
              GlassCard(
                isDark: isDark,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: GlassIconBadge(icon: Icons.pin_outlined, color: colorScheme.primary, isDark: isDark),
                  title: Text('Enable App Lock', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                  subtitle: Text('Require PIN to open ChitChat', style: TextStyle(color: colorScheme.secondary, fontSize: 12)),
                  value: appLockEnabled,
                  activeThumbColor: colorScheme.primary,
                  onChanged: (val) {
                    if (val && !hasPin) {
                      _showPinSheet(context, ref, colorScheme, isDark);
                    } else {
                      ref.read(settingsProvider.notifier).setBool('app_lock_enabled', val);
                    }
                  },
                ),
              ),

              if (appLockEnabled) ...[
                const SizedBox(height: 12),

                // Change PIN card
                GlassCard(
                  isDark: isDark,
                  onTap: () => _showPinSheet(context, ref, colorScheme, isDark, isChanging: true),
                  child: Row(
                    children: [
                      GlassIconBadge(icon: Icons.dialpad_rounded, color: colorScheme.tertiary, isDark: isDark),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Change PIN', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                            Text('Update your 4-digit code', style: TextStyle(color: colorScheme.secondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: colorScheme.secondary),
                    ],
                  ),
                ),

                if (_canCheckBiometrics) ...[
                  const SizedBox(height: 12),

                  // Biometric card
                  GlassCard(
                    isDark: isDark,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: GlassIconBadge(icon: Icons.fingerprint_rounded, color: Colors.green, isDark: isDark),
                      title: Text('Fingerprint Unlock', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                      subtitle: Text('Use biometrics as fallback', style: TextStyle(color: colorScheme.secondary, fontSize: 12)),
                      value: biometricsEnabled,
                      activeThumbColor: Colors.green,
                      onChanged: (val) {
                        ref.read(settingsProvider.notifier).setBool('app_biometrics_enabled', val);
                      },
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 24),

              // Info chip
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 14, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text('PIN is stored securely on this device', style: TextStyle(fontSize: 12, color: colorScheme.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPinSheet(BuildContext context, WidgetRef ref, ColorScheme colorScheme, bool isDark, {bool isChanging = false}) {
    final currentPin = ref.read(appPinProvider);
    bool isAskingOld = isChanging;
    bool hasError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  left: 24, right: 24, top: 32,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.7),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 40, height: 4, decoration: BoxDecoration(color: colorScheme.secondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 24),
                      Icon(
                        isAskingOld ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isAskingOld ? 'Enter Current PIN' : (isChanging ? 'Enter New PIN' : 'Create PIN'),
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                      if (hasError) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: colorScheme.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text('Incorrect PIN. Try again.', style: TextStyle(color: colorScheme.error, fontSize: 13)),
                        ),
                      ],
                      const SizedBox(height: 28),
                      Pinput(
                        key: ValueKey(isAskingOld),
                        length: 4,
                        obscureText: true,
                        autofocus: true,
                        showCursor: true,
                        onCompleted: (pin) {
                          if (isAskingOld) {
                            if (pin == currentPin) {
                              setSheetState(() { isAskingOld = false; hasError = false; });
                            } else {
                              setSheetState(() => hasError = true);
                            }
                          } else {
                            ref.read(settingsProvider.notifier).setString('app_pin', pin);
                            ref.read(settingsProvider.notifier).setBool('app_lock_enabled', true);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('✅ PIN saved securely on this device'),
                                backgroundColor: colorScheme.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        },
                        defaultPinTheme: PinTheme(
                          width: 60,
                          height: 60,
                          textStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.4), width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 60,
                          height: 60,
                          textStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            border: Border.all(color: colorScheme.primary, width: 2),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 1)],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
