import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../data/providers/settings_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _bioController = TextEditingController(text: profile.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                final res = await _picker.pickImage(source: ImageSource.camera);
                if (context.mounted) Navigator.pop(context, res);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                final res = await _picker.pickImage(source: ImageSource.gallery);
                if (context.mounted) Navigator.pop(context, res);
              },
            ),
          ],
        ),
      ),
    );

    if (image != null) {
      ref.read(userProfileProvider.notifier).updateAvatar(image.path);
    }
  }

  void _saveProfile() {
    ref.read(userProfileProvider.notifier).updateName(_nameController.text);
    ref.read(userProfileProvider.notifier).updateBio(_bioController.text);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(profile, colorScheme, theme),
            const SizedBox(height: 32),
            if (!_isEditing) _buildViewMode(profile, colorScheme) else _buildEditMode(colorScheme),
            const SizedBox(height: 32),
            _buildStatsRow(colorScheme),
            const SizedBox(height: 48),
            _buildDangerZone(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UserProfile profile, ColorScheme colorScheme, ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: colorScheme.primary,
                backgroundImage: profile.avatarUrl != null ? FileImage(File(profile.avatarUrl!)) : null,
                child: profile.avatarUrl == null
                    ? Text(profile.name[0].toUpperCase(), style: TextStyle(fontSize: 40, color: colorScheme.onPrimary, fontWeight: FontWeight.bold))
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: colorScheme.surface, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]),
                    child: Icon(Icons.camera_alt, size: 20, color: colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(profile.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          Text(profile.mobile, style: TextStyle(fontSize: 14, color: colorScheme.secondary)),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('Online', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewMode(UserProfile profile, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildViewTile(Icons.person_outline, 'Name', profile.name, colorScheme),
        _buildViewTile(Icons.info_outline, 'Bio', profile.bio, colorScheme),
        _buildViewTile(Icons.phone_outlined, 'Mobile', profile.mobile, colorScheme, showEdit: false),
      ],
    );
  }

  Widget _buildViewTile(IconData icon, String label, String value, ColorScheme colorScheme, {bool showEdit = true}) {
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(label, style: TextStyle(fontSize: 12, color: colorScheme.secondary)),
      subtitle: Text(value, style: TextStyle(fontSize: 16, color: colorScheme.onSurface, fontWeight: FontWeight.w500)),
      trailing: showEdit ? Icon(Icons.edit, size: 16, color: colorScheme.secondary.withValues(alpha: 0.5)) : null,
      onTap: showEdit ? () => setState(() => _isEditing = true) : null,
    );
  }

  Widget _buildEditMode(ColorScheme colorScheme) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Name', prefixIcon: const Icon(Icons.person)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _bioController,
          maxLength: 139,
          decoration: InputDecoration(labelText: 'Bio', prefixIcon: const Icon(Icons.info), counterText: ''),
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        TextButton(onPressed: () => setState(() => _isEditing = false), child: const Text('Cancel')),
      ],
    );
  }

  Widget _buildStatsRow(ColorScheme colorScheme) {
    return Row(
      children: [
        _buildStatBox('128', 'Media', colorScheme),
        const SizedBox(width: 12),
        _buildStatBox('45', 'Links', colorScheme),
        const SizedBox(width: 12),
        _buildStatBox('12', 'Docs', colorScheme),
      ],
    );
  }

  Widget _buildStatBox(String count, String label, ColorScheme colorScheme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1))),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            Text(label, style: TextStyle(fontSize: 12, color: colorScheme.secondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showLogoutDialog(context, colorScheme),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _showDeleteDialog(context, colorScheme),
          child: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () {
            ref.read(settingsProvider.notifier).setBool('app_lock_enabled', false);
            Navigator.pop(context);
          }, child: const Text('Cancel')),
          TextButton(onPressed: () {
            context.go('/login');
          }, child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text('This action is permanent and cannot be undone. All your chats and media will be lost forever.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep Account')),
          TextButton(onPressed: () => context.go('/login'), child: const Text('Delete PERMANENTLY', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
