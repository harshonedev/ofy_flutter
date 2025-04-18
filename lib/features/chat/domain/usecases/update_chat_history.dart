import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/core/usecases/usecase.dart';
import 'package:llm_cpp_chat_app/features/chat/domain/entities/message.dart';
import 'package:llm_cpp_chat_app/features/chat/domain/repositories/chat_repository.dart';

class UpdateChatHistory extends UseCase<bool, Message> {
  final ChatRepository repository;
  UpdateChatHistory(this.repository);
  @override
  Future<Either<Failure, bool>> call(Message param) async {
    return await repository.updateChatHistory(param);
  }
}
