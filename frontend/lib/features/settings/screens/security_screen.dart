import 'package:flutter/material.dart';
import '../../../../shared/widgets/glass_widgets.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: glassAppBar(title: 'Security', isDark: isDark),
      body: GlassBackground(
        isDark: isDark,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 20, 16, 40),
          children: [
            const GlassSectionHeader(title: 'Login & Verification'),
            GlassCard(
              isDark: isDark,
              child: Column(children: [
                _buildNavigationTile(context, Icons.key_outlined, 'Passkeys', colorScheme, isDark),
                const Divider(height: 1),
                _buildNavigationTile(context, Icons.email_outlined, 'Email address', colorScheme, isDark),
                const Divider(height: 1),
                _buildNavigationTile(context, Icons.verified_user_outlined, 'Two-step verification', colorScheme, isDark),
              ]),
            ),
            
            const GlassSectionHeader(title: 'Account Settings'),
            GlassCard(
              isDark: isDark,
              child: Column(children: [
                _buildNavigationTile(context, Icons.swap_horiz_outlined, 'Change phone number', colorScheme, isDark),
                const Divider(height: 1),
                _buildNavigationTile(context, Icons.person_add_outlined, 'Add account', colorScheme, isDark),
              ]),
            ),
            
            const SizedBox(height: 16),
            GlassCard(
              isDark: isDark,
              child: _buildNavigationTile(context, Icons.delete_outline, 'Delete account', colorScheme, isDark, isDestructive: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTile(BuildContext context, IconData icon, String title, ColorScheme colorScheme, bool isDark, {bool isDestructive = false}) {
    return GlassTile(
      isDark: isDark,
      icon: icon,
      iconColor: isDestructive ? Colors.red : colorScheme.primary,
      title: title,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title settings coming soon!')));
      },
    );
  }
}
