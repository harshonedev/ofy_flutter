import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/core/usecases/usecase.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/repository/download_repository.dart';

class ResumeDownload implements UseCase<String, String> {
  final DownloadRepository downloadRepository;

  ResumeDownload(this.downloadRepository);

  @override
  Future<Either<Failure, String>> call(String taskId) async {
    return await downloadRepository.resumeDownload(taskId);
  }
}