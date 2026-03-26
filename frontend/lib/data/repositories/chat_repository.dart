import '../../core/services/api_service.dart';

class ChatRepository {
  Future<Map<String, dynamic>> clearChat(String conversationId) async {
    try {
      final response = await ApiService.delete('/chats/$conversationId/clear');
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
