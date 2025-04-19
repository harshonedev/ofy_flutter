import 'package:equatable/equatable.dart';

enum MessageRole { user, assistant, system }

class Message extends Equatable {
  final String content;
  final MessageRole role;
  final DateTime timestamp;

  Message({required this.content, required this.role, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();


  @override
  List<Object> get props => [content, role, timestamp];
}
