import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  static const FlutterSecureStorage _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── TOKEN ─────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } else {
      await _secure.write(key: _tokenKey, value: token);
    }
  }

  static Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    }
    return await _secure.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } else {
      await _secure.delete(key: _tokenKey);
    }
  }

  // ── USER ──────────────────────────────────────────────────────

  static Future<void> saveUser(String userJson) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, userJson);
    } else {
      await _secure.write(key: _userKey, value: userJson);
    }
  }

  static Future<String?> getUser() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userKey);
    }
    return await _secure.read(key: _userKey);
  }

  static Future<void> deleteUser() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } else {
      await _secure.delete(key: _userKey);
    }
  }

  // ── CLEAR ALL ─────────────────────────────────────────────────

  static Future<void> clearAll() async {
    await deleteToken();
    await deleteUser();
  }

  // --- App Lock PIN (per-user, device-local) ---
  static Future<void> savePinForUser(String userId, String pin) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_pin_$userId', pin);
    } else {
      await _secure.write(key: 'app_pin_$userId', value: pin);
    }
  }

  static Future<String?> getPinForUser(String userId) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('app_pin_$userId');
    }
    return await _secure.read(key: 'app_pin_$userId');
  }

  static Future<void> clearPinForUser(String userId) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_pin_$userId');
    } else {
      await _secure.delete(key: 'app_pin_$userId');
    }
  }
}
