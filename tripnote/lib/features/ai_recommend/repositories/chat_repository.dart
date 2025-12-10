import '../../../core/network/api_client.dart';
import '../models/chat_model.dart';

class ChatRepository {
  final ApiClient _apiClient;

  ChatRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// 채팅 세션 목록 조회
  Future<List<ChatSession>> getSessions() async {
    final response = await _apiClient.get('/chat/sessions/');
    final List<dynamic> data =
        response.data is List ? response.data : response.data['results'] ?? [];
    return data.map((json) => ChatSession.fromJson(json)).toList();
  }

  /// 채팅 세션 상세 조회
  Future<ChatSession> getSession(int sessionId) async {
    final response = await _apiClient.get('/chat/sessions/$sessionId/');
    return ChatSession.fromJson(response.data);
  }

  /// 메시지 전송
  Future<Map<String, dynamic>> sendMessage(String message,
      {int? sessionId}) async {
    final response = await _apiClient.post(
      '/chat/send/',
      data: {
        'message': message,
        if (sessionId != null) 'session_id': sessionId,
      },
    );
    return {
      'session_id': response.data['session_id'] as int,
      'message': ChatMessage.fromJson(response.data['message']),
    };
  }

  /// 세션 삭제
  Future<void> deleteSession(int sessionId) async {
    await _apiClient.delete('/chat/sessions/$sessionId/');
  }
}
