import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/privacy_provider.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  static String visibilityLabel(String v) => switch (v) {
        'contacts' => 'My contacts',
        'nobody' => 'Nobody',
        _ => 'Everyone',
      };

  static String timerLabel(int s) => switch (s) {
        86400 => '24 hours',
        604800 => '7 days',
        7776000 => '90 days',
        _ => 'Off',
      };

  void _visibilitySheet(
    BuildContext ctx,
    WidgetRef ref,
    String title,
    String current,
    String key,
  ) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _RadioSheet<String>(
        title: title,
        options: const {
          'everyone': 'Everyone',
          'contacts': 'My contacts',
          'nobody': 'Nobody',
        },
        current: current,
        onSelect: (v) {
          Navigator.pop(ctx);
          ref.read(privacyProvider.notifier).updateField({key: v});
        },
      ),
    );
  }

  void _timerSheet(BuildContext ctx, WidgetRef ref, int current) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _RadioSheet<int>(
        title: 'Default message timer',
        options: const {0: 'Off', 86400: '24 hours', 604800: '7 days', 7776000: '90 days'},
        current: current,
        onSelect: (v) {
          Navigator.pop(ctx);
          ref.read(privacyProvider.notifier).updateField({'defaultMessageTimer': v});
        },
      ),
    );
  }

  void _comingSoon(BuildContext ctx, String label) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text('$label — Coming Soon 🚀'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncPrivacy = ref.watch(privacyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy'), elevation: 0),
      body: asyncPrivacy.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text('Failed to load privacy settings'),
            TextButton(
              onPressed: () => ref.read(privacyProvider.notifier).load(),
              child: const Text('Retry'),
            ),
          ]),
        ),
        data: (s) => ListView(children: [
          // ──────────────────────────────────────────
          // WHO CAN SEE MY PERSONAL INFO
          // ──────────────────────────────────────────
          _SectionHeader('WHO CAN SEE MY PERSONAL INFO'),
          _PTile(
            icon: Icons.shield_outlined,
            title: 'Last seen and online',
            subtitle: visibilityLabel(s.lastSeen),
            onTap: () => _visibilitySheet(context, ref, 'Last seen and online', s.lastSeen, 'lastSeen'),
          ),
          const _Div(),
          _PTile(
            icon: Icons.shield_outlined,
            title: 'Profile photo',
            subtitle: visibilityLabel(s.profilePhoto),
            onTap: () => _visibilitySheet(context, ref, 'Profile photo', s.profilePhoto, 'profilePhoto'),
          ),
          const _Div(),
          _PTile(
            icon: Icons.shield_outlined,
            title: 'About',
            subtitle: visibilityLabel(s.about),
            onTap: () => _visibilitySheet(context, ref, 'About', s.about, 'about'),
          ),
          const _Div(),
          _PTile(
            icon: Icons.shield_outlined,
            title: 'Status',
            subtitle: visibilityLabel(s.status),
            onTap: () => _visibilitySheet(context, ref, 'Status', s.status, 'status'),
          ),
          const SizedBox(height: 8),

          // ──────────────────────────────────────────
          // READ RECEIPTS
          // ──────────────────────────────────────────
          SwitchListTile(
            value: s.readReceipts,
            onChanged: (v) =>
                ref.read(privacyProvider.notifier).updateField({'readReceipts': v}),
            title: Text('Read receipts', style: theme.textTheme.bodyLarge),
            subtitle: Text(
              "If turned off, you won't send or receive read receipts.",
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 8),

          // ──────────────────────────────────────────
          // MESSAGING
          // ──────────────────────────────────────────
          _SectionHeader('MESSAGING'),
          _PTile(
            icon: Icons.timer_outlined,
            title: 'Default message timer',
            subtitle: timerLabel(s.defaultMessageTimer),
            onTap: () => _timerSheet(context, ref, s.defaultMessageTimer),
          ),
          const _Div(),
          _PTile(
            icon: Icons.location_on_outlined,
            title: 'Live location',
            subtitle: 'None',
            onTap: () => _comingSoon(context, 'Live location'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Soon',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ──────────────────────────────────────────
          // CALLS & SECURITY
          // ──────────────────────────────────────────
          _SectionHeader('CALLS & SECURITY'),
          SwitchListTile(
            secondary: Icon(Icons.phone_disabled_outlined,
                color: theme.colorScheme.onSurfaceVariant),
            value: s.silenceUnknownCallers,
            onChanged: (v) => ref
                .read(privacyProvider.notifier)
                .updateField({'silenceUnknownCallers': v}),
            title: Text('Silence unknown callers', style: theme.textTheme.bodyLarge),
            subtitle: Text(
              'Calls from unknown numbers will be silenced.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const _Div(),
          _PTile(
            icon: Icons.block,
            title: 'Blocked contacts',
            subtitle: 'None',
            onTap: () => _comingSoon(context, 'Blocked contacts'),
          ),
          const _Div(),
          _PTile(
            icon: Icons.lock_outlined,
            title: 'App lock',
            subtitle: s.appLock ? 'Enabled' : 'Disabled',
            onTap: () => ref
                .read(privacyProvider.notifier)
                .updateField({'appLock': !s.appLock}),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// PRIVATE WIDGETS
// ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _PTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _PTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: Text(subtitle,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      trailing: trailing ?? Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}

class _Div extends StatelessWidget {
  const _Div();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 56, endIndent: 0);
}

class _RadioSheet<T> extends StatelessWidget {
  final String title;
  final Map<T, String> options;
  final T current;
  final void Function(T) onSelect;

  const _RadioSheet({
    required this.title,
    required this.options,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ...options.entries.map((e) => RadioListTile<T>(
                title: Text(e.value),
                value: e.key,
                groupValue: current,
                onChanged: (v) => v != null ? onSelect(v) : null,
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
