class ChatSession {
  final int id;
  final String title;
  final String? lastMessage;
  final DateTime updatedAt;
  final List<ChatMessage>? messages;

  ChatSession({
    required this.id,
    required this.title,
    this.lastMessage,
    required this.updatedAt,
    this.messages,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as int,
      title: json['title'] as String,
      lastMessage: json['last_message'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      messages: (json['messages'] as List?)
          ?.map((m) => ChatMessage.fromJson(m))
          .toList(),
    );
  }
}

class ChatMessage {
  final int? id;
  final String role;
  final String content;
  final DateTime? createdAt;

  ChatMessage({
    this.id,
    required this.role,
    required this.content,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int?,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}
