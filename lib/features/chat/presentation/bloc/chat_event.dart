import 'package:equatable/equatable.dart';
import 'package:llm_cpp_chat_app/core/constants/model_type.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class GetChatHistoryEvent extends ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String message;
  final String? modelPath;

  const SendMessageEvent({required this.message, this.modelPath});

  @override
  List<Object?> get props => [message, modelPath];
}

class MessageStreamingEvent extends ChatEvent {
  final String token;

  const MessageStreamingEvent({required this.token});

  @override
  List<Object?> get props => [token];
}

class ClearChatEvent extends ChatEvent {}

class SwitchModelTypeEvent extends ChatEvent {
  final ModelType modelType;
  final String? modelApiKey;
  final String? modelName;

  const SwitchModelTypeEvent({required this.modelType, this.modelApiKey, this.modelName});

  @override
  List<Object?> get props => [modelType, modelApiKey, modelName];
}

class InitializeModelEvent extends ChatEvent {
  final String modelPath;

  const InitializeModelEvent({required this.modelPath});

  @override
  List<Object?> get props => [modelPath];
}

class CompleteResponseEvent extends ChatEvent {}

class SubscriptionErrorEvent extends ChatEvent {
  final String error;

  const SubscriptionErrorEvent({required this.error});

  @override
  List<Object?> get props => [error];
}
