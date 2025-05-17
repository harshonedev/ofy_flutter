import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/file_size_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';

abstract class DownloadRepository {
  Future<Either<Failure, List<Model>>> getGGUFModels();
  Future<Either<Failure, ModelDetails>> getModelDetails(String modelId);
  Future<String?> downloadModel(String fileUrl, String fileName);
  Future<void> cancelDownload(String taskId);
  Future<void> pauseDownload(String taskId);
  Future<String?> resumeDownload(String taskId);
  Stream<Either<Failure, FileSizeDetails>> getFileSize(List<FileDetails> files);
}
