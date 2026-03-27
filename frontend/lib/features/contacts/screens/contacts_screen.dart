import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/contacts_provider.dart';
import '../../../data/models/contact_model.dart';
import '../../../../shared/widgets/glass_widgets.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final filteredContacts = ref.watch(filteredContactsProvider);

    // Group contacts by first letter
    final grouped = <String, List<ContactModel>>{};
    for (var contact in filteredContacts) {
      if (contact.name.isEmpty) continue;
      final letter = contact.name[0].toUpperCase();
      grouped.putIfAbsent(letter, () => []).add(contact);
    }
    final sortedLetters = grouped.keys.toList()..sort();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        isDark: isDark,
        child: SafeArea( // Keep SafeArea for content padding
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight), // Manual spacer instead of AppBar
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: sortedLetters.length + 1, // +1 for invite banner
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildInviteBanner(colorScheme, isDark),
                      );
                    }
                    
                    final letter = sortedLetters[index - 1];
                    final letterContacts = grouped[letter]!;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
                          child: Text(
                            letter,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        GlassCard(
                          isDark: isDark,
                          padding: EdgeInsets.zero, // Zero padding for list children
                          radius: 28,
                          child: Column(
                            children: List.generate(letterContacts.length, (idx) {
                              final contact = letterContacts[idx];
                              return Column(
                                children: [
                                  _ContactListTile(contact: contact, isDark: isDark),
                                  if (idx < letterContacts.length - 1)
                                    Divider(
                                      height: 1,
                                      indent: 72,
                                      endIndent: 16,
                                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                                    ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInviteBanner(ColorScheme colorScheme, bool isDark) {
    return GlassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      radius: 24,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.tertiary]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Invite Friends', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Spread the love with ChitChat 🐻', style: TextStyle(color: colorScheme.secondary.withValues(alpha: 0.7), fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('SHARE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _ContactListTile extends StatelessWidget {
  final ContactModel contact;
  final bool isDark;
  const _ContactListTile({required this.contact, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.push('/chat/${contact.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [colorScheme.primary.withValues(alpha: 0.2), colorScheme.tertiary.withValues(alpha: 0.1)],
                    ),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                if (contact.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xff0D0D1A) : Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(contact.mobile, style: TextStyle(color: colorScheme.secondary.withValues(alpha: 0.6), fontSize: 13)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chat_bubble_outline_rounded, color: colorScheme.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
