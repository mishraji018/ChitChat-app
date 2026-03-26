import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../../shared/widgets/glass_widgets.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: glassAppBar(title: 'Notifications', isDark: isDark),
      body: GlassBackground(
        isDark: isDark,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 20, 16, 40),
          children: [
            GlassCard(
              isDark: isDark,
              child: _buildSwitchTile(
                title: 'Conversation tones',
                subtitle: 'Play sounds for messages.',
                value: ref.watch(convTonesProvider),
                onChanged: (val) => ref.read(settingsProvider.notifier).setBool('conv_tones', val),
                colorScheme: colorScheme,
              ),
            ),
            
            const GlassSectionHeader(title: 'Messages'),
            GlassCard(
              isDark: isDark,
              child: Column(children: [
                _buildSelectionTile(context, ref, 'Notification tone', ref.watch(msgToneProvider), 'msg_tone', ['Default', 'Tone 1', 'Tone 2'], colorScheme, isDark),
                const Divider(height: 1),
                _buildSelectionTile(context, ref, 'Vibrate', ref.watch(msgVibrateProvider), 'msg_vibrate', ['Off', 'Default', 'Short', 'Long'], colorScheme, isDark),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: 'High priority',
                  subtitle: 'Show previews at top of screen.',
                  value: ref.watch(msgPriorityProvider),
                  onChanged: (val) => ref.read(settingsProvider.notifier).setBool('msg_priority', val),
                  colorScheme: colorScheme,
                ),
              ]),
            ),
            
            const GlassSectionHeader(title: 'Groups'),
            GlassCard(
              isDark: isDark,
              child: Column(children: [
                _buildSelectionTile(context, ref, 'Notification tone', ref.watch(groupToneProvider), 'group_tone', ['Default', 'Tone 1', 'Tone 2'], colorScheme, isDark),
                const Divider(height: 1),
                _buildSelectionTile(context, ref, 'Vibrate', ref.watch(groupVibrateProvider), 'group_vibrate', ['Off', 'Default', 'Short', 'Long'], colorScheme, isDark),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: 'High priority',
                  subtitle: 'Show previews at top of screen.',
                  value: ref.watch(groupPriorityProvider),
                  onChanged: (val) => ref.read(settingsProvider.notifier).setBool('group_priority', val),
                  colorScheme: colorScheme,
                ),
              ]),
            ),
            
            const GlassSectionHeader(title: 'Calls'),
            GlassCard(
              isDark: isDark,
              child: Column(children: [
                _buildSelectionTile(context, ref, 'Ringtone', ref.watch(callRingtoneProvider), 'call_ringtone', ['Default', 'Ring 1', 'Ring 2'], colorScheme, isDark),
                const Divider(height: 1),
                _buildSelectionTile(context, ref, 'Vibrate', ref.watch(callVibrateProvider), 'call_vibrate', ['Off', 'Default', 'Short', 'Long'], colorScheme, isDark),
              ]),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme colorScheme,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: Text(subtitle, style: TextStyle(color: colorScheme.secondary, fontSize: 13)),
      value: value,
      activeColor: colorScheme.primary,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSelectionTile(BuildContext context, WidgetRef ref, String title, String currentValue, String stateKey, List<String> options, ColorScheme colorScheme, bool isDark) {
    return GlassTile(
      isDark: isDark,
      icon: Icons.notifications_none_rounded,
      iconColor: colorScheme.primary,
      title: title,
      subtitle: currentValue,
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return GlassCard(
              isDark: isDark,
              radius: 0,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...options.map((option) {
                      return RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: currentValue,
                        activeColor: colorScheme.primary,
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(settingsProvider.notifier).setString(stateKey, value);
                            Navigator.pop(context);
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
