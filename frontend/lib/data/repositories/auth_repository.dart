import 'dart:convert';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService _api;
  AuthRepository(this._api);

  Future<({String userId})> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = await _api.signup(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    return (userId: data['userId'] as String);
  }

  Future<UserModel> verifyOtp({
    required String userId,
    required String otp,
  }) async {
    final data = await _api.verifyOtp(userId: userId, otp: otp);
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await StorageService.saveToken(token);
    await StorageService.saveUser(jsonEncode(user.toJson()));

    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.login(email: email, password: password);
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await StorageService.saveToken(token);
    await StorageService.saveUser(jsonEncode(user.toJson()));

    return user;
  }

  Future<void> resendOtp(String userId) async {
    await _api.resendOtp(userId);
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}
    await StorageService.clearAll();
  }

  Future<UserModel?> getStoredUser() async {
    final json = await StorageService.getUser();
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<bool> isLoggedIn() async {
    final token = await StorageService.getToken();
    return token != null && token.isNotEmpty;
  }
}
