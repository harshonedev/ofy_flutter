import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_cpp_chat_app/features/chat/data/services/model_service_impl.dart';

import '../../../../core/constants/model_type.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/message.dart';
import '../../domain/services/model_service_interface.dart';
import '../../domain/usecases/clear_chat_history.dart';
import '../../domain/usecases/get_chat_history.dart';
import '../../domain/usecases/send_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatHistory getChatHistory;
  final SendMessage sendMessage;
  final ClearChatHistory clearChatHistory;
  final ModelServiceInterface modelService;

  ModelType _currentModelType = ModelType.local;
  String? _modelPath;
  StreamSubscription? _modelResponseSubscription;

  ChatBloc({
    required this.getChatHistory,
    required this.sendMessage,
    required this.clearChatHistory,
    required this.modelService,
  }) : super(ChatInitial()) {
    on<GetChatHistoryEvent>(_onGetChatHistory);
    on<SendMessageEvent>(_onSendMessage);
    on<MessageStreamingEvent>(_onMessageStreaming);
    on<ClearChatEvent>(_onClearChat);
    on<SwitchModelTypeEvent>(_onSwitchModelType);
    on<InitializeModelEvent>(_onInitializeModel);
    on<CompleteResponseEvent>(_onCompleteResponse);

    // Subscribe to model responses
    _subscribeToModelResponses();
  }

  void _subscribeToModelResponses() {
    _modelResponseSubscription?.cancel();
    _modelResponseSubscription = modelService.responseStream.listen(
      (response) {
        // Check if this is the completion marker
        if (response == ModelServiceImpl.completionMarker) {
          // Signal that the response is complete
          add(CompleteResponseEvent());
          return;
        }

        // Stream tokens as they come in
        add(MessageStreamingEvent(token: response));
      },
      onError: (error) {
        emit(ChatError(message: error.toString()));
      },
    );
  }

  void initializeModelPath(String modelPath) {
    _modelPath = modelPath;
    add(InitializeModelEvent(modelPath: modelPath));
  }

  Future<void> _onInitializeModel(
    InitializeModelEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      final success = await modelService.loadModel(event.modelPath);

      if (success) {
        final result = await getChatHistory(NoParams());

        result.fold(
          (failure) => emit(ChatError(message: failure.toString())),
          (messages) => emit(
            ChatLoaded(messages: messages, modelType: _currentModelType),
          ),
        );
      } else {
        emit(const ChatError(message: 'Failed to load model'));
      }
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onGetChatHistory(
    GetChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final result = await getChatHistory(NoParams());

    result.fold(
      (failure) => emit(ChatError(message: failure.toString())),
      (messages) =>
          emit(ChatLoaded(messages: messages, modelType: _currentModelType)),
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;

      // Add user message immediately
      final userMessage = Message(
        content: event.message,
        role: MessageRole.user,
      );

      final updatedMessages = List<Message>.from(currentState.messages)
        ..add(userMessage);

      emit(
        currentState.copyWith(messages: updatedMessages).clearCurrentResponse(),
      );

      if (_currentModelType == ModelType.local) {
        // Use local model inference
        try {
          if (_modelPath == null) {
            emit(const ChatError(message: 'Model path not initialized'));
            return;
          }

          // Build prompt from conversation history
          final prompt = modelService.buildPrompt(updatedMessages);

          // Send to model service for processing
          await modelService.sendPrompt(prompt);

          // The streaming responses will be handled by the subscription
        } catch (e) {
          emit(ChatError(message: 'Error processing message: ${e.toString()}'));
        }
      } else {
        // Use remote API (OpenAI, etc.)
        final params = SendMessageParams(
          content: event.message,
          modelPath: event.modelPath ?? _modelPath,
        );

        final result = await sendMessage(params);

        result.fold((failure) => emit(ChatError(message: failure.toString())), (
          assistantMessage,
        ) {
          if (state is ChatLoaded) {
            final latestState = state as ChatLoaded;
            final finalMessages = List<Message>.from(latestState.messages)
              ..add(assistantMessage);

            emit(
              latestState
                  .copyWith(messages: finalMessages)
                  .clearCurrentResponse(),
            );
          }
        });
      }
    }
  }

  void _onMessageStreaming(
    MessageStreamingEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(currentState.appendToCurrentResponse(event.token));
    }
  }

  Future<void> _onClearChat(
    ClearChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());

    final result = await clearChatHistory(NoParams());

    result.fold(
      (failure) => emit(ChatError(message: failure.toString())),
      (_) => emit(ChatLoaded(messages: const [], modelType: _currentModelType)),
    );
  }

  void _onSwitchModelType(SwitchModelTypeEvent event, Emitter<ChatState> emit) {
    _currentModelType =
        event.useLocalModel ? ModelType.local : ModelType.openAi;

    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(currentState.copyWith(modelType: _currentModelType));
    } else {
      emit(ChatLoaded(messages: const [], modelType: _currentModelType));
    }
  }

  void _onCompleteResponse(
    CompleteResponseEvent event,
    Emitter<ChatState> emit,
  ) {
    // If we have a current response in the state, add it as a complete message
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final currentResponse = currentState.currentResponse;

      if (currentResponse != null && currentResponse.isNotEmpty) {
        // Create a new assistant message with the complete response
        final assistantMessage = Message(
          content: currentResponse,
          role: MessageRole.assistant,
        );

        // Add it to the message list
        final updatedMessages = List<Message>.from(currentState.messages)
          ..add(assistantMessage);

        // Emit new state with the message added and current response cleared
        emit(
          currentState
              .copyWith(messages: updatedMessages)
              .clearCurrentResponse(),
        );
      }
    }
  }

  @override
  Future<void> close() {
    _modelResponseSubscription?.cancel();
    modelService.dispose();
    return super.close();
  }
}
