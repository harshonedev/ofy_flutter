import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/core/usecases/usecase.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/repository/download_repository.dart';

class PauseDownload implements UseCase<void, String> {
  final DownloadRepository downloadRepository;

  PauseDownload(this.downloadRepository);

  @override
  Future<Either<Failure, void>> call(String taskId) async {
    return await downloadRepository.pauseDownload(taskId);
  }
}