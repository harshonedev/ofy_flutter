import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class ClearChatHistory implements UseCase<bool, NoParams> {
  final ChatRepository repository;

  ClearChatHistory(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.clearChatHistory();
  }
}
