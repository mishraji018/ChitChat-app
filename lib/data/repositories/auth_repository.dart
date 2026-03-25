import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';

class AuthRepository {

  // SIGNUP
  Future<Map<String, dynamic>> signup({
    required String name,
    required String mobile,
    required String email,
    required String passkey,
  }) async {
    try {
      final response = await ApiService.post('/auth/signup', {
        'name': name,
        'mobile': mobile,
        'email': email,
        'passkey': passkey,
      });
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Signup failed'
      };
    }
  }

  // VERIFY OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await ApiService.post('/auth/verify-otp', {
        'email': email,
        'otp': otp,
      });
      // Save token on success
      if (response.data['token'] != null) {
        await StorageService.saveToken(response.data['token']);
        await StorageService.saveUser(
          jsonEncode(response.data['user'])
        );
        ApiService.setAuthToken(response.data['token']);
      }
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'OTP verification failed'
      };
    }
  }

  // LOGIN
  Future<Map<String, dynamic>> login({
    required String mobile,
    required String passkey,
  }) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'mobile': mobile,
        'passkey': passkey,
      });
      // Save token on success
      if (response.data['token'] != null) {
        await StorageService.saveToken(response.data['token']);
        await StorageService.saveUser(
          jsonEncode(response.data['user'])
        );
        ApiService.setAuthToken(response.data['token']);
      }
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Login failed'
      };
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout', {});
    } catch (e) {
      // ignore error, clear locally anyway
    }
    await StorageService.clearAll();
    ApiService.clearAuthToken();
  }

  // FORGOT PASSKEY
  Future<Map<String, dynamic>> forgotPasskey({
    required String mobile,
  }) async {
    try {
      final response = await ApiService.post('/auth/forgot-passkey', {
        'mobile': mobile,
      });
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed'
      };
    }
  }

  // RESEND OTP
  Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    try {
      final response = await ApiService.post('/auth/resend-otp', {
        'email': email,
      });
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed'
      };
    }
  }
}
