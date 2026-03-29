import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../../data/models/chat_model.dart';

class ApiService {
  static const String _baseUrl = kIsWeb
      ? 'http://localhost:5000/api'
      : 'http://10.0.2.2:5000/api';

  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  // Generic Rest Helpers (required by repositories)
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) {
    return _dio.delete(path, data: data);
  }

  // ── AUTH ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post('/auth/signup', data: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String userId,
    required String otp,
  }) async {
    final res = await _dio.post('/auth/verify-otp', data: {
      'userId': userId,
      'otp': otp,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<void> resendOtp(String userId) async {
    await _dio.post('/auth/resend-otp', data: {'userId': userId});
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
  }

  // ── CHATS (ERROR 1 FIX) ───────────────────────────────────────

  Future<List<ChatModel>> getChats() async {
    try {
      final res = await _dio.get('/chats');
      final list = res.data['chats'] as List<dynamic>? ?? [];
      return list
          .map((e) => ChatModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getChats Error: $e');
      return [];
    }
  }

  // ── PRIVACY ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> getPrivacySettings() async {
    final res = await _dio.get('/privacy');
    return (res.data['privacySettings'] ?? {}) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updatePrivacySettings(
      Map<String, dynamic> fields) async {
    final res = await _dio.put('/privacy', data: fields);
    return (res.data['privacySettings'] ?? {}) as Map<String, dynamic>;
  }

  // ── ACCOUNT ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAccountInfo() async {
    final res = await _dio.get('/account');
    return (res.data['account'] ?? {}) as Map<String, dynamic>;
  }

  Future<void> updateEmail(String email) async {
    await _dio.put('/account/email', data: {'email': email});
  }

  Future<void> requestPhoneChange(String newPhone) async {
    await _dio.post('/account/change-phone', data: {'newPhone': newPhone});
  }

  Future<void> confirmPhoneChange(String otp) async {
    await _dio.put('/account/change-phone/confirm', data: {'otp': otp});
  }

  Future<void> addPasskey(String deviceName) async {
    await _dio.post('/account/passkeys', data: {'deviceName': deviceName});
  }

  Future<void> removePasskey(String passkeyId) async {
    await _dio.delete('/account/passkeys/$passkeyId');
  }

  Future<void> deleteAccount() async {
    await _dio.delete('/account', data: {'confirmText': 'DELETE'});
  }

  // ── CONTACTS ──────────────────────────────────────────────────
  
  Future<Map<String, dynamic>> addContact({
    required String name,
    required String phone,
    String? avatar,
  }) async {
    final res = await _dio.post('/users/contacts', data: {
      'name': name,
      'phone': phone,
      'avatar': avatar,
    });
    return res.data;
  }

  Future<List<dynamic>> getBlockedUsers() async {
    final res = await _dio.get('/users/blocked');
    return res.data['data'] ?? [];
  }

  Future<void> blockUser(String userId) async {
    await _dio.put('/users/block/$userId');
  }

  Future<void> unblockUser(String userId) async {
    await _dio.put('/users/unblock/$userId');
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());