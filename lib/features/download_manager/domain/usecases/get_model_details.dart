import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/core/usecases/usecase.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/repository/download_repository.dart';

class GetModelDetails implements UseCase<ModelDetails, Params> {
  final DownloadRepository repository;

  GetModelDetails(this.repository);

  @override
  Future<Either<Failure, ModelDetails>> call(Params params) async {
    return await repository.getModelDetails(params.modelId);
  }
}

class Params extends Equatable {
  final String modelId;

  const Params({required this.modelId});

  @override
  List<Object> get props => [modelId];
}
