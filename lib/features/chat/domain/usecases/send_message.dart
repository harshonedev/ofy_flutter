import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:llm_cpp_chat_app/core/constants/model_type.dart';

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
      params.modelName,
      params. apiKey,
      params.modelType,

    );
  }
}

class SendMessageParams extends Equatable {
  final String content;
  final MessageRole role;
  final String modelName;
  final ModelType modelType;
  final String apiKey;

  const SendMessageParams({
    required this.content,
    this.role = MessageRole.user,
    required this.modelName,
    required this.apiKey,
    required this.modelType,
  });

  @override
  List<Object?> get props => [content, role, modelName];
}
