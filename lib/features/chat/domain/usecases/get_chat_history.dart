import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetChatHistory implements UseCase<List<Message>, NoParams> {
  final ChatRepository repository;

  GetChatHistory(this.repository);

  @override
  Future<Either<Failure, List<Message>>> call(NoParams params) async {
    return await repository.getChatHistory();
  }
}
