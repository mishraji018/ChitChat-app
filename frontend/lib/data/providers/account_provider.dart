import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account_model.dart';
import '../../core/services/api_service.dart';

class AccountNotifier extends StateNotifier<AsyncValue<AccountInfo>> {
  AccountNotifier(this._api) : super(const AsyncValue.loading()) {
    load();
  }

  final ApiService _api;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final data = await _api.getAccountInfo();
      final info = AccountInfo.fromJson(data);
      state = AsyncValue.data(info);
    } catch (_) {
      state = AsyncValue.data(AccountInfo.empty);
    }
  }

  Future<bool> updateEmail(String email) async {
    try {
      await _api.updateEmail(email);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestPhoneChange(String newPhone) async {
    try {
      await _api.requestPhoneChange(newPhone);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> confirmPhoneChange(String otp) async {
    try {
      await _api.confirmPhoneChange(otp);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addPasskey(String deviceName) async {
    try {
      await _api.addPasskey(deviceName);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removePasskey(String passkeyId) async {
    try {
      await _api.removePasskey(passkeyId);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      await _api.deleteAccount();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final accountProvider =
    StateNotifierProvider<AccountNotifier, AsyncValue<AccountInfo>>((ref) {
  return AccountNotifier(ref.read(apiServiceProvider));
});
