import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/account_provider.dart';
import '../../../data/models/account_model.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  // ── PASSKEYS ────────────────────────────────────────────────────
  void _showPasskeysSheet(BuildContext ctx, WidgetRef ref, List<PasskeyModel> passkeys) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PasskeysSheet(
        passkeys: passkeys,
        onAdd: (name) async {
          final ok = await ref.read(accountProvider.notifier).addPasskey(name);
          if (ctx.mounted) {
            Navigator.pop(ctx);
            _snack(ctx, ok ? 'Passkey added ✅' : 'Failed to add passkey');
          }
        },
        onRemove: (id) async {
          final ok = await ref.read(accountProvider.notifier).removePasskey(id);
          if (ctx.mounted) {
            Navigator.pop(ctx);
            _snack(ctx, ok ? 'Passkey removed' : 'Failed to remove passkey');
          }
        },
      ),
    );
  }

  // ── EMAIL ────────────────────────────────────────────────────────
  void _showEmailSheet(BuildContext ctx, WidgetRef ref, String current) {
    final ctrl = TextEditingController(text: current);
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 24,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Email address',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                final ok = await ref.read(accountProvider.notifier).updateEmail(ctrl.text.trim());
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  _snack(ctx, ok ? 'Email updated ✅' : 'Failed to update email');
                }
              },
              child: const Text('Save'),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  // ── CHANGE PHONE ─────────────────────────────────────────────────
  void _showChangePhoneSheet(BuildContext ctx, WidgetRef ref) {
    final phoneCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    bool otpSent = false;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (bCtx, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 24,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              otpSent ? 'Enter OTP' : 'Change phone number',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (!otpSent) ...[
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'New phone number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final ok = await ref
                        .read(accountProvider.notifier)
                        .requestPhoneChange(phoneCtrl.text.trim());
                    if (bCtx.mounted) {
                      if (ok) {
                        setState(() => otpSent = true);
                      } else {
                        _snack(ctx, 'Failed to send OTP');
                      }
                    }
                  },
                  child: const Text('Send OTP'),
                ),
              ),
            ] else ...[
              TextField(
                controller: otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final ok = await ref
                        .read(accountProvider.notifier)
                        .confirmPhoneChange(otpCtrl.text.trim());
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      _snack(ctx, ok ? 'Phone number updated ✅' : 'Invalid OTP');
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  // ── DELETE ACCOUNT ───────────────────────────────────────────────
  void _showDeleteDialog(BuildContext ctx, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
        title: const Text('Delete account?'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
            'This action is permanent and cannot be undone. '
            'All your messages and data will be deleted forever.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Type DELETE to confirm',
              border: OutlineInputBorder(),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (ctrl.text.trim() != 'DELETE') {
                _snack(ctx, 'Please type DELETE to confirm');
                return;
              }
              final ok = await ref.read(accountProvider.notifier).deleteAccount();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (ok) {
                  // Clear storage and go to login
                  _snack(ctx, 'Account deleted. Goodbye 👋');
                } else {
                  _snack(ctx, 'Failed to delete account');
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
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

  void _snack(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── BUILD ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncAccount = ref.watch(accountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account'), elevation: 0),
      body: asyncAccount.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text('Failed to load account info'),
            TextButton(
              onPressed: () => ref.read(accountProvider.notifier).load(),
              child: const Text('Retry'),
            ),
          ]),
        ),
        data: (account) => ListView(children: [
          // ── LOGIN & VERIFICATION ──────────────────────────────
          const _SectionHeader('LOGIN & VERIFICATION'),

          _ATile(
            icon: Icons.key_outlined,
            title: 'Passkeys',
            subtitle: account.passkeys.isEmpty
                ? 'None'
                : '${account.passkeys.length} passkey${account.passkeys.length > 1 ? 's' : ''}',
            onTap: () => _showPasskeysSheet(context, ref, account.passkeys),
          ),
          const _Div(),
          _ATile(
            icon: Icons.email_outlined,
            title: 'Email address',
            subtitle: account.email.isEmpty ? 'Not set' : account.email,
            onTap: () => _showEmailSheet(context, ref, account.email),
          ),
          const _Div(),
          _ATile(
            icon: Icons.verified_user_outlined,
            title: 'Two-step verification',
            subtitle: 'Coming soon',
            onTap: () => _comingSoon(context, 'Two-step verification'),
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

          // ── ACCOUNT SETTINGS ──────────────────────────────────
          const _SectionHeader('ACCOUNT SETTINGS'),

          _ATile(
            icon: Icons.swap_horiz_rounded,
            title: 'Change phone number',
            subtitle: account.phone.isNotEmpty ? account.phone : 'Not set',
            onTap: () => _showChangePhoneSheet(context, ref),
          ),
          const _Div(),
          _ATile(
            icon: Icons.person_add_outlined,
            title: 'Add account',
            subtitle: 'Sign in with another number',
            onTap: () => _comingSoon(context, 'Add account'),
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
          const SizedBox(height: 16),

          // ── DELETE ACCOUNT ────────────────────────────────────
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red),
            ),
            title: const Text(
              'Delete account',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            trailing:
                Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
            onTap: () => _showDeleteDialog(context, ref),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PASSKEYS BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────

class _PasskeysSheet extends StatelessWidget {
  final List<PasskeyModel> passkeys;
  final Future<void> Function(String) onAdd;
  final Future<void> Function(String) onRemove;

  const _PasskeysSheet({
    required this.passkeys,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ctrl = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 24,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Passkeys',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (passkeys.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('No passkeys added yet.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          )
        else
          ...passkeys.map((p) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.devices_outlined),
                title: Text(p.deviceName),
                subtitle: Text(
                  'Added ${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}',
                  style: theme.textTheme.bodySmall,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => onRemove(p.id),
                ),
              )),
        const Divider(height: 24),
        TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Device name (e.g. My Pixel 8)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_android_outlined),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) onAdd(ctrl.text.trim());
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Passkey'),
          ),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PRIVATE WIDGETS
// ─────────────────────────────────────────────────────────────────

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

class _ATile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ATile({
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
      trailing: trailing ??
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
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
