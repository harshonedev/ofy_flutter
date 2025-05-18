import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/core/usecases/usecase.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/repository/download_repository.dart';

class RemoveModel extends UseCase<void, String> {
  final DownloadRepository repository;
  RemoveModel(this.repository);
  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteDownload(params);
  }
}
