import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:lcpp/lcpp.dart';
import '../entities/message.dart' as app;
import 'dart:math' as math;

class ModelService {
  Llama? _llama;
  final _responseController = StreamController<String>.broadcast();
  bool _isModelLoaded = false;
  StreamSubscription? _currentStreamSubscription;

  Stream<String> get responseStream => _responseController.stream;
  bool get isModelLoaded => _isModelLoaded;

  Future<bool> loadModel(String modelPath) async {
    try {
      // Create a new Llama instance with the model file
      _llama = Llama(
        LlamaController(
          modelPath: modelPath,
          nCtx: 2048,
          nBatch: 512,
          seed: math.Random().nextInt(1000000),
          greedy: false, // Use sampling instead of greedy decoding
        ),
      );

      _isModelLoaded = true;
      return true;
    } catch (e) {
      debugPrint('Error loading model: $e');
      _isModelLoaded = false;
      return false;
    }
  }

  Future<void> cancelCurrentRequest() async {
    await _currentStreamSubscription?.cancel();
    _currentStreamSubscription = null;
  }

  Future<void> sendPrompt(String prompt) async {
    if (!_isModelLoaded || _llama == null) {
      _responseController.addError('Model not loaded');
      return;
    }

    try {
      // Cancel any running request
      await cancelCurrentRequest();

      // Create chat messages
      final messages = [
        ChatMessage.withRole(
          role: 'system',
          content: 'You are a helpful assistant.',
        ),
        ChatMessage.withRole(role: 'user', content: prompt),
      ];

      // Start inference
      debugPrint('Sending prompt: $prompt');
      final stream = _llama!.prompt(messages);

      // Listen to the stream and forward responses to the controller
      _currentStreamSubscription = stream.listen(
        (response) {
          _responseController.add(response);
        },
        onError: (error) {
          debugPrint('Error during inference: $error');
          _responseController.addError('Error during inference: $error');
        },
        onDone: () {
          debugPrint('Inference completed');
          _currentStreamSubscription = null;
        },
      );
    } catch (e) {
      debugPrint('Error sending prompt: $e');
      _responseController.addError('Error sending prompt: $e');
    }
  }

  String buildPrompt(List<app.Message> messages) {
    // With lcpp we just return the last user message
    // since we handle the conversation in the messages list
    for (final message in messages.reversed) {
      if (message.role == app.MessageRole.user) {
        return message.content;
      }
    }
    return '';
  }

  List<ChatMessage> convertAppMessages(List<app.Message> appMessages) {
    return appMessages.map((msg) {
      String role;
      switch (msg.role) {
        case app.MessageRole.user:
          role = 'user';
          break;
        case app.MessageRole.assistant:
          role = 'assistant';
          break;
        case app.MessageRole.system:
          role = 'system';
          break;
      }
      return ChatMessage.withRole(role: role, content: msg.content);
    }).toList();
  }

  void dispose() {
    cancelCurrentRequest();
    _llama?.stop();
    _llama?.reload();
    _responseController.close();
  }
}
