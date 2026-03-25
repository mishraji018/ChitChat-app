import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactInfoScreen extends ConsumerWidget {
  final String userId;
  const ContactInfoScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.7)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'JD',
                        style: TextStyle(color: colorScheme.onPrimary, fontSize: 80, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('John Doe', style: TextStyle(color: colorScheme.onPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('+91 9876543210 • Online', style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.8), fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildActionRow(colorScheme),
                  const SizedBox(height: 24),
                  _buildSection('About and Phone', [
                    ListTile(
                      title: const Text('Living the dream!'),
                      subtitle: const Text('June 12, 2023'),
                      onTap: () {},
                    ),
                    const Divider(indent: 16),
                    ListTile(
                      title: const Text('+91 9876543210'),
                      subtitle: const Text('Mobile'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: Icon(Icons.chat, color: colorScheme.primary), onPressed: () {}),
                          IconButton(icon: Icon(Icons.phone, color: colorScheme.primary), onPressed: () {}),
                          IconButton(icon: Icon(Icons.videocam, color: colorScheme.primary), onPressed: () {}),
                        ],
                      ),
                    ),
                  ], colorScheme),
                  const SizedBox(height: 16),
                  _buildMediaSection(colorScheme),
                  const SizedBox(height: 16),
                  _buildSection('Settings', [
                    _buildSwitchTile(Icons.notifications_off_outlined, 'Mute notifications', false, colorScheme),
                    _buildTile(Icons.wallpaper, 'Custom wallpaper', colorScheme),
                    _buildSwitchTile(Icons.push_pin_outlined, 'Pin chat', false, colorScheme),
                    _buildSwitchTile(Icons.archive_outlined, 'Archive chat', false, colorScheme),
                  ], colorScheme),
                  const SizedBox(height: 16),
                  _buildSection('Danger Zone', [
                    _buildTile(Icons.block, 'Block John Doe', colorScheme, isDanger: true),
                    _buildTile(Icons.thumb_down_outlined, 'Report John Doe', colorScheme, isDanger: true),
                    _buildTile(Icons.delete_outline, 'Clear chat', colorScheme, isDanger: true),
                  ], colorScheme),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.phone, 'Audio', colorScheme),
        _buildActionButton(Icons.videocam, 'Video', colorScheme),
        _buildActionButton(Icons.search, 'Search', colorScheme),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: colorScheme.primary),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(16), child: Text(title, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13))),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, ColorScheme colorScheme, {bool isDanger = false}) {
    final color = isDanger ? Colors.red : colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, ColorScheme colorScheme) {
    return SwitchListTile(
      secondary: Icon(icon, color: colorScheme.onSurface),
      title: Text(title, style: TextStyle(color: colorScheme.onSurface, fontSize: 15)),
      value: value,
      onChanged: (val) {},
    );
  }

  Widget _buildMediaSection(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Media, links, and docs', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text('185 ', style: TextStyle(color: colorScheme.secondary)),
                  Icon(Icons.chevron_right, size: 20, color: colorScheme.secondary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(4, (i) => Expanded(
              child: Container(
                height: 70,
                margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.image, color: colorScheme.primary.withValues(alpha: 0.5)),
              ),
            )),
          ),
        ],
      ),
    );
  }
}
