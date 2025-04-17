import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Message>>> getChatHistory();
  Future<Either<Failure, Message>> sendMessage(
    String content,
    MessageRole role, {
    String? modelPath,
  });
  Future<Either<Failure, bool>> clearChatHistory();
}
