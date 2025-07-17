import 'package:dartz/dartz.dart';

import 'package:background_downloader/background_downloader.dart'
    as file_downloader;
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/features/download_manager/data/datasources/download_service.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/download_model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/file_size_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_file.dart';

abstract class DownloadRepository {
  Future<Either<Failure, List<Model>>> getGGUFModels();
  Future<Either<Failure, ModelDetails>> getModelDetails(String modelId);
  Future<Either<Failure, List<DownloadModel>>> getActiveDownloads();
  Future<Either<Failure, List<ModelFile>>> getAvailableModels();
  Future<Either<Failure, DownloadModel>> downloadModel(
    String fileUrl,
    String fileName,
  );
  Future<Either<Failure, bool>> cancelDownload(file_downloader.Task task);
  Future<Either<Failure, bool>> pauseDownload(file_downloader.Task task);
  Future<Either<Failure, bool>> resumeDownload(file_downloader.Task task);
  Future<Either<Failure, void>> deleteDownload(String taskId);
  Stream<Either<Failure, FileSizeDetails>> getFileSize(List<FileDetails> files);
  Stream<DownloadProgress> downloadProgressStream();
  Stream<DownloadStatus> downloadStatusStream();
  void startListeningToDownloads();
  void startFileDownloader();
  void dispose();
}
