import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final Map<String, dynamic>? user;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    Map<String, dynamic>? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo = AuthRepository();

  AuthNotifier() : super(const AuthState());

  Future<void> checkAuth() async {
    final token = await StorageService.getToken();
    if (token != null) {
      ApiService.setAuthToken(token);
      final userJson = await StorageService.getUser();
      if (userJson != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: jsonDecode(userJson),
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String mobile, String passkey) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _repo.login(mobile: mobile, passkey: passkey);
    if (result['success']) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: result['data']['user'],
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result['message'],
      );
      return false;
    }
  }

  Future<bool> signup(String name, String mobile, String email, String passkey) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _repo.signup(
      name: name, mobile: mobile, email: email, passkey: passkey
    );
    if (result['success']) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result['message'],
      );
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _repo.verifyOtp(email: email, otp: otp);
    if (result['success']) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: result['data']['user'],
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result['message'],
      );
      return false;
    }
  }

  Future<void> logout() async {
    final userId = state.user?['id'] as String?;
    if (userId != null) {
      await StorageService.clearPinForUser(userId);
    }
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
