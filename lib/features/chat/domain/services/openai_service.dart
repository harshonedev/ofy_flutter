// filepath: /home/harsh/FlutterProjects/llm_cpp_chat_app-1/lib/features/chat/domain/services/openai_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../entities/message.dart' as app;

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  String? _apiKey;
  String _selectedModel = 'gpt-3.5-turbo';
  final StreamController<String> _responseController =
      StreamController<String>.broadcast();
  bool _isReceivingResponse = false;

  // Completion marker to signal end of response
  static const String completionMaker = "<<DONE>>";

  Stream<String> get responseStream => _responseController.stream;
  bool get isReceivingResponse => _isReceivingResponse;

  // Initialize with API key and model name
  void initialize(String apiKey, String model) {
    _apiKey = apiKey;
    _selectedModel = model;
  }

  bool get isInitialized => _apiKey != null && _apiKey!.isNotEmpty;

  Future<void> sendPrompt(String prompt, List<app.Message> history) async {
    if (!isInitialized) {
      _responseController.addError('OpenAI API key not set');
      return;
    }

    try {
      _isReceivingResponse = true;

      // Prepare conversation history for OpenAI format
      final messages = _prepareMessages(history, prompt);

      // Send request to OpenAI API
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _selectedModel,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 800,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        // Simulate streaming for consistent UX with local model
        await _simulateStreamResponse(content);
      } else {
        final error =
            jsonDecode(response.body)['error']['message'] ?? 'Unknown error';
        _responseController.addError('OpenAI API Error: $error');
      }
    } catch (e) {
      debugPrint('Error communicating with OpenAI: $e');
      _responseController.addError('Error communicating with OpenAI: $e');
    } finally {
      _isReceivingResponse = false;
      _responseController.add(completionMaker);
    }
  }

  // Helper method to convert app messages to OpenAI format
  List<Map<String, String>> _prepareMessages(
    List<app.Message> history,
    String currentPrompt,
  ) {
    final messages = <Map<String, String>>[];

    // Add system message if not already in history
    bool hasSystemMessage = false;

    for (var message in history) {
      if (message.role == app.MessageRole.system) {
        hasSystemMessage = true;
      }

      String role;
      switch (message.role) {
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

      messages.add({'role': role, 'content': message.content});
    }

    // Add system message if none exists
    if (!hasSystemMessage) {
      messages.insert(0, {
        'role': 'system',
        'content': 'You are a helpful assistant.',
      });
    }

    // Add the current user prompt
    messages.add({'role': 'user', 'content': currentPrompt});

    return messages;
  }

  // Simulate streaming for consistent UX with local model
  Future<void> _simulateStreamResponse(String content) async {
    // Split content into chunks to simulate streaming
    final chunks = _splitIntoChunks(content, 10);

    for (var chunk in chunks) {
      _responseController.add(chunk);
      // Add a small delay to simulate streaming
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  // Helper method to split text into chunks
  List<String> _splitIntoChunks(String text, int avgChunkSize) {
    final result = <String>[];
    var remaining = text;

    while (remaining.isNotEmpty) {
      // Vary chunk size slightly for more natural effect
      final variance = (avgChunkSize * 0.5).toInt();
      final min = avgChunkSize - variance;
      final max = avgChunkSize + variance;

      final chunkSize =
          min + (DateTime.now().millisecondsSinceEpoch % (max - min));
      final chunk =
          remaining.length <= chunkSize
              ? remaining
              : remaining.substring(0, chunkSize);

      result.add(chunk);
      remaining =
          remaining.length <= chunkSize ? '' : remaining.substring(chunkSize);
    }

    return result;
  }

  void dispose() {
    if (!_responseController.isClosed) {
      _responseController.close();
    }
  }
}
