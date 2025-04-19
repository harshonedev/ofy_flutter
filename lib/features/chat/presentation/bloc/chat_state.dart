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
  final bool? isChatFinished;

  const ChatLoaded({
    required this.messages,
    required this.modelType,
    this.currentResponse,
    this.isChatFinished,
  });

  @override
  List<Object?> get props => [messages, modelType, currentResponse];

  ChatLoaded copyWith({
    List<Message>? messages,
    ModelType? modelType,
    String? currentResponse,
    bool? isChatFinished,

  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      modelType: modelType ?? this.modelType,
      currentResponse: currentResponse ?? this.currentResponse,
      isChatFinished: isChatFinished ?? this.isChatFinished,
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
  final List<Message>? messages;

  const ChatError({required this.message, this.messages});

  @override
  List<Object?> get props => [message];
}
