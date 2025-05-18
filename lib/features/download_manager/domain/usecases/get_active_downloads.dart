import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/core/usecases/usecase.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/download_model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/repository/download_repository.dart';

class GetActiveDownloads implements UseCase<List<DownloadModel>, NoParams> {
  final DownloadRepository downloadRepository;
  GetActiveDownloads(this.downloadRepository);
  @override
  Future<Either<Failure, List<DownloadModel>>> call(NoParams params) {
    return downloadRepository.getActiveDownloads();
  }

}