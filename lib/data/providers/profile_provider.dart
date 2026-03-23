import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String name;
  final String bio;
  final String mobile;
  final String? avatarUrl;
  final bool isOnline;

  UserProfile({
    required this.name,
    required this.bio,
    required this.mobile,
    this.avatarUrl,
    this.isOnline = true,
  });

  UserProfile copyWith({
    String? name,
    String? bio,
    String? mobile,
    String? avatarUrl,
    bool? isOnline,
  }) {
    return UserProfile(
      name: name ?? this.name,
      bio: bio ?? this.bio,
      mobile: mobile ?? this.mobile,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class ProfileNotifier extends StateNotifier<UserProfile> {
  static const _nameKey = 'profile_name';
  static const _bioKey = 'profile_bio';
  static const _mobileKey = 'profile_mobile';
  static const _avatarKey = 'profile_avatar';

  ProfileNotifier() : super(UserProfile(name: 'John Doe', bio: 'Living the dream!', mobile: '+91 9876543210')) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      name: prefs.getString(_nameKey) ?? state.name,
      bio: prefs.getString(_bioKey) ?? state.bio,
      mobile: prefs.getString(_mobileKey) ?? state.mobile,
      avatarUrl: prefs.getString(_avatarKey) ?? state.avatarUrl,
    );
  }

  Future<void> updateName(String name) async {
    state = state.copyWith(name: name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  Future<void> updateBio(String bio) async {
    state = state.copyWith(bio: bio);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bioKey, bio);
  }

  Future<void> updateAvatar(String? avatarUrl) async {
    state = state.copyWith(avatarUrl: avatarUrl);
    final prefs = await SharedPreferences.getInstance();
    if (avatarUrl != null) {
      await prefs.setString(_avatarKey, avatarUrl);
    } else {
      await prefs.remove(_avatarKey);
    }
  }
}

final userProfileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier();
});
