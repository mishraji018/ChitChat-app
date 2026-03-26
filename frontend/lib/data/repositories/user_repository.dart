import '../../core/services/api_service.dart';

class UserRepository {
  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await ApiService.get('/users/$userId');
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> blockUser(String userId) async {
    try {
      final response = await ApiService.put('/users/block/$userId', {});
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> unblockUser(String userId) async {
    try {
      final response = await ApiService.put('/users/unblock/$userId', {});
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> muteConversation(String conversationId) async {
    try {
      final response = await ApiService.put('/users/mute/$conversationId', {});
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> unmuteConversation(String conversationId) async {
    try {
      final response = await ApiService.put('/users/unmute/$conversationId', {});
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
