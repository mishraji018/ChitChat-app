import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';

class SettingsNotifier extends StateNotifier<Map<String, dynamic>> {
  static const _notificationsKey = 'notifications_enabled';
  static const _groupNotificationsKey = 'group_notifications_enabled';
  static const _vibrationKey = 'vibration_enabled';
  static const _appLockKey = 'app_lock_enabled';
  static const _languageKey = 'selected_language';
  static const _appPinKey = 'app_pin';
  static const _themeModeKey = 'theme_mode';
  static const _wallpaperTypeKey = 'wallpaper_type';
  static const _wallpaperValueKey = 'wallpaper_value';
  static const _lastSeenPrivacyKey = 'last_seen_privacy';
  static const _profilePhotoPrivacyKey = 'profile_photo_privacy';
  static const _aboutPrivacyKey = 'about_privacy';
  static const _statusPrivacyKey = 'status_privacy';
  static const _readReceiptsKey = 'read_receipts';
  static const _silenceUnknownCallersKey = 'silence_unknown_callers';
  static const _fontSizeKey = 'font_size';
  
  static const _convTonesKey = 'conv_tones';
  static const _msgToneKey = 'msg_tone';
  static const _msgVibrateKey = 'msg_vibrate';
  static const _msgPriorityKey = 'msg_priority';
  static const _groupToneKey = 'group_tone';
  static const _groupVibrateKey = 'group_vibrate';
  static const _groupPriorityKey = 'group_priority';
  static const _callRingtoneKey = 'call_ringtone';
  static const _callVibrateKey = 'call_vibrate';

  final ApiService _api;

  SettingsNotifier(this._api) : super({
    _notificationsKey: true,
    _groupNotificationsKey: true,
    _vibrationKey: true,
    _appLockKey: false,
    _languageKey: 'English',
    _appPinKey: '',
    _themeModeKey: 'light',
    _wallpaperTypeKey: 'default',
    _wallpaperValueKey: '',
    _lastSeenPrivacyKey: 'Everyone',
    _profilePhotoPrivacyKey: 'Everyone',
    _aboutPrivacyKey: 'Everyone',
    _statusPrivacyKey: 'Contacts',
    _readReceiptsKey: true,
    _silenceUnknownCallersKey: false,
    _fontSizeKey: 'Medium',
    _convTonesKey: true,
    _msgToneKey: 'Default',
    _msgVibrateKey: 'Default',
    _msgPriorityKey: true,
    _groupToneKey: 'Default',
    _groupVibrateKey: 'Default',
    _groupPriorityKey: true,
    _callRingtoneKey: 'Default',
    _callVibrateKey: 'Default',
    'app_biometrics_enabled': false,
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
      _appPinKey: '',  // PIN loaded separately from secure storage,
      _themeModeKey: prefs.getString(_themeModeKey) ?? 'light',
      _wallpaperTypeKey: prefs.getString(_wallpaperTypeKey) ?? 'default',
      _wallpaperValueKey: prefs.getString(_wallpaperValueKey) ?? '',
      _lastSeenPrivacyKey: prefs.getString(_lastSeenPrivacyKey) ?? 'Everyone',
      _profilePhotoPrivacyKey: prefs.getString(_profilePhotoPrivacyKey) ?? 'Everyone',
      _aboutPrivacyKey: prefs.getString(_aboutPrivacyKey) ?? 'Everyone',
      _statusPrivacyKey: prefs.getString(_statusPrivacyKey) ?? 'Contacts',
      _readReceiptsKey: prefs.getBool(_readReceiptsKey) ?? true,
      _silenceUnknownCallersKey: prefs.getBool(_silenceUnknownCallersKey) ?? false,
      _fontSizeKey: prefs.getString(_fontSizeKey) ?? 'Medium',
      _convTonesKey: prefs.getBool(_convTonesKey) ?? true,
      _msgToneKey: prefs.getString(_msgToneKey) ?? 'Default',
      _msgVibrateKey: prefs.getString(_msgVibrateKey) ?? 'Default',
      _msgPriorityKey: prefs.getBool(_msgPriorityKey) ?? true,
      _groupToneKey: prefs.getString(_groupToneKey) ?? 'Default',
      _groupVibrateKey: prefs.getString(_groupVibrateKey) ?? 'Default',
      _groupPriorityKey: prefs.getBool(_groupPriorityKey) ?? true,
      _callRingtoneKey: prefs.getString(_callRingtoneKey) ?? 'Default',
      _callVibrateKey: prefs.getString(_callVibrateKey) ?? 'Default',
      'app_biometrics_enabled': prefs.getBool('app_biometrics_enabled') ?? false,
    };
  }

  void _syncSettingsToBackend() {
    try {
      // Don't send PIN to backend
      final safeState = Map<String, dynamic>.from(state);
      safeState.remove(_appPinKey);
      _api.put('/users/settings', data: safeState);
    } catch (_) {}
  }

