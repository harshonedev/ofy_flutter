import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/core/usecases/usecase.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_file.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/repository/download_repository.dart';

class GetAvailableModels implements UseCase<List<ModelFile>, NoParams> {
  final DownloadRepository repository;
  GetAvailableModels(this.repository);

  @override
  Future<Either<Failure, List<ModelFile>>> call(NoParams params) {
    return repository.getAvailableModels();
  }
}
