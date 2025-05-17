import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/core/usecases/usecase.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/repository/download_repository.dart';

class DownloadModel implements UseCase<void, Params> {
  final DownloadRepository repository;

  DownloadModel(this.repository);

  @override
  Future<Either<Failure, String?>> call(Params params) async {
    try {
      final taskId = await repository.downloadModel(params.modelFileUrl, params.modelFileName);
      return Right(taskId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class Params extends Equatable {
  final String modelFileUrl;
  final String modelFileName;

  const Params({required this.modelFileName, required this.modelFileUrl});

  @override
  List<Object> get props => [modelFileName];
}
