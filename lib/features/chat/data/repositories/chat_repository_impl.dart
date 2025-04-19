import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/constants/model_type.dart';
import 'package:llm_cpp_chat_app/features/chat/domain/services/local_model_service_interface.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/local_chat_datasource.dart';
import '../datasources/remote_chat_datasource.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final LocalChatDataSource localDataSource;
  final RemoteChatDataSource remoteDataSource;
  final LocalModelServiceInterface localModelService;

  ChatRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.localModelService,
  });

  @override
  Future<Either<Failure, List<Message>>> getChatHistory() async {
    try {
      final localMessages = await localDataSource.getCachedMessages();
      return Right(localMessages);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage(
    String content,
    MessageRole role,
    String modelName,
    String apiKey,
    ModelType modelType,
  ) async {
    try {
      // First, cache the user message
      final userMessage = MessageModel(content: content, role: role);

      // Get existing messages
      final existingMessages = await localDataSource.getCachedMessages();
      final updatedMessages = List<MessageModel>.from(existingMessages)
        ..add(userMessage);

      await localDataSource.cacheMessages(updatedMessages);

      try {
        // Get AI response
        final userMessagesForApi =
            updatedMessages.map((message) => message.toApiMessageParams()).toList();
        MessageModel response;
        if (modelType == ModelType.ai4Chat) {
          response = await remoteDataSource.getAi4ChatResponse(
            userMessagesForApi,
            apiKey,
            modelName,
          );
        } else if (modelType == ModelType.claude) {
          response = await remoteDataSource.getClaudeResponse(
            userMessagesForApi,
            apiKey,
            modelName,
          );
        } else if (modelType == ModelType.openAi) {
          response = await remoteDataSource.getOpenAIResponse(
            userMessagesForApi,
            apiKey,
            modelName,
          );
        } else {
          return Left(
            ModelResponseFailure('Unsupported model type: $modelType'),
          );
        }

        // Add AI response to chat history and cache
        final finalMessages = List<MessageModel>.from(updatedMessages)
          ..add(response);
        await localDataSource.cacheMessages(finalMessages);

        // Return the AI response
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on ModelLoadException catch (e) {
        return Left(ModelLoadFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> clearChatHistory() async {
    try {
      final result = await localDataSource.clearCache();
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> updateChatHistory(Message message) async {
    try {
      // Get existing messages
      final messageModel = MessageModel(
        content: message.content,
        role: message.role,
      );
      final existingMessages = await localDataSource.getCachedMessages();
      final updatedMessages = List<MessageModel>.from(existingMessages)
        ..add(messageModel);

      // Cache the updated list with the new user message
      final result = await localDataSource.cacheMessages(updatedMessages);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
