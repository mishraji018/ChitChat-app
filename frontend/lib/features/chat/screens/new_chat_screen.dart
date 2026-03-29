import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/contacts_provider.dart';

class NewChatScreen extends ConsumerWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredContacts = ref.watch(filteredContactsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('New Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(ref, colorScheme),
          Expanded(
            child: ListView(
              children: [
                _buildActionTile(
                  icon: Icons.group,
                  iconColor: Colors.green,
                  title: 'New Group',
                  subtitle: 'Create a group chat',
                  onTap: () => context.push('/new-group'),
                ),
                _buildActionTile(
                  icon: Icons.person_add,
                  iconColor: Colors.blue,
                  title: 'New Contact',
                  subtitle: 'Add a contact',
                  onTap: () => context.push('/add-contact'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'CONTACTS ON CHITCHAT',
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                if (filteredContacts.isEmpty)
                  _buildEmptyState(colorScheme)
                else
                  ...filteredContacts.map((contact) => _ContactTile(contact: contact)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) => ref.read(contactsSearchQueryProvider.notifier).state = value,
          decoration: InputDecoration(
            hintText: 'Search by name or number...',
            hintStyle: TextStyle(color: colorScheme.secondary.withValues(alpha: 0.7)),
            prefixIcon: Icon(Icons.search, color: colorScheme.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👥', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No contacts found',
              style: TextStyle(
                color: colorScheme.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      onTap: onTap,
    );
  }
}

class _ContactTile extends StatelessWidget {
  final dynamic contact;
  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              contact.name[0].toUpperCase(),
              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
          if (contact.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(contact.mobile, style: TextStyle(color: colorScheme.secondary, fontSize: 13)),
      onTap: () => context.push('/chat/${contact.id}'),
    );
  }
}
