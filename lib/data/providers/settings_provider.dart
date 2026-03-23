import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier extends StateNotifier<Map<String, dynamic>> {
  static const _notificationsKey = 'notifications_enabled';
  static const _groupNotificationsKey = 'group_notifications_enabled';
  static const _vibrationKey = 'vibration_enabled';
  static const _appLockKey = 'app_lock_enabled';
  static const _languageKey = 'selected_language';

  SettingsNotifier() : super({
    _notificationsKey: true,
    _groupNotificationsKey: true,
    _vibrationKey: true,
    _appLockKey: false,
    _languageKey: 'English',
  }) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = {
      _notificationsKey: prefs.getBool(_notificationsKey) ?? true,
      _groupNotificationsKey: prefs.getBool(_groupNotificationsKey) ?? true,
      _vibrationKey: prefs.getBool(_vibrationKey) ?? true,
      _appLockKey: prefs.getBool(_appLockKey) ?? false,
      _languageKey: prefs.getString(_languageKey) ?? 'English',
    };
  }

  Future<void> setBool(String key, bool value) async {
    state = {...state, key: value};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> setString(String key, String value) async {
    state = {...state, key: value};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Map<String, dynamic>>((ref) {
  return SettingsNotifier();
});

final notificationsEnabledProvider = Provider((ref) => ref.watch(settingsProvider)['notifications_enabled'] as bool);
final groupNotificationsProvider = Provider((ref) => ref.watch(settingsProvider)['group_notifications_enabled'] as bool);
final vibrationEnabledProvider = Provider((ref) => ref.watch(settingsProvider)['vibration_enabled'] as bool);
final appLockEnabledProvider = Provider((ref) => ref.watch(settingsProvider)['app_lock_enabled'] as bool);
final selectedLanguageProvider = Provider((ref) => ref.watch(settingsProvider)['selected_language'] as String);
