import 'package:equatable/equatable.dart';

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
  final bool useLocalModel;

  const SwitchModelTypeEvent({required this.useLocalModel});

  @override
  List<Object?> get props => [useLocalModel];
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
