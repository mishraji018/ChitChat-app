import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/v2/api_service.dart';
import '../../services/v2/socket_service.dart';

/// Manages authentication state across the whole app.
/// Wrap your MaterialApp with ChangeNotifierProvider<AuthProvider>.
///
/// Usage in widget:
///   final auth = context.watch<AuthProvider>();
///   if (auth.isLoggedIn) { ... }
class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get userId => _user?['_id'] ?? _user?['id'] ?? '';
  String get userName => _user?['name'] ?? '';
  String get userAvatar => _user?['avatar'] ?? '';
  String get userPhone => _user?['phone'] ?? '';
  String get userStatus => _user?['status'] ?? '';

  // ─── Init: restore session on app launch ──────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUser = prefs.getString('current_user');
      final token = await ApiService.getToken();

      if (savedUser != null && token != null) {
        _user = jsonDecode(savedUser);
        notifyListeners();

        // Re-fetch fresh user data from server
        final fresh = await ApiService.getMe();
        _user = fresh['user'] ?? fresh;
        await prefs.setString('current_user', jsonEncode(_user));

        // Re-connect socket
        await SocketService.instance.connect();
      }
    } catch (e) {
      // Token expired or network issue — log out silently
      await ApiService.clearToken();
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Register ─────────────────────────────────────────────────────────────────

  Future<bool> register({
    required String name,
    required String phone,
    String? email,
  }) async {
    _setLoading(true);
    try {
      await ApiService.register(name: name, phone: phone, email: email);
      _clearError();
      return true; // Navigate to OTP screen
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Verify OTP ───────────────────────────────────────────────────────────────

  Future<bool> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    _setLoading(true);
    try {
      final data = await ApiService.verifyOtp(phone: phone, otp: otp);
      _user = data['user'];

      // Save user locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(_user));

      // Connect socket after login
      await SocketService.instance.connect();

      _clearError();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Update Profile ───────────────────────────────────────────────────────────

  Future<bool> updateProfile(Map<String, dynamic> fields) async {
    _setLoading(true);
    try {
      final data = await ApiService.updateProfile(fields);
      _user = data['user'] ?? data;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(_user));

      _clearError();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    SocketService.instance.disconnect();
    await ApiService.logout();
    _user = null;
    _clearError();
    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
