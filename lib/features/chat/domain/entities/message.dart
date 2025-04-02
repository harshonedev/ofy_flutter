enum MessageRole {
  user,
  assistant,
  system,
}

class Message {
  final String content;
  final MessageRole role;
  final DateTime timestamp;

  Message({
    required this.content,
    required this.role,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Message copyWith({
    String? content,
    MessageRole? role,
    DateTime? timestamp,
  }) {
    return Message(
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'role': role.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'] as String,
      role: MessageRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => MessageRole.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
