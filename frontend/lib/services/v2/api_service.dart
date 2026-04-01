import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 🔧 CHANGE THIS to your backend IP/URL
  // For Android Emulator:  http://10.0.2.2:5000
  // For Physical Device:   http://YOUR_LOCAL_IP:5000  (e.g. http://192.168.1.5:5000)
  // For Production:        https://your-deployed-backend.com
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // ─── Token Helpers ───────────────────────────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Generic Request Helpers ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _get(String path) async {
    final headers = await _authHeaders();
    final response = await http.get(Uri.parse('$baseUrl$path'), headers: headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> _delete(String path) async {
    final headers = await _authHeaders();
    final response = await http.delete(Uri.parse('$baseUrl$path'), headers: headers);
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final message = body['message'] ?? body['error'] ?? 'Something went wrong';
      throw ApiException(message, response.statusCode);
    }
  }

  // ─── AUTH ─────────────────────────────────────────────────────────────────────

  /// Register user with phone number — triggers OTP
  static Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    String? email,
  }) async {
    return _post('/auth/register', {
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
    });
  }

  /// Verify OTP — returns JWT token + user data
  static Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final data = await _post('/auth/verify', {'phone': phone, 'otp': otp});
    if (data['token'] != null) {
      await saveToken(data['token']);
      // Save current user locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(data['user']));
    }
    return data;
  }

  /// Get current logged-in user
  static Future<Map<String, dynamic>> getMe() => _get('/auth/me');

  /// Update profile (name, status, avatar, about)
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> fields) =>
      _put('/auth/profile', fields);

  /// Logout
  static Future<void> logout() async {
    try {
      await _post('/auth/logout', {});
    } catch (_) {}
    await clearToken();
  }

  // ─── USERS ────────────────────────────────────────────────────────────────────

  /// Search users by name or phone
  static Future<List<dynamic>> searchUsers(String query) async {
    final data = await _get('/users/search?q=${Uri.encodeComponent(query)}');
    return data['users'] ?? data['data'] ?? [];
  }

  /// Get user by ID
  static Future<Map<String, dynamic>> getUserById(String userId) =>
      _get('/users/$userId');

  /// Sync contacts (pass list of phone numbers)
  static Future<List<dynamic>> syncContacts(List<String> phones) async {
    final data = await _post('/users/sync', {'phones': phones});
    return data['contacts'] ?? data['data'] ?? [];
  }

  /// Add a contact
  static Future<Map<String, dynamic>> addContact({
    required String name,
    required String phone,
  }) =>
      _post('/users/contacts', {'name': name, 'phone': phone});

  /// Block a user
  static Future<void> blockUser(String userId) =>
      _put('/users/block/$userId', {});

  /// Unblock a user
  static Future<void> unblockUser(String userId) =>
      _put('/users/unblock/$userId', {});

  /// Mute a conversation
  static Future<void> muteConversation(String conversationId) =>
      _put('/users/mute/$conversationId', {});

  /// Unmute a conversation
  static Future<void> unmuteConversation(String conversationId) =>
      _put('/users/unmute/$conversationId', {});

  /// Update app settings
  static Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> settings) =>
      _put('/users/settings', settings);

  /// Get blocked users
  static Future<List<dynamic>> getBlockedUsers() async {
    final data = await _get('/users/blocked');
    return data['blocked'] ?? data['data'] ?? [];
  }

  // ─── CHATS ────────────────────────────────────────────────────────────────────

  /// Get all conversations for current user
  static Future<List<dynamic>> getChats() async {
    final data = await _get('/chats');
    return data['chats'] ?? data['data'] ?? [];
  }

  /// Get a single conversation by ID
  static Future<Map<String, dynamic>> getChatById(String chatId) =>
      _get('/chats/$chatId');

  /// Create or open a 1-on-1 conversation
  static Future<Map<String, dynamic>> createChat(String participantId) =>
      _post('/chats', {'participantId': participantId});

  /// Create a group chat
  static Future<Map<String, dynamic>> createGroupChat({
    required String groupName,
    required List<String> participantIds,
    String? groupAvatar,
  }) =>
      _post('/chats/group', {
        'groupName': groupName,
        'participants': participantIds,
        if (groupAvatar != null) 'groupAvatar': groupAvatar,
      });

  /// Get messages for a conversation (paginated)
  static Future<List<dynamic>> getMessages(String chatId, {int page = 1, int limit = 30}) async {
    final data = await _get('/chats/$chatId/messages?page=$page&limit=$limit');
    return data['messages'] ?? data['data'] ?? [];
  }

  /// Send a message via REST (fallback; prefer Socket for real-time)
  static Future<Map<String, dynamic>> sendMessage(
    String chatId, {
    required String text,
    String type = 'text',
    String? mediaUrl,
    String? replyTo,
    int? duration,
  }) =>
      _post('/chats/$chatId/messages', {
        'text': text,
        'type': type,
        if (mediaUrl != null) 'mediaUrl': mediaUrl,
        if (replyTo != null) 'replyTo': replyTo,
        if (duration != null) 'duration': duration,
      });

  /// Edit a message
  static Future<Map<String, dynamic>> editMessage(String messageId, String newText) =>
      _put('/chats/messages/$messageId', {'text': newText});

  /// Delete a message
  static Future<void> deleteMessage(String messageId) =>
      _delete('/chats/messages/$messageId');

  /// React to a message
  static Future<void> reactToMessage(String messageId, String emoji) =>
      _post('/chats/messages/$messageId/react', {'emoji': emoji});

  /// Clear all messages in a chat
  static Future<void> clearChat(String chatId) =>
      _delete('/chats/$chatId/clear');

  // ─── MEDIA ────────────────────────────────────────────────────────────────────

  /// Upload a file (image, pdf, voice, video)
  static Future<Map<String, dynamic>> uploadMedia(File file) async {
    final token = await getToken();
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/media/upload'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  /// Delete uploaded media by Cloudinary public_id
  static Future<void> deleteMedia(String publicId) =>
      _delete('/media/${Uri.encodeComponent(publicId)}');

  // ─── PRIVACY ──────────────────────────────────────────────────────────────────

  /// Get privacy settings
  static Future<Map<String, dynamic>> getPrivacySettings() =>
      _get('/privacy');

  /// Update privacy settings
  static Future<Map<String, dynamic>> updatePrivacySettings(Map<String, dynamic> settings) =>
      _put('/privacy', settings);

  /// Get blocked contacts
  static Future<List<dynamic>> getBlockedContacts() async {
    final data = await _get('/privacy/blocked');
    return data['blocked'] ?? data['data'] ?? [];
  }

  /// Block a contact via privacy route
  static Future<void> blockContact(String contactId) =>
      _post('/privacy/blocked', {'contactId': contactId});

  /// Unblock a contact via privacy route
  static Future<void> unblockContact(String contactId) =>
      _delete('/privacy/blocked/$contactId');

  // ─── ACCOUNT ──────────────────────────────────────────────────────────────────

  /// Get account info
  static Future<Map<String, dynamic>> getAccount() => _get('/account');

  /// Update email
  static Future<Map<String, dynamic>> updateEmail(String email) =>
      _put('/account/email', {'email': email});

  /// Request phone number change (sends OTP)
  static Future<Map<String, dynamic>> requestPhoneChange(String newPhone) =>
      _post('/account/change-phone', {'phone': newPhone});

  /// Confirm phone number change with OTP
  static Future<Map<String, dynamic>> confirmPhoneChange(String otp) =>
      _put('/account/change-phone/confirm', {'otp': otp});

  /// Delete account permanently
  static Future<void> deleteAccount() => _delete('/account');

  /// Get passkeys
  static Future<List<dynamic>> getPasskeys() async {
    final data = await _get('/account/passkeys');
    return data['passkeys'] ?? data['data'] ?? [];
  }

  /// Add a passkey
  static Future<Map<String, dynamic>> addPasskey(String id, String deviceName) =>
      _post('/account/passkeys', {'id': id, 'deviceName': deviceName});

  /// Remove a passkey
  static Future<void> removePasskey(String passkeyId) =>
      _delete('/account/passkeys/$passkeyId');
}

// ─── Custom Exception ─────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
