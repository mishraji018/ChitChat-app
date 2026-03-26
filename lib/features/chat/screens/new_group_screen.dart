import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/contacts_provider.dart';
import '../../../data/models/contact_model.dart';

class NewGroupScreen extends ConsumerWidget {
  const NewGroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredContacts = ref.watch(filteredContactsProvider);
    final selectedIds = ref.watch(selectedContactsProvider);
    final contacts = ref.watch(contactsProvider);
    
    final selectedContacts = contacts.where((c) => selectedIds.contains(c.id)).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Group'),
            Text(
              'Add participants (${selectedIds.length}/256)',
              style: TextStyle(fontSize: 12, color: colorScheme.secondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: selectedIds.isEmpty ? null : () => context.push('/new-group-info'),
            child: Text(
              'NEXT',
              style: TextStyle(
                color: selectedIds.isEmpty ? colorScheme.secondary : colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (selectedIds.isNotEmpty) _buildSelectedList(selectedContacts, ref, colorScheme),
          _buildSearchBar(ref, colorScheme),
          Expanded(
            child: ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];
                final isSelected = selectedIds.contains(contact.id);
                return _SelectContactTile(
                  contact: contact,
                  isSelected: isSelected,
                  onTap: () {
                    final newSet = Set<String>.from(selectedIds);
                    if (isSelected) {
                      newSet.remove(contact.id);
                    } else {
                      newSet.add(contact.id);
                    }
                    ref.read(selectedContactsProvider.notifier).state = newSet;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedList(List<ContactModel> selected, WidgetRef ref, ColorScheme colorScheme) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.onSurface.withOpacity(0.05))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: selected.length,
        itemBuilder: (context, index) {
          final contact = selected[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      child: Text(contact.name[0], style: TextStyle(color: colorScheme.primary)),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 48,
                      child: Text(
                        contact.name.split(' ')[0],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      final newSet = Set<String>.from(ref.read(selectedContactsProvider));
                      newSet.remove(contact.id);
                      ref.read(selectedContactsProvider.notifier).state = newSet;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: colorScheme.secondary, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
        ),
        child: TextField(
          onChanged: (value) => ref.read(contactsSearchQueryProvider.notifier).state = value,
          decoration: InputDecoration(
            hintText: 'Search by name or number...',
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

class _SelectContactTile extends StatelessWidget {
  final ContactModel contact;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectContactTile({
    required this.contact,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: colorScheme.primary.withOpacity(0.1),
        child: Text(contact.name[0], style: TextStyle(color: colorScheme.primary)),
      ),
      title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(contact.mobile, style: TextStyle(color: colorScheme.secondary, fontSize: 12)),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (_) => onTap(),
        activeColor: colorScheme.primary,
        shape: const CircleBorder(),
      ),
      onTap: onTap,
    );
  }
}
