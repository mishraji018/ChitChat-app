import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/glass_widgets.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.55),
              elevation: 0,
            ),
          ),
        ),
      ),
      body: GlassBackground(
        isDark: isDark,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              const SizedBox(height: 8),
              _buildProfileRow(context, profile, colorScheme, isDark),
              const SizedBox(height: 16),
              const GlassSectionHeader(title: 'Account'),
              GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(children: [
                  GlassTile(isDark: isDark, icon: Icons.privacy_tip_outlined, iconColor: Colors.blue, title: 'Privacy', onTap: () => context.push('/privacy')),
                  const Divider(height: 1),
                  GlassTile(isDark: isDark, icon: Icons.security_outlined, iconColor: Colors.green, title: 'Security', onTap: () => context.push('/security')),
                ]),
              ),
              const GlassSectionHeader(title: 'Chats'),
              GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(children: [
                  _buildThemeTile(context, ref, colorScheme, isDark),
                  const Divider(height: 1),
                  GlassTile(isDark: isDark, icon: Icons.wallpaper_outlined, iconColor: Colors.purple, title: 'Wallpaper', onTap: () => _showWallpaperSheet(ref, colorScheme, isDark)),
                  const Divider(height: 1),
                  GlassTile(isDark: isDark, icon: Icons.format_size, iconColor: Colors.orange, title: 'Font size', subtitle: ref.watch(fontSizeProvider), onTap: () => _showFontSizeSheet(context, ref, colorScheme, isDark)),
                  const Divider(height: 1),
                  GlassTile(isDark: isDark, icon: Icons.backup_outlined, iconColor: Colors.teal, title: 'Chat backup', onTap: () => _showComingSoon('Chat backup')),
                  const Divider(height: 1),
                  GlassTile(isDark: isDark, icon: Icons.archive_outlined, iconColor: Colors.red, title: 'Archive all chats', onTap: () => _showArchiveDialog(colorScheme, isDark)),
                ]),
              ),
              const GlassSectionHeader(title: 'Notifications'),
              GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GlassTile(isDark: isDark, icon: Icons.notifications_none_outlined, iconColor: Colors.amber, title: 'Notifications', subtitle: 'Message, group & call tones', onTap: () => context.push('/notifications')),
              ),
              const GlassSectionHeader(title: 'App'),
              GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(children: [
                  _buildLanguageTile(context, ref, colorScheme, isDark),
                  const Divider(height: 1),
                  _buildAppLockTile(context, ref, colorScheme, isDark),
                  const Divider(height: 1),
                  GlassTile(isDark: isDark, icon: Icons.picture_as_pdf_outlined, iconColor: Colors.red, title: 'Download chats (PDF)', onTap: () => _showComingSoon('Download feature')),
                  const Divider(height: 1),
                  GlassTile(isDark: isDark, icon: Icons.storage_outlined, iconColor: Colors.indigo, title: 'Storage and data', onTap: () => _showComingSoon('Storage settings')),
                  const Divider(height: 1),
                  GlassTile(isDark: isDark, icon: Icons.help_outline, iconColor: Colors.cyan, title: 'Help', onTap: () => _showComingSoon('Help center')),
                  const Divider(height: 1),
                  GlassTile(isDark: isDark, icon: Icons.info_outline, iconColor: colorScheme.primary, title: 'About ChitChat', subtitle: 'v1.0.0', onTap: () => _showAboutDialog(colorScheme, isDark)),
                ]),
              ),
              const SizedBox(height: 20),
              GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(children: [
                  GlassTile(isDark: isDark, icon: Icons.logout, iconColor: Colors.red, title: 'Logout', trailing: const SizedBox.shrink(), onTap: () => _showLogoutDialog(colorScheme, isDark)),
                  const Divider(height: 1),
                  GlassTile(isDark: isDark, icon: Icons.delete_forever, iconColor: Colors.red, title: 'Delete Account', trailing: const SizedBox.shrink(), onTap: () => _showDeleteDialog(colorScheme, isDark)),
                ]),
              ),
              const SizedBox(height: 24),
              Center(child: Text('Made with ❤️ by ChitChat Team', style: TextStyle(color: colorScheme.secondary, fontSize: 12))),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProfileRow(BuildContext context, UserProfile profile, ColorScheme colorScheme, bool isDark) {
    return GlassCard(
      isDark: isDark,
      onTap: () => context.push('/profile'),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.tertiary]),
              boxShadow: [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.3), blurRadius: 12)],
            ),
            alignment: Alignment.center,
            child: Text(profile.name.isNotEmpty ? profile.name[0] : '?', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                Text(profile.mobile, style: TextStyle(color: colorScheme.secondary, fontSize: 13)),
                Text('Tap to edit profile', style: TextStyle(color: colorScheme.primary, fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colorScheme.secondary),
        ],
      ),
    );
  }



  Widget _buildThemeTile(BuildContext context, WidgetRef ref, ColorScheme colorScheme, bool isDark) {
    final currentTheme = ref.watch(themeProvider);
    return GlassTile(
      isDark: isDark,
      icon: Icons.palette_outlined,
      iconColor: Colors.deepPurple,
      title: 'Theme',
      subtitle: currentTheme.name.toUpperCase(),
      onTap: () => _showThemeSheet(ref, colorScheme, isDark),
    );
  }

  void _showFontSizeSheet(BuildContext context, WidgetRef ref, ColorScheme colorScheme, bool isDark) {
    final options = ['Small', 'Medium', 'Large'];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF121212) : colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final currentSize = ref.watch(fontSizeProvider);

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24, bottom: 16),
                      child: Text('Font size', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    ),
                    ...options.map((option) {
                      return RadioListTile<String>(
                        title: Text(option, style: TextStyle(color: colorScheme.onSurface)),
                        value: option,
                        groupValue: currentSize,
                        activeColor: colorScheme.primary,
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(settingsProvider.notifier).setString('font_size', value);
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

  void _showWallpaperSheet(WidgetRef ref, ColorScheme colorScheme, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF121212) : colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
            Padding(padding: const EdgeInsets.all(16), child: Text('Choose Wallpaper', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface))),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildWallpaperCategory('Premium', [
                    _WallpaperOption('Cherry Blossom', 'premium', 'assets/wallpapers/cherry_blossom.png', const Color(0xfffce7f3)),
                  ], ref, colorScheme),
                  const SizedBox(height: 16),
                  _buildWallpaperCategory('Classy & Default', [
                    _WallpaperOption('Default', 'default', '', Colors.grey.shade800),
                  ], ref, colorScheme),
                  const SizedBox(height: 16),
                  _buildWallpaperCategory('Solid Colors', [
                    _WallpaperOption('Midnight', 'solid', '#0f172a', const Color(0xff0f172a)),
                    _WallpaperOption('Forest', 'solid', '#064e3b', const Color(0xff064e3b)),
                    _WallpaperOption('Rose', 'solid', '#831843', const Color(0xff831843)),
                    _WallpaperOption('Chocolate', 'solid', '#451a03', const Color(0xff451a03)),
                  ], ref, colorScheme),
                  const SizedBox(height: 16),
                  _buildWallpaperCategory('Gradients', [
                    _WallpaperOption('Sunset', 'gradient', '#f59e0b,#e11d48', null, const LinearGradient(colors: [Color(0xfff59e0b), Color(0xffe11d48)])),
                    _WallpaperOption('Ocean', 'gradient', '#0ea5e9,#2563eb', null, const LinearGradient(colors: [Color(0xff0ea5e9), Color(0xff2563eb)])),
                    _WallpaperOption('Aurora', 'gradient', '#10b981,#3b82f6', null, const LinearGradient(colors: [Color(0xff10b981), Color(0xff3b82f6)])),
                  ], ref, colorScheme),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.photo_library, color: colorScheme.primary),
                    title: Text('Choose from device', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    trailing: Icon(Icons.chevron_right, color: colorScheme.secondary),
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                      if (image != null) {
                        final bytes = await image.readAsBytes();
                        final base64String = base64Encode(bytes);
                        ref.read(settingsProvider.notifier).setString('wallpaper_type', 'image');
                        ref.read(settingsProvider.notifier).setString('wallpaper_value', base64String);
                        if(context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Custom wallpaper applied!')));
                           Navigator.pop(context);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWallpaperCategory(String title, List<_WallpaperOption> options, WidgetRef ref, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final option = options[index];
              final currentType = ref.watch(wallpaperTypeProvider);
              final currentValue = ref.watch(wallpaperValueProvider);
              final isSelected = currentType == option.type && currentValue == option.value;

              return GestureDetector(
                onTap: () {
                  ref.read(settingsProvider.notifier).setString('wallpaper_type', option.type);
                  ref.read(settingsProvider.notifier).setString('wallpaper_value', option.value);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${option.name} wallpaper applied!')));
                  Navigator.pop(context);
                },
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: option.color,
                        gradient: option.gradient,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: colorScheme.primary, width: 3) : Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                    ),
                    const SizedBox(height: 4),
                    Text(option.name, style: TextStyle(fontSize: 11, color: colorScheme.onSurface)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showThemeSheet(WidgetRef ref, ColorScheme colorScheme, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF121212) : colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.all(16), child: Text('Choose Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface))),
          _buildThemeOption(ref, '📱 System Default', AppThemeMode.system, colorScheme),
          _buildThemeOption(ref, '🌙 Dark Mode', AppThemeMode.dark, colorScheme),
          _buildThemeOption(ref, '☀️ Light Mode', AppThemeMode.light, colorScheme),
          _buildThemeOption(ref, '🌊 Ocean Blue', AppThemeMode.ocean, colorScheme),
          _buildThemeOption(ref, '🌸 Pink', AppThemeMode.pink, colorScheme),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildThemeOption(WidgetRef ref, String label, AppThemeMode mode, ColorScheme colorScheme) {
    final isSelected = ref.watch(themeProvider) == mode;
    return ListTile(
      title: Text(label, style: TextStyle(color: colorScheme.onSurface)),
      trailing: isSelected ? Icon(Icons.check, color: colorScheme.primary) : null,
      onTap: () {
        ref.read(themeProvider.notifier).setTheme(mode);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Theme applied!')));
        Navigator.pop(context);
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context, WidgetRef ref, ColorScheme colorScheme, bool isDark) {
    final lang = ref.watch(selectedLanguageProvider);
    return GlassTile(
      isDark: isDark,
      icon: Icons.language,
      iconColor: Colors.lightBlue,
      title: 'Language',
      subtitle: lang,
      onTap: () => _showLanguageSheet(ref, colorScheme, isDark),
    );
  }

  void _showLanguageSheet(WidgetRef ref, ColorScheme colorScheme, bool isDark) {
    final languages = [
      {'label': '🇬🇧 English', 'value': 'English'},
      {'label': '🇮🇳 Hindi', 'value': 'Hindi'},
      {'label': '🇪🇸 Spanish', 'value': 'Spanish'},
      {'label': '🇫🇷 French', 'value': 'French'},
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF121212) : colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.all(16), child: Text('Choose Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface))),
          ...languages.map((l) => ListTile(
                title: Text(l['label']!, style: TextStyle(color: colorScheme.onSurface)),
                trailing: ref.watch(selectedLanguageProvider) == l['value'] ? Icon(Icons.check, color: colorScheme.primary) : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setString('selected_language', l['value']!);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Language changed to ${l['value']}!')));
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAppLockTile(BuildContext context, WidgetRef ref, ColorScheme colorScheme, bool isDark) {
    final enabled = ref.watch(appLockEnabledProvider);
    return GlassTile(
      isDark: isDark,
      icon: Icons.lock_outline,
      iconColor: Colors.redAccent,
      title: 'App Lock',
      subtitle: enabled ? 'Enabled' : 'Disabled',
      onTap: () => context.pushNamed('app-lock-settings'),
    );
  }

  void _showArchiveDialog(ColorScheme colorScheme, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Archive all chats?', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: colorScheme.secondary))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All chats archived!')));
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(ColorScheme colorScheme, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('About ChitChat 🐻', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: v1.0.0', style: TextStyle(color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Made with ❤️ by ChitChat Team', style: TextStyle(color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('A cute little chat app for everyone!', style: TextStyle(color: colorScheme.onSurface)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _showLogoutDialog(ColorScheme colorScheme, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout?', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?', style: TextStyle(color: colorScheme.onSurface)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: colorScheme.secondary))),
          TextButton(
            onPressed: () async {
              await ref.read(settingsProvider.notifier).clearAll();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ColorScheme colorScheme, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Account?', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        content: Text('This action cannot be undone. All your data will be permanently deleted.', style: TextStyle(color: colorScheme.onSurface)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: colorScheme.secondary))),
          TextButton(
            onPressed: () async {
              await ref.read(settingsProvider.notifier).clearAll();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _WallpaperOption {
  final String name;
  final String type;
  final String value;
  final Color? color;
  final Gradient? gradient;

  _WallpaperOption(this.name, this.type, this.value, [this.color, this.gradient]);
}
