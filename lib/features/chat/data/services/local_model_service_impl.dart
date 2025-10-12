import 'dart:async';
import 'package:llama_sdk/llama_sdk.dart'
    if (dart.library.html) 'package:llama_sdk/llama_sdk.web.dart';
import 'dart:math' as math;
import 'package:logger/logger.dart';

import '../../domain/entities/message.dart';
import '../../domain/services/local_model_service_interface.dart';

class LocalModelServiceImpl implements LocalModelServiceInterface {
  static final Logger _logger = Logger();

  Llama? _llama;
  StreamController<String>? _responseController;
  bool _isModelLoaded = false;
  StreamSubscription? _currentStreamSubscription;
  String _lastResponse = '';

  // Store conversation history
  final List<LlamaMessage> _conversationHistory = [];

  // Completion marker to signal end of response
  static const String completionMarker = "<<DONE>>";

  @override
  Stream<String> get responseStream {
    _responseController ??= StreamController<String>.broadcast();
    return _responseController!.stream;
  }

  @override
  bool get isModelLoaded => _isModelLoaded;

  @override
  Future<bool> loadModel(String modelPath) async {
    try {
      // Reset state if needed
      await cancelCurrentRequest();

      // Create a new stream controller if needed
      if (_responseController == null || _responseController!.isClosed) {
        _responseController = StreamController<String>.broadcast();
      }

      // Increase context size and adjust parameters
      _llama = Llama(
        LlamaController(
          modelPath: modelPath,
          nCtx: 2048,
          nBatch: 2048,
          seed: math.Random().nextInt(1000000),
          greedy: false,
        ),
      );

      _isModelLoaded = true;
      // Clear conversation history when loading new model
      _conversationHistory.clear();
      _lastResponse = '';
      _logger.i("Model Loaded Successfully");
      return true;
    } catch (e) {
      _logger.e('Error loading model: $e');
      _isModelLoaded = false;
      return false;
    }
  }

  @override
  Future<void> cancelCurrentRequest() async {
    await _currentStreamSubscription?.cancel();
    _currentStreamSubscription = null;
  }

  @override
  Future<void> sendPrompt(String prompt) async {
    if (!_isModelLoaded || _llama == null) {
      _responseController?.addError('Model not loaded');
      return;
    }

    try {
      await cancelCurrentRequest();
      _lastResponse = '';

      // Create a new stream controller if needed
      if (_responseController == null || _responseController!.isClosed) {
        _responseController = StreamController<String>.broadcast();
      }

      // Add system message if needed
      if (_conversationHistory.isEmpty) {
        _conversationHistory.add(
          LlamaMessage.withRole(
            role: 'system',
            content: 'You are a helpful assistant.',
          ),
        );
      }

      final userMessage = LlamaMessage.withRole(role: 'user', content: prompt);
      _conversationHistory.add(userMessage);

      // Keep conversation history manageable
      if (_conversationHistory.length > 10) {
        _conversationHistory.removeRange(0, _conversationHistory.length - 10);
      }

      _logger.d('Sending prompt with ${_conversationHistory.length} messages');

      final stream = _llama!.prompt(_conversationHistory);

      _currentStreamSubscription = stream.listen(
        (response) {
          _lastResponse += response;
          _responseController?.add(response);
        },
        onError: (error) {
          _logger.e('Error during inference: $error');
          _responseController?.addError('Error during inference: $error');
        },
        onDone: () {
          _logger.d('Inference completed with response: $_lastResponse');

          // Add assistant's response to history
          if (_lastResponse.isNotEmpty) {
            _conversationHistory.add(
              LlamaMessage.withRole(role: 'assistant', content: _lastResponse),
            );
          }
          _currentStreamSubscription = null;

          // Signal completion with marker instead of closing the stream
          _responseController?.add(completionMarker);
        },
      );
    } catch (e) {
      _logger.e('Error sending prompt: $e');
      _responseController?.addError('Error sending prompt: $e');
    }
  }

  @override
  String buildPrompt(List<Message> messages) {
    // With lcpp we just return the last user message
    // since we handle the conversation in the messages list
    for (final message in messages.reversed) {
      if (message.role == MessageRole.user) {
        return message.content;
      }
    }
    return '';
  }

  List<LlamaMessage> convertAppMessages(List<Message> appMessages) {
    return appMessages.map((msg) {
      String role;
      switch (msg.role) {
        case MessageRole.user:
          role = 'user';
          break;
        case MessageRole.assistant:
          role = 'assistant';
          break;
        case MessageRole.system:
          role = 'system';
          break;
      }
      return LlamaMessage.withRole(role: role, content: msg.content);
    }).toList();
  }

  @override
  void dispose() {
    cancelCurrentRequest();
    _llama?.stop();
    _llama?.reload();
    _conversationHistory.clear();
    _lastResponse = '';

    // Close the stream controller only when disposing the service
    if (_responseController != null && !_responseController!.isClosed) {
      _responseController!.close();
      _responseController = null;
    }
  }
}
