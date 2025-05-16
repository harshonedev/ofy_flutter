import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/file_size_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/repository/download_repository.dart';

class GetFileSizeUseCase {
  final DownloadRepository repository;
  GetFileSizeUseCase(this.repository);

  Stream<Either<Failure, FileSizeDetails>> call(List<FileDetails> files) {
    return repository.getFileSize(files);
  }
  
}