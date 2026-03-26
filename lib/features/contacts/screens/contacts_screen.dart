import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/contacts_provider.dart';
import '../../../data/models/contact_model.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredContacts = ref.watch(filteredContactsProvider);

    // Group contacts by first letter
    final grouped = <String, List<ContactModel>>{};
    for (var contact in filteredContacts) {
      final letter = contact.name[0].toUpperCase();
      grouped.putIfAbsent(letter, () => []).add(contact);
    }
    final sortedLetters = grouped.keys.toList()..sort();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
              const PopupMenuItem(value: 'invite', child: Text('Invite friends')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInviteBanner(colorScheme, theme),
          _buildSearchBar(ref, colorScheme),
          Expanded(
            child: ListView.builder(
              itemCount: sortedLetters.length,
              itemBuilder: (context, index) {
                final letter = sortedLetters[index];
                final letterContacts = grouped[letter]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        letter,
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...letterContacts.map((c) => _ContactListTile(contact: c)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteBanner(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.share, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Invite friends to BlinkChat', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Share the app with your loved ones', style: TextStyle(color: colorScheme.secondary, fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text('SHARE', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          onChanged: (value) => ref.read(contactsSearchQueryProvider.notifier).state = value,
          decoration: InputDecoration(
            hintText: 'Search contacts...',
            hintStyle: TextStyle(color: colorScheme.secondary.withOpacity(0.5)),
            prefixIcon: Icon(Icons.search, color: colorScheme.secondary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}

class _ContactListTile extends StatelessWidget {
  final ContactModel contact;
  const _ContactListTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.primary.withOpacity(0.05),
            child: Text(contact.name[0], style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          if (contact.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
                ),
              ),
            ),
        ],
      ),
      title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(contact.mobile, style: TextStyle(color: colorScheme.secondary, fontSize: 13)),
      trailing: IconButton(
        icon: Icon(Icons.chat_bubble_outline, color: colorScheme.primary, size: 20),
        onPressed: () => context.push('/chat/${contact.id}'),
      ),
      onTap: () => context.push('/contact-info/${contact.id}'),
    );
  }
}