  /// Called after auth to load the PIN from device secure storage.
  Future<void> loadSecurePinForUser(String userId) async {
    final pin = await StorageService.getPinForUser(userId);
    state = {...state, _appPinKey: pin ?? ''};
    if ((pin == null || pin.isEmpty)) {
      // No PIN found — disable lock automatically
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_appLockKey, false);
      state = {...state, _appLockKey: false};
    }
  }

  Future<void> syncSettingsFromBackend() async {
    try {
      final response = await _api.get('/auth/me');
      if (response.statusCode == 200 && response.data['success']) {
        final Map<String, dynamic> remoteSettings = response.data['data']['settings'] ?? {};
        if (remoteSettings.isNotEmpty) {
          state = {...state, ...remoteSettings};
          final prefs = await SharedPreferences.getInstance();
          for (final key in remoteSettings.keys) {
            final val = remoteSettings[key];
            if (val is bool) {
              await prefs.setBool(key, val);
            } else if (val is String) {
              await prefs.setString(key, val);
            } else if (val is int) {
              await prefs.setInt(key, val);
            } else if (val is double) {
              await prefs.setDouble(key, val);
            }
          }
        }
      }
    } catch (_) {}
  }

  void setCurrentUserId(String userId) {
    state = {...state, 'current_user_id': userId};
  }

  Future<void> setBool(String key, bool value) async {
    state = {...state, key: value};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    _syncSettingsToBackend();
  }

  Future<void> setString(String key, String value) async {
    state = {...state, key: value};
    if (key == _appPinKey) {
      // PIN is always saved to device secure storage, NOT shared prefs
      final userId = state['current_user_id'] as String?;
      if (userId != null && userId.isNotEmpty) {
        await StorageService.savePinForUser(userId, value);
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
    _syncSettingsToBackend();
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = {
      _notificationsKey: true,
      _groupNotificationsKey: true,
      _vibrationKey: true,
      _appLockKey: false,
      _languageKey: 'English',
      _appPinKey: '',
      _themeModeKey: 'light',
      _wallpaperTypeKey: 'default',
      _wallpaperValueKey: '',
      _lastSeenPrivacyKey: 'Everyone',
      _profilePhotoPrivacyKey: 'Everyone',
      _aboutPrivacyKey: 'Everyone',
      _statusPrivacyKey: 'Contacts',
      _readReceiptsKey: true,
      _silenceUnknownCallersKey: false,
      _fontSizeKey: 'Medium',
    };
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Map<String, dynamic>>((ref) {
  return SettingsNotifier(ref.read(apiServiceProvider));
});

final notificationsEnabledProvider = Provider((ref) => (ref.watch(settingsProvider)['notifications_enabled'] ?? true) as bool);
final groupNotificationsProvider = Provider((ref) => (ref.watch(settingsProvider)['group_notifications_enabled'] ?? true) as bool);
final vibrationEnabledProvider = Provider((ref) => (ref.watch(settingsProvider)['vibration_enabled'] ?? true) as bool);
final appLockEnabledProvider = Provider((ref) => (ref.watch(settingsProvider)['app_lock_enabled'] ?? false) as bool);
final selectedLanguageProvider = Provider((ref) => (ref.watch(settingsProvider)['selected_language'] ?? 'English') as String);
final appPinProvider = Provider((ref) => (ref.watch(settingsProvider)['app_pin'] ?? '') as String);
final wallpaperTypeProvider = Provider((ref) => (ref.watch(settingsProvider)['wallpaper_type'] ?? 'default') as String);
final wallpaperValueProvider = Provider((ref) => (ref.watch(settingsProvider)['wallpaper_value'] ?? '') as String);
final fontSizeProvider = Provider((ref) => (ref.watch(settingsProvider)['font_size'] ?? 'Medium') as String);

final chatFontSizeProvider = Provider<double>((ref) {
  final sizeStr = ref.watch(fontSizeProvider);
  switch (sizeStr) {
    case 'Small': return 13.0;
    case 'Large': return 18.0;
    default: return 15.0; // Medium
  }
});

// Privacy Providers
final lastSeenPrivacyProvider = Provider((ref) => (ref.watch(settingsProvider)['last_seen_privacy'] ?? 'Everyone') as String);
final profilePhotoPrivacyProvider = Provider((ref) => (ref.watch(settingsProvider)['profile_photo_privacy'] ?? 'Everyone') as String);
final aboutPrivacyProvider = Provider((ref) => (ref.watch(settingsProvider)['about_privacy'] ?? 'Everyone') as String);
final statusPrivacyProvider = Provider((ref) => (ref.watch(settingsProvider)['status_privacy'] ?? 'Contacts') as String);
final readReceiptsProvider = Provider((ref) => (ref.watch(settingsProvider)['read_receipts'] ?? true) as bool);
final silenceUnknownCallersProvider = Provider((ref) => (ref.watch(settingsProvider)['silence_unknown_callers'] ?? false) as bool);

// Extra Notification Providers
final convTonesProvider = Provider((ref) => (ref.watch(settingsProvider)['conv_tones'] ?? true) as bool);
final msgToneProvider = Provider((ref) => (ref.watch(settingsProvider)['msg_tone'] ?? 'Default') as String);
final msgVibrateProvider = Provider((ref) => (ref.watch(settingsProvider)['msg_vibrate'] ?? 'Default') as String);
final msgPriorityProvider = Provider((ref) => (ref.watch(settingsProvider)['msg_priority'] ?? true) as bool);

final groupToneProvider = Provider((ref) => (ref.watch(settingsProvider)['group_tone'] ?? 'Default') as String);
final groupVibrateProvider = Provider((ref) => (ref.watch(settingsProvider)['group_vibrate'] ?? 'Default') as String);
final groupPriorityProvider = Provider((ref) => (ref.watch(settingsProvider)['group_priority'] ?? true) as bool);

final callRingtoneProvider = Provider((ref) => (ref.watch(settingsProvider)['call_ringtone'] ?? 'Default') as String);
final callVibrateProvider = Provider((ref) => (ref.watch(settingsProvider)['call_vibrate'] ?? 'Default') as String);

final appBiometricsEnabledProvider = Provider((ref) => (ref.watch(settingsProvider)['app_biometrics_enabled'] ?? false) as bool);
