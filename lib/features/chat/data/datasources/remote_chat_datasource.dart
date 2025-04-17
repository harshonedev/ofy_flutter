import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/model_type.dart';
import '../../../../core/error/exceptions.dart';
import '../models/message_model.dart';
import '../../domain/entities/message.dart';

abstract class RemoteChatDataSource {
  /// Calls the API endpoint to get a response for a user message
  ///
  /// Throws a [ServerException] for all error codes
  Future<MessageModel> getAIResponse(
    String userMessage, {
    ModelType modelType = ModelType.openAi,
    String? apiKey,
    String? modelPath,
  });
}

class RemoteChatDataSourceImpl implements RemoteChatDataSource {
  final http.Client client;

  RemoteChatDataSourceImpl({http.Client? client})
    : client = client ?? http.Client();

  @override
  Future<MessageModel> getAIResponse(
    String userMessage, {
    ModelType modelType = ModelType.openAi,
    String? apiKey,
    String? modelPath,
  }) async {
    if (modelType == ModelType.openAi) {
      if (apiKey == null || apiKey.isEmpty) {
        throw ServerException(message: 'API key is required for OpenAI');
      }
      return _getOpenAIResponse(userMessage, apiKey);
    } else if (modelType == ModelType.local) {
      if (modelPath == null || modelPath.isEmpty) {
        throw ModelLoadException(
          message: 'Model path is required for local inference',
        );
      }
      return _getLocalModelResponse(userMessage, modelPath);
    } else {
      throw ServerException(message: 'Unsupported model type');
    }
  }

  Future<MessageModel> _getOpenAIResponse(
    String userMessage,
    String apiKey,
  ) async {
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': userMessage},
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final content = jsonResponse['choices'][0]['message']['content'];

      return MessageModel(content: content, role: MessageRole.assistant);
    } else {
      throw ServerException(
        message: 'Error ${response.statusCode}: ${response.body}',
      );
    }
  }

  Future<MessageModel> _getLocalModelResponse(
    String userMessage,
    String modelPath,
  ) async {
    // This would be implemented using lcpp package for local model inference
    // For now, we'll return a placeholder response
    try {
      // Simulating a delay for model inference
      await Future.delayed(const Duration(seconds: 1));

      return MessageModel(
        content:
            'This is a placeholder for local model response. Implement actual LCPP inference here.',
        role: MessageRole.assistant,
      );
    } catch (e) {
      throw ModelLoadException(
        message: 'Failed to get response from local model: ${e.toString()}',
      );
    }
  }
}
