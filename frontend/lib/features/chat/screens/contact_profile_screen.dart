import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../../data/providers/contact_provider.dart';

class ContactProfileScreen extends ConsumerWidget {
  final String userId;
  final String? conversationId; // Added conversationId
  final String name;
  final String avatar;
  final String about;

  const ContactProfileScreen({
    super.key,
    required this.userId,
    this.conversationId,
    required this.name,
    required this.avatar,
    this.about = 'Hey there! I am using ChitChat.',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final contactState = ref.watch(contactProvider((userId, conversationId)));
    final contactNotifier = ref.read(contactProvider((userId, conversationId)).notifier);

    // Show error if any
    if (contactState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(contactState.error!)),
        );
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GlassBackground(
        isDark: isDark,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  // Profile Header
                  Hero(
                    tag: 'avatar_$userId',
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.5), width: 2),
                        image: DecorationImage(
                          image: NetworkImage(avatar),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+91 98765 43210', 
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickAction(context, Icons.message, 'Message', () => Navigator.pop(context)),
                        _buildQuickAction(context, Icons.call, 'Audio', () {}),
                        _buildQuickAction(context, Icons.videocam, 'Video', () {}),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // About Section
                  _buildSection(
                    context,
                    'About',
                    child: Text(
                      about,
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Media Section
                  _buildSection(
                    context,
                    'Media, links, and docs',
                    trailing: Text('12 >', style: TextStyle(color: colorScheme.primary)),
                    child: SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) => Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          child: const Icon(Icons.image, color: Colors.white24),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Customizations & Settings
                  _buildSection(
                    context,
                    'Settings',
                    child: Column(
                      children: [
                        _buildToggleTile(
                          Icons.notifications_outlined,
                          'Mute notifications',
                          contactState.isMuted,
                          (val) => contactNotifier.toggleMute(),
                          colorScheme,
                        ),
                        _buildToggleTile(
                          Icons.lock_outline,
                          'Chat lock',
                          false,
                          (val) {},
                          colorScheme,
                        ),
                        _buildTile(
                          Icons.wallpaper,
                          'Custom wallpaper',
                          () {},
                          colorScheme,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Actions
                  _buildSection(
                    context,
                    'Actions',
                    child: Column(
                      children: [
                        _buildTile(
                          Icons.delete_outline,
                          'Clear Chat',
                          () => _showClearChatDialog(context, contactNotifier),
                          colorScheme,
                          isDestructive: true,
                        ),
                        _buildTile(
                          Icons.block,
                          contactState.isBlocked ? 'Unblock $name' : 'Block $name',
                          () => contactNotifier.toggleBlock(),
                          colorScheme,
                          isDestructive: true,
                        ),
                        _buildTile(
                          Icons.report_problem_outlined,
                          'Report $name',
                          () {},
                          colorScheme,
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            if (contactState.isLoading)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, {required Widget child, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        isDark: Theme.of(context).brightness == Brightness.dark,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (trailing != null) trailing,
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile(IconData icon, String label, bool value, ValueChanged<bool> onChanged, ColorScheme colorScheme) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: colorScheme.primary,
      ),
    );
  }

  Widget _buildTile(IconData icon, String label, VoidCallback onTap, ColorScheme colorScheme, {bool isDestructive = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white70),
      title: Text(
        label,
        style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
    );
  }

  void _showClearChatDialog(BuildContext context, ContactNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1a1a1a),
        title: const Text('Clear Chat', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to clear all messages in this chat?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await notifier.clearChat();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Chat cleared' : 'Failed to clear chat')),
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
