import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/core/usecases/usecase.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/repository/download_repository.dart';

class GetGGUFModels implements UseCase<List<Model>, NoParams> {
  final DownloadRepository repository;

  GetGGUFModels(this.repository);

  @override
  Future<Either<Failure, List<Model>>> call(NoParams params) async {
    return await repository.getGGUFModels();
  }
}
