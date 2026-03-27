import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/privacy_model.dart';
import '../../core/services/api_service.dart';

class PrivacyNotifier extends StateNotifier<AsyncValue<PrivacySettings>> {
  PrivacyNotifier(this._api) : super(const AsyncValue.loading()) {
    load();
  }

  final ApiService _api;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final data = await _api.getPrivacySettings();
      final settings = PrivacySettings.fromJson(data);
      state = AsyncValue.data(settings);
    } catch (_) {
      // Dev mode / backend not connected → use defaults silently
      state = AsyncValue.data(PrivacySettings.defaults);
    }
  }

  Future<void> updateField(Map<String, dynamic> fields) async {
    final prev = state;
    if (prev is! AsyncData<PrivacySettings>) return;

    // Optimistic update
    state = AsyncValue.data(_merge(prev.value, fields));

    try {
      final data = await _api.updatePrivacySettings(fields);
      final updated = PrivacySettings.fromJson(data);
      state = AsyncValue.data(updated);
    } catch (_) {
      state = prev; // Revert on failure
    }
  }

  PrivacySettings _merge(PrivacySettings current, Map<String, dynamic> f) {
    return current.copyWith(
      lastSeen: f['lastSeen'] as String?,
      profilePhoto: f['profilePhoto'] as String?,
      about: f['about'] as String?,
      status: f['status'] as String?,
      readReceipts: f['readReceipts'] as bool?,
      silenceUnknownCallers: f['silenceUnknownCallers'] as bool?,
      defaultMessageTimer: f['defaultMessageTimer'] as int?,
      appLock: f['appLock'] as bool?,
    );
  }
}

final privacyProvider =
    StateNotifierProvider<PrivacyNotifier, AsyncValue<PrivacySettings>>((ref) {
  return PrivacyNotifier(ref.read(apiServiceProvider));
});
