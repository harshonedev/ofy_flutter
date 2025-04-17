import 'package:equatable/equatable.dart';

import '../../../../core/constants/model_type.dart';
import '../../domain/entities/message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  final ModelType modelType;
  final String? currentResponse;

  const ChatLoaded({
    required this.messages,
    required this.modelType,
    this.currentResponse,
  });

  @override
  List<Object?> get props => [messages, modelType, currentResponse];

  ChatLoaded copyWith({
    List<Message>? messages,
    ModelType? modelType,
    String? currentResponse,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      modelType: modelType ?? this.modelType,
      currentResponse: currentResponse ?? this.currentResponse,
    );
  }

  ChatLoaded appendToCurrentResponse(String token) {
    return copyWith(currentResponse: (currentResponse ?? '') + token);
  }

  ChatLoaded clearCurrentResponse() {
    return copyWith(currentResponse: '');
  }
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}
