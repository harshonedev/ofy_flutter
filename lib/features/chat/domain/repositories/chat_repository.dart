import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/constants/model_type.dart';

import '../../../../core/error/failures.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Message>>> getChatHistory();
  Future<Either<Failure, Message>> sendMessage(
    String content,
    MessageRole role,
    String modelName,
    String apiKey,  
    ModelType modelType,
  );
  Future<Either<Failure, bool>> clearChatHistory();
  Future<Either<Failure, bool>> updateChatHistory(Message message); 
  
}
