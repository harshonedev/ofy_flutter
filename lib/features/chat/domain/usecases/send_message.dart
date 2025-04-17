import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessage implements UseCase<Message, SendMessageParams> {
  final ChatRepository repository;

  SendMessage(this.repository);

  @override
  Future<Either<Failure, Message>> call(SendMessageParams params) async {
    return await repository.sendMessage(
      params.content,
      params.role,
      modelPath: params.modelPath,
    );
  }
}

class SendMessageParams extends Equatable {
  final String content;
  final MessageRole role;
  final String? modelPath;

  const SendMessageParams({
    required this.content,
    this.role = MessageRole.user,
    this.modelPath,
  });

  @override
  List<Object?> get props => [content, role, modelPath];
}
