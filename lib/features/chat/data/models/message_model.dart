import 'package:llm_cpp_chat_app/features/chat/data/datasources/remote_chat_datasource.dart';

import '../../domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required super.content,
    required super.role,
    super.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      content: json['content'],
      role: _roleFromString(json['role']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }


 

  ApiMessageParams toApiMessageParams() {
    return ApiMessageParams(
      content: content,
      role: _roleToString(role),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'role': _roleToString(role),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForApi() {
    return {
      'content': content,
      'role': _roleToString(role),
    };
  }

  static MessageRole _roleFromString(String role) {
    switch (role) {
      case 'user':
        return MessageRole.user;
      case 'assistant':
        return MessageRole.assistant;
      case 'system':
        return MessageRole.system;
      default:
        return MessageRole.user;
    }
  }

  static String _roleToString(MessageRole role) {
    switch (role) {
      case MessageRole.user:
        return 'user';
      case MessageRole.assistant:
        return 'assistant';
      case MessageRole.system:
        return 'system';
      }
  }
}
