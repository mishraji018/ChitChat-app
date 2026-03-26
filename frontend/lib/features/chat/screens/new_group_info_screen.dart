import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/contacts_provider.dart';

class NewGroupInfoScreen extends ConsumerStatefulWidget {
  const NewGroupInfoScreen({super.key});

  @override
  ConsumerState<NewGroupInfoScreen> createState() => _NewGroupInfoScreenState();
}

class _NewGroupInfoScreenState extends ConsumerState<NewGroupInfoScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedIds = ref.watch(selectedContactsProvider);
    final contacts = ref.watch(contactsProvider);
    final selectedContacts = contacts.where((c) => selectedIds.contains(c.id)).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('New Group'),
        actions: [
          TextButton(
            onPressed: _nameController.text.trim().isEmpty ? null : () => _createGroup(),
            child: Text(
              'CREATE',
              style: TextStyle(
                color: _nameController.text.trim().isEmpty ? colorScheme.secondary : colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildAvatarPicker(colorScheme),
            const SizedBox(height: 32),
            _buildInputs(colorScheme),
            _buildParticipantsPreview(selectedContacts, colorScheme),
            const SizedBox(height: 32),
            _buildCreateButton(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker(ColorScheme colorScheme) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(Icons.group, size: 50, color: colorScheme.primary),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: colorScheme.surface, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]),
              child: Icon(Icons.camera_alt, size: 20, color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputs(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            maxLength: 25,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Group name (required)',
              counterStyle: TextStyle(color: colorScheme.secondary),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            maxLength: 100,
            decoration: const InputDecoration(hintText: 'Group description (optional)'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildParticipantsPreview(selected, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            '${selected.length} PARTICIPANTS',
            style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: selected.length,
            itemBuilder: (context, index) {
              final contact = selected[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(contact.name[0], style: TextStyle(color: colorScheme.primary, fontSize: 12)),
                    ),
                    const SizedBox(height: 4),
                    Text(contact.name.split(' ')[0], style: const TextStyle(fontSize: 10)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _nameController.text.trim().isEmpty ? null : () => _createGroup(),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Create Group', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _createGroup() {
    // Navigate to chat
    context.go('/chat/new_group_id');
    // Clear selection
    ref.read(selectedContactsProvider.notifier).state = {};
  }
}
