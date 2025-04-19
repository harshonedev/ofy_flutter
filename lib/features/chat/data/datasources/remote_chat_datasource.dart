import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:llm_cpp_chat_app/core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/message_model.dart';
import '../../domain/entities/message.dart';

abstract class RemoteChatDataSource {
  /// Calls the API endpoint to get a response for a user message
  ///
  /// Throws a [ServerException] for all error codes
  Future<MessageModel> getOpenAIResponse(
    List<ApiMessageParams> userMessages,
    String apiKey,
    String modelName,
  );

  Future<MessageModel> getAi4ChatResponse(
    List<ApiMessageParams> userMessages,
    String apiKey,
    String modelName,
  );

  Future<MessageModel> getClaudeResponse(
    List<ApiMessageParams> userMessages,
    String apiKey,
    String modelName,
  );
}

class RemoteChatDataSourceImpl implements RemoteChatDataSource {
  final http.Client client;

  RemoteChatDataSourceImpl({required this.client});

  @override
  Future<MessageModel> getAi4ChatResponse(
    List<ApiMessageParams> userMessages,
    String apiKey,
    String modelName,
  ) async {
    try {
      final uri = Uri.parse(AppConstants.ai4ChatBaseUrl);
      print(
        'userMessage: ${json.encode({'model': modelName, 'messages': userMessages})}',
      );
      final response = await client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: json.encode({'model': modelName, 'messages': userMessages}),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'] ?? '';
        return MessageModel(content: content, role: MessageRole.assistant);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw ServerException(
          message: 'Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error: $e');
    }
  }

  @override
  Future<MessageModel> getClaudeResponse(
    List<ApiMessageParams> userMessages,
    String apiKey,
    String modelName,
  ) async {
    try {
      final uri = Uri.parse(AppConstants.claudeaiBaseUrl);
      final response = await client.post(
        uri,
        headers: {
          'x-api-key': apiKey,
          'content-type': 'application/json',
          'anthropic-version': '2023-06-01',
        },
        body: json.encode({
          'model': modelName,
          'max-tokens': 1024,
          'messages': userMessages,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final content = jsonResponse['content'][0]['text'] ?? '';
        return MessageModel(content: content, role: MessageRole.assistant);
      } else {
        throw ServerException(
          message: 'Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error: $e');
    }
  }

  @override
  Future<MessageModel> getOpenAIResponse(
    List<ApiMessageParams> userMessages,
    String apiKey,
    String modelName,
  ) async {
    try {
      final uri = Uri.parse(AppConstants.openAiBaseUrl);
      final response = await client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({'model': modelName, 'messages': userMessages}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'] ?? '';
        return MessageModel(content: content, role: MessageRole.assistant);
      } else {
        throw ServerException(
          message: 'Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error: $e');
    }
  }
}

class ApiMessageParams{
  final String content;
  final String role;

  ApiMessageParams({
    required this.content,
    required this.role,
  });
}
