import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../../shared/widgets/glass_widgets.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    // Watch providers
    final lastSeen = ref.watch(lastSeenPrivacyProvider);
    final profilePhoto = ref.watch(profilePhotoPrivacyProvider);
    final about = ref.watch(aboutPrivacyProvider);
    final status = ref.watch(statusPrivacyProvider);
    final readReceipts = ref.watch(readReceiptsProvider);
    final silenceCallers = ref.watch(silenceUnknownCallersProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: glassAppBar(title: 'Privacy', isDark: isDark),
      body: GlassBackground(
        isDark: isDark,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 20, 16, 40),
          children: [
            const GlassSectionHeader(title: 'Who can see my personal info'),
            GlassCard(
              isDark: isDark,
              child: Column(children: [
                _buildSelectionTile(context, ref, 'Last seen and online', lastSeen, 'last_seen_privacy', colorScheme, isDark,
                    description: 'If you don\'t share your status, you won\'t see others\'.'),
                const Divider(height: 1),
                _buildSelectionTile(context, ref, 'Profile photo', profilePhoto, 'profile_photo_privacy', colorScheme, isDark),
                const Divider(height: 1),
                _buildSelectionTile(context, ref, 'About', about, 'about_privacy', colorScheme, isDark),
                const Divider(height: 1),
                _buildSelectionTile(context, ref, 'Status', status, 'status_privacy', colorScheme, isDark),
              ]),
            ),
            
            const SizedBox(height: 24),
            GlassCard(
              isDark: isDark,
              child: SwitchListTile(
                title: const Text('Read receipts', style: TextStyle(fontSize: 16)),
                subtitle: Text('If turned off, you won\'t send or receive read receipts.', style: TextStyle(color: colorScheme.secondary, fontSize: 12)),
                value: readReceipts,
                activeColor: colorScheme.primary,
                onChanged: (val) => ref.read(settingsProvider.notifier).setBool('read_receipts', val),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            
            const GlassSectionHeader(title: 'Messaging'),
            GlassCard(
              isDark: isDark,
              child: Column(children: [
                GlassTile(isDark: isDark, icon: Icons.timer_outlined, iconColor: colorScheme.primary, title: 'Default message timer', subtitle: 'Off', onTap: () => _showComingSoon(context, 'Timer')),
                const Divider(height: 1),
                GlassTile(isDark: isDark, icon: Icons.location_on_outlined, iconColor: colorScheme.primary, title: 'Live location', subtitle: 'None', onTap: () => _showComingSoon(context, 'Location')),
              ]),
            ),

            const GlassSectionHeader(title: 'Calls & Security'),
            GlassCard(
              isDark: isDark,
              child: Column(children: [
                SwitchListTile(
                  title: const Text('Silence unknown callers', style: TextStyle(fontSize: 16)),
                  subtitle: Text('Calls from unknown numbers will be silenced.', style: TextStyle(color: colorScheme.secondary, fontSize: 12)),
                  value: silenceCallers,
                  activeColor: colorScheme.primary,
                  onChanged: (val) => ref.read(settingsProvider.notifier).setBool('silence_unknown_callers', val),
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(height: 1),
                GlassTile(isDark: isDark, icon: Icons.block_outlined, iconColor: colorScheme.primary, title: 'Blocked contacts', subtitle: 'None', onTap: () => _showComingSoon(context, 'Blocked')),
                const Divider(height: 1),
                GlassTile(
                  isDark: isDark,
                  icon: Icons.lock_outline,
                  iconColor: colorScheme.primary,
                  title: 'App lock', 
                  subtitle: ref.watch(appLockEnabledProvider) ? 'Enabled' : 'Disabled', 
                  onTap: () => context.pushNamed('app-lock-settings')
                ),
              ]),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature settings coming soon!')));
  }



  Widget _buildSelectionTile(
    BuildContext context, 
    WidgetRef ref, 
    String title, 
    String currentValue, 
    String dbKey,
    ColorScheme colorScheme,
    bool isDark,
    {String? description}
  ) {
    return GlassTile(
      isDark: isDark,
      icon: Icons.privacy_tip_outlined,
      iconColor: colorScheme.primary,
      title: title,
      subtitle: currentValue,
      onTap: () => _showPrivacyBottomSheet(context, ref, title, currentValue, dbKey, colorScheme),
    );
  }



  void _showPrivacyBottomSheet(
    BuildContext context, 
    WidgetRef ref, 
    String title, 
    String currentValue, 
    String dbKey,
    ColorScheme colorScheme
  ) {
    final options = ['Everyone', 'My Contacts', 'Nobody'];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final dynamic watcher = ref.watch(settingsProvider);
            final valInSheet = watcher[dbKey] ?? 'Everyone';

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24, bottom: 16),
                      child: Text('Who can see my $title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    ...options.map((option) {
                      return RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: valInSheet as String,
                        activeColor: colorScheme.primary,
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(settingsProvider.notifier).setString(dbKey, value);
                            Navigator.pop(context);
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }
}
