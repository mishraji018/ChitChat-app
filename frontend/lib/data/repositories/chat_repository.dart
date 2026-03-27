import '../../core/services/api_service.dart';

class ChatRepository {
  final ApiService _api;

  ChatRepository(this._api);

  Future<Map<String, dynamic>> clearChat(String conversationId) async {
    try {
      final response = await _api.delete('/chats/$conversationId/clear');
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
