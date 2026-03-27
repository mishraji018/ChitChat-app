import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/glass_widgets.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../utils/notification_handler.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

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
                subtitle: 'Play sounds for incoming and outgoing messages.',
                value: settings.conversationTones,
                onChanged: (val) => notifier.updateConversationTones(val),
                colorScheme: colorScheme,
              ),
            ),
            
            const GlassSectionHeader(title: 'Messages'),
            GlassCard(
              isDark: isDark,
              child: Column(children: [
                _buildToneTile(context, ref, 'Notification tone', settings.messageTone, colorScheme, isDark, true, (val) => notifier.updateMessageTone(val)),
                const Divider(height: 1),
                _buildVibrateTile(context, ref, 'Vibrate', settings.messageVibrate, colorScheme, isDark, (val) => notifier.updateMessageVibrate(val)),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: 'High priority',
                  subtitle: 'Show previews of notifications at the top of the screen.',
                  value: settings.messageHighPriority,
                  onChanged: (val) => notifier.updateMessageHighPriority(val),
                  colorScheme: colorScheme,
                ),
              ]),
            ),
            
            const GlassSectionHeader(title: 'Groups'),
            GlassCard(
              isDark: isDark,
              child: Column(children: [
                _buildToneTile(context, ref, 'Notification tone', settings.groupTone, colorScheme, isDark, true, (val) => notifier.updateGroupTone(val)),
                const Divider(height: 1),
                _buildVibrateTile(context, ref, 'Vibrate', settings.groupVibrate, colorScheme, isDark, (val) => notifier.updateGroupVibrate(val)),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: 'High priority',
                  subtitle: 'Show previews of notifications at the top of the screen.',
                  value: settings.groupHighPriority,
                  onChanged: (val) => notifier.updateGroupHighPriority(val),
                  colorScheme: colorScheme,
                ),
              ]),
            ),
            
            const GlassSectionHeader(title: 'Calls'),
            GlassCard(
              isDark: isDark,
              child: Column(children: [
                _buildToneTile(context, ref, 'Ringtone', settings.callRingtone, colorScheme, isDark, false, (val) => notifier.updateCallRingtone(val)),
                const Divider(height: 1),
                _buildVibrateTile(context, ref, 'Vibrate', settings.callVibrate, colorScheme, isDark, (val) => notifier.updateCallVibrate(val)),
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
      activeThumbColor: colorScheme.primary,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildVibrateTile(BuildContext context, WidgetRef ref, String title, String currentValue, ColorScheme colorScheme, bool isDark, Function(String) onSelected) {
    return GlassTile(
      isDark: isDark,
      icon: Icons.vibration,
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
                    ...['Default', 'Always', 'Never'].map((option) {
                      return RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: currentValue,
                        activeColor: colorScheme.primary,
                        onChanged: (value) {
                          if (value != null) {
                            onSelected(value);
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

  Widget _buildToneTile(BuildContext context, WidgetRef ref, String title, String currentValue, ColorScheme colorScheme, bool isDark, bool isNotification, Function(String) onSelected) {
    final List<String> defaultTones = isNotification 
      ? ['Chime', 'Bell', 'Ping', 'Droplet', 'None']
      : ['Classic Ring', 'Marimba', 'Digital', 'Acoustic', 'None'];

    return GlassTile(
      isDark: isDark,
      icon: isNotification ? Icons.notifications_none_rounded : Icons.library_music_outlined,
      iconColor: colorScheme.primary,
      title: title,
      subtitle: currentValue,
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return GlassCard(
                  isDark: isDark,
                  radius: 20,
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isNotification ? 'Notification Tone' : 'Ringtone', 
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, child) {
                            return ListView(
                              controller: scrollController,
                              children: [
                                ...defaultTones.map((tone) {
                                  return RadioListTile<String>(
                                    title: Text(tone),
                                    value: tone,
                                    groupValue: currentValue,
                                    activeColor: colorScheme.primary,
                                    onChanged: (value) async {
                                      if (value != null) {
                                        if (isNotification) {
                                          playNotificationSound(value);
                                        } else {
                                          playRingtone(value);
                                        }
                                        onSelected(value);
                                        await Future.delayed(const Duration(milliseconds: 500));
                                        if (context.mounted) Navigator.pop(context);
                                      }
                                    },
                                  );
                                }),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.folder_open),
                                  title: const Text('From Device...'),
                                  onTap: () {
                                    // Normally we would use android_intent or flutter_ringtone_player picker logic here
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Opening device picker...')),
                                    );
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          }
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
