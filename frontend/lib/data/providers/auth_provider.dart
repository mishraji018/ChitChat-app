import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../../core/services/api_service.dart';

// ── State ─────────────────────────────────────────────────────────

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final String? pendingUserId;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.pendingUserId,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    String? pendingUserId,
    bool clearUser = false,
    bool clearError = false,
    bool clearPendingUserId = false,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        user: clearUser ? null : user ?? this.user,
        error: clearError ? null : error ?? this.error,
        pendingUserId: clearPendingUserId ? null : pendingUserId ?? this.pendingUserId,
      );

  bool get isAuthenticated => user != null;
}

// ── Notifier ──────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState()) {
    _checkStoredSession();
  }

  final AuthRepository _repo;

  Future<void> _checkStoredSession() async {
    try {
      final user = await _repo.getStoredUser();
      if (user != null && user.id.isNotEmpty) {
        state = state.copyWith(user: user);
      }
    } catch (_) {}
  }

  Future<String?> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      state = state.copyWith(isLoading: false, pendingUserId: result.userId);
      return result.userId;
    } on DioException catch (e) {
      final msg = _extractError(e);
      state = state.copyWith(isLoading: false, error: msg);
      return null;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Signup failed. Try again.');
      return null;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    final userId = state.pendingUserId;
    if (userId == null) {
      state = state.copyWith(error: 'Session expired. Please sign up again.');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.verifyOtp(userId: userId, otp: otp);
      state = state.copyWith(
        isLoading: false,
        user: user,
        clearPendingUserId: true,
      );
      return true;
    } on DioException catch (e) {
      final msg = _extractError(e);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Verification failed.');
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.login(email: email, password: password);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } on DioException catch (e) {
      final msg = _extractError(e);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Login failed. Try again.');
      return false;
    }
  }

  Future<void> resendOtp() async {
    final userId = state.pendingUserId;
    if (userId == null) return;
    try {
      await _repo.resendOtp(userId);
    } catch (_) {}
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(clearError: true);

  String _extractError(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) return data['message'] as String;
    } catch (_) {}
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Check your network.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot reach server. Is backend running?';
    }
    return 'Something went wrong.';
  }
}

// ── Providers ─────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiServiceProvider));
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
