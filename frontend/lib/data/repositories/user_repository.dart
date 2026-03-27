import '../../core/services/api_service.dart';

class UserRepository {
  final ApiService _api;

  UserRepository(this._api);

  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _api.get('/users/$userId');
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> blockUser(String userId) async {
    try {
      final response = await _api.put('/users/block/$userId', data: {});
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> unblockUser(String userId) async {
    try {
      final response = await _api.put('/users/unblock/$userId', data: {});
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> muteConversation(String conversationId) async {
    try {
      final response = await _api.put('/users/mute/$conversationId', data: {});
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> unmuteConversation(String conversationId) async {
    try {
      final response = await _api.put('/users/unmute/$conversationId', data: {});
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
