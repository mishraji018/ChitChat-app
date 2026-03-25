import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../data/providers/auth_provider.dart';
import 'package:pinput/pinput.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileRow(context, profile, colorScheme),
          const SizedBox(height: 24),
          _buildSection('Account', [
            _buildTile(Icons.privacy_tip_outlined, 'Privacy', null, colorScheme),
            _buildTile(Icons.security_outlined, 'Security', null, colorScheme),
            _buildTile(Icons.verified_user_outlined, 'Two-step verification', null, colorScheme),
          ], colorScheme),
          const SizedBox(height: 16),
          _buildSection('Chats', [
            _buildThemeTile(context, ref, colorScheme),
            _buildTile(Icons.wallpaper_outlined, 'Wallpaper', null, colorScheme),
            _buildTile(Icons.backup_outlined, 'Chat backup', null, colorScheme),
            _buildTile(Icons.archive_outlined, 'Archive all chats', null, colorScheme, iconColor: Colors.red),
          ], colorScheme),
          const SizedBox(height: 16),
          _buildSection('Notifications', [
            _buildSwitchTile(Icons.message_outlined, 'Message notifications', notificationsEnabledProvider, (val) => ref.read(settingsProvider.notifier).setBool('notifications_enabled', val), colorScheme, ref),
            _buildSwitchTile(Icons.group_outlined, 'Group notifications', groupNotificationsProvider, (val) => ref.read(settingsProvider.notifier).setBool('group_notifications_enabled', val), colorScheme, ref),
            _buildSwitchTile(Icons.emoji_emotions_outlined, 'Reaction notifications', null, (val) {}, colorScheme, ref, initial: true),
            _buildTile(Icons.notifications_active_outlined, 'Notification sound', 'Default', colorScheme),
            _buildSwitchTile(Icons.vibration_outlined, 'Vibration', vibrationEnabledProvider, (val) => ref.read(settingsProvider.notifier).setBool('vibration_enabled', val), colorScheme, ref),
          ], colorScheme),
          const SizedBox(height: 16),
          _buildSection('App', [
            _buildLanguageTile(context, ref, colorScheme),
            _buildAppLockTile(context, ref, colorScheme),
            _buildTile(Icons.picture_as_pdf_outlined, 'Download chats (PDF)', null, colorScheme),
            _buildTile(Icons.storage_outlined, 'Storage and data', null, colorScheme),
            _buildTile(Icons.help_outline, 'Help', null, colorScheme),
            _buildTile(Icons.info_outline, 'About ChitChat', 'ChitChat v1.0.0', colorScheme),
          ], colorScheme),
          const SizedBox(height: 24),
          _buildLogoutButton(context, ref, colorScheme),
          const SizedBox(height: 32),
          Center(child: Text('Made with ❤️ by ChitChat Team', style: TextStyle(color: colorScheme.secondary, fontSize: 12))),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        onTap: () async {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) {
            context.go('/login');
          }
        },
      ),
    );
  }

  Widget _buildProfileRow(BuildContext context, UserProfile profile, ColorScheme colorScheme) {
    return InkWell(
      onTap: () => context.push('/profile'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            CircleAvatar(radius: 30, backgroundColor: colorScheme.primary, child: Text(profile.name[0], style: TextStyle(color: colorScheme.onPrimary, fontSize: 24, fontWeight: FontWeight.bold))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  Text(profile.mobile, style: TextStyle(color: colorScheme.secondary, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 8, bottom: 8), child: Text(title, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13))),
        Container(
          decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile(IconData icon, String title, String? subtitle, ColorScheme colorScheme, {Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? colorScheme.primary),
      title: Text(title, style: TextStyle(color: colorScheme.onSurface, fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: colorScheme.secondary, fontSize: 12)) : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, ProviderListenable<bool>? provider, Function(bool) onChanged, ColorScheme colorScheme, WidgetRef ref, {bool initial = false}) {
    final value = provider != null ? ref.watch(provider) : initial;
    return SwitchListTile(
      secondary: Icon(icon, color: colorScheme.primary),
      title: Text(title, style: TextStyle(color: colorScheme.onSurface, fontSize: 15)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildThemeTile(BuildContext context, WidgetRef ref, ColorScheme colorScheme) {
    final currentTheme = ref.watch(themeProvider);
    return ListTile(
      leading: Icon(Icons.palette_outlined, color: colorScheme.primary),
      title: const Text('Theme', style: TextStyle(fontSize: 15)),
      subtitle: Text(currentTheme.name.toUpperCase(), style: TextStyle(color: colorScheme.secondary, fontSize: 12)),
      onTap: () => _showThemeSheet(context, ref, colorScheme),
    );
  }

  void _showThemeSheet(BuildContext context, WidgetRef ref, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildThemeOption(context, ref, 'Light', AppThemeMode.light, Colors.white, colorScheme),
            _buildThemeOption(context, ref, 'Dark', AppThemeMode.dark, Colors.black, colorScheme),
            _buildThemeOption(context, ref, 'Ocean', AppThemeMode.ocean, Colors.blue, colorScheme),
            _buildThemeOption(context, ref, 'Pink', AppThemeMode.pink, Colors.pink, colorScheme),
            _buildThemeOption(context, ref, 'System Default', AppThemeMode.system, Colors.grey, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, WidgetRef ref, String label, AppThemeMode mode, Color swatch, ColorScheme colorScheme) {
    final isSelected = ref.watch(themeProvider) == mode;
    return ListTile(
      leading: Container(width: 24, height: 24, decoration: BoxDecoration(color: swatch, shape: BoxShape.circle, border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)))),
      title: Text(label),
      trailing: isSelected ? Icon(Icons.check, color: colorScheme.primary) : null,
      onTap: () {
        ref.read(themeProvider.notifier).setTheme(mode);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context, WidgetRef ref, ColorScheme colorScheme) {
    final lang = ref.watch(selectedLanguageProvider);
    return ListTile(
      leading: Icon(Icons.language, color: colorScheme.primary),
      title: const Text('Language', style: TextStyle(fontSize: 15)),
      subtitle: Text(lang, style: TextStyle(color: colorScheme.secondary, fontSize: 12)),
      onTap: () => _showLanguageSheet(context, ref, colorScheme),
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref, ColorScheme colorScheme) {
    final langs = ['English', 'Hindi', 'Spanish', 'French'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...langs.map((l) => ListTile(
              title: Text(l),
              trailing: ref.watch(selectedLanguageProvider) == l ? Icon(Icons.check, color: colorScheme.primary) : null,
              onTap: () {
                ref.read(settingsProvider.notifier).setString('selected_language', l);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLockTile(BuildContext context, WidgetRef ref, ColorScheme colorScheme) {
    final isLocked = ref.watch(appLockEnabledProvider);
    return SwitchListTile(
      secondary: Icon(Icons.lock_outline, color: colorScheme.primary),
      title: const Text('App Lock', style: TextStyle(fontSize: 15)),
      value: isLocked,
      onChanged: (val) {
        if (val) {
          _showPinSetup(context, ref, colorScheme);
        } else {
          ref.read(settingsProvider.notifier).setBool('app_lock_enabled', false);
        }
      },
    );
  }

  void _showPinSetup(BuildContext context, WidgetRef ref, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Setup 4-Digit PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Pinput(
                length: 4,
                obscureText: true,
                onCompleted: (pin) {
                  ref.read(settingsProvider.notifier).setBool('app_lock_enabled', true);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
