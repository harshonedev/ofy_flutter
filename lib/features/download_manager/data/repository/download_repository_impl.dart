import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart'
    as file_downloader;
import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/error/exceptions.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/core/utils/model_utils.dart';
import 'package:llm_cpp_chat_app/features/download_manager/data/datasources/download_service.dart';
import 'package:llm_cpp_chat_app/features/download_manager/data/datasources/hugging_face_api.dart';
import 'package:llm_cpp_chat_app/features/download_manager/data/models/download_model_data.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/download_model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/file_size_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_file.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/repository/download_repository.dart';
import 'package:logger/web.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  final HuggingFaceApi huggingFaceApi;
  final DownloadService downloadService;
  final Logger logger = Logger();

  DownloadRepositoryImpl({
    required this.huggingFaceApi,
    required this.downloadService,
  });

  @override
  void startFileDownloader() {
    downloadService.startDownloader();
    logger.i('File downloader started');
  }

  @override
  Future<Either<Failure, bool>> cancelDownload(
    file_downloader.Task task,
  ) async {
    try {
      final isCancelled = await downloadService.cancelDownload(task);
      logger.i('Download cancelled');
      return Right(isCancelled);
    } catch (e) {
      logger.e('Error cancelling download: $e');
      return const Left(DownloadFailure('Failed to cancel download'));
    }
  }

  @override
  Future<Either<Failure, DownloadModel>> downloadModel(
    String fileUrl,
    String fileName,
  ) async {
    try {
      // if file already exists
      final records = await downloadService.loadDownlaods();
      final existingRecords = records.where(
        (record) => record.task.filename == fileName,
      );
      if (existingRecords.isNotEmpty) {
        logger.i('File already exists: $fileName');
        return const Left(DownloadFailure('File already exists'));
      }

      final task = await downloadService.downloadFile(fileUrl, fileName);
      if (task != null) {
        logger.i('Download started: ${task.taskId}');
        return Right(DownloadModelData.fromTask(task));
      } else {
        logger.e('Failed to start download');
        return const Left(DownloadFailure('Failed to start download'));
      }
    } catch (e) {
      logger.e('Error downloading model: $e');
      return const Left(DownloadFailure('Failed to download model'));
    }
  }

  @override
  Future<Either<Failure, List<Model>>> getGGUFModels() async {
    try {
      final models = await huggingFaceApi.getGGUFModels();
      if (models.isEmpty) {
        return const Left(ServerFailure("No models found"));
      }
      return Right(models);
    } on ServerException catch (e) {
      logger.e(e.message);
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ModelDetails>> getModelDetails(String modelId) async {
    try {
      final model = await huggingFaceApi.getModelDetails(modelId);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, FileSizeDetails>> getFileSize(
    List<FileDetails> files,
  ) async* {
    try {
      for (var file in files) {
        final fileSize = await huggingFaceApi.getFileSize(file.downloadUrl);
        if (fileSize != null) {
          final formattedSize = ModelUtils.calculateFileSize(fileSize);
          yield Right(
            FileSizeDetails(
              formattedSize: formattedSize,
              fileIndex: files.indexOf(file),
            ),
          );
        } else {
          yield Right(
            FileSizeDetails(
              formattedSize: "File size not available",
              fileIndex: files.indexOf(file),
            ),
          );
        }
      }
    } on ServerException catch (e) {
      logger.e(e.message);
      yield Left(ServerFailure(e.message));
    } catch (e) {
      logger.e(e.toString());
      yield const Left(ServerFailure("Failed to get file size"));
    }
  }

  @override
  Future<Either<Failure, bool>> pauseDownload(file_downloader.Task task) async {
    try {
      final downloadTask = file_downloader.DownloadTask.fromJson(task.toJson());
      final isPaused = await downloadService.pauseDownload(downloadTask);
      return Right(isPaused);
    } catch (e) {
      logger.e('Error pausing download: $e');
      return const Left(DownloadFailure('Failed to pause download'));
    }
  }

  @override
  Future<Either<Failure, bool>> resumeDownload(
    file_downloader.Task task,
  ) async {
    try {
      final downloadTask = file_downloader.DownloadTask.fromJson(task.toJson());
      final isResumed = await downloadService.resumeDownload(downloadTask);
      if (isResumed) {
        logger.i('Download resumed: $isResumed');
        return Right(isResumed);
      } else {
        logger.e('Failed to resume download');
        return const Left(DownloadFailure('Failed to resume download'));
      }
    } catch (e) {
      logger.e('Error resuming download: $e');
      return const Left(DownloadFailure('Failed to resume download'));
    }
  }

  @override
  Future<Either<Failure, List<DownloadModel>>> getActiveDownloads() async {
    try {
      final records = await downloadService.loadDownlaods();
      if (records.isEmpty) {
        return const Right([]);
      }
      final downloadModels =
          records
              .where((record) {
                return record.status == file_downloader.TaskStatus.running ||
                    record.status == file_downloader.TaskStatus.paused ||
                    record.status == file_downloader.TaskStatus.waitingToRetry;
              })
              .map((record) {
                final downloadModelData = DownloadModelData.fromTask(
                  record.task,
                ).copyWith(
                  progress: (record.progress * 100).round(),
                  status: record.status.toString(),
                  expectedFileSize:
                      record.expectedFileSize > 0
                          ? ModelUtils.calculateFileSize(
                            record.expectedFileSize,
                          )
                          : 'Unknown',
                  isPaused: record.status == file_downloader.TaskStatus.paused,
                );
                logger.i(
                  'Active download: ${downloadModelData.task.taskId}, '
                  'Status: ${downloadModelData.status}, '
                  'Progress: ${downloadModelData.progress}%',
                );
                return downloadModelData;
              })
              .toList();
      return Right(downloadModels);
    } catch (e) {
      logger.e('Error getting active downloads: $e');
      return const Left(DownloadFailure('Failed to get active downloads'));
    }
  }

  @override
  Future<Either<Failure, List<ModelFile>>> getAvailableModels() async {
    try {
      final records = await downloadService.loadDownlaods();
      if (records.isEmpty) {
        return const Right([]);
      }
      final downloadedRecords =
          records.where((record) {
            return record.status == file_downloader.TaskStatus.complete;
          }).toList();
      List<ModelFile> modelFiles = [];
      for (var record in downloadedRecords) {
        final filePath = await record.task.filePath(
          withFilename: record.task.filename,
        );
        final file = File(filePath);
        String fileSize = 'Unknown';
        if (file.existsSync()) {
          fileSize = ModelUtils.calculateFileSize(file.lengthSync());
        } else {
          logger.w('File does not exist: $filePath');
        }
        final modelFile = ModelFile(
          taskId: record.taskId,
          fileName: record.task.filename,
          filePath: filePath,
          fileSize: fileSize,
        );
        modelFiles.add(modelFile);
      }
      return Right(modelFiles);
    } catch (e) {
      logger.e('Error getting available models: $e');
      return const Left(DownloadFailure('Failed to get available models'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDownload(
    String taskId,
    String filePath,
  ) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync(); // use delete() for async
      } else {
        logger.w('File does not exist: $filePath');
      }
      await downloadService.deleteDownload(taskId);
      logger.i('Download deleted');
      return const Right(null);
    } catch (e) {
      logger.e('Error deleting download: $e');
      return const Left(DownloadFailure('Failed to delete download'));
    }
  }

  @override
  Stream<DownloadProgress> downloadProgressStream() {
    return downloadService.downloadProgressStream;
  }

  @override
  Stream<DownloadStatus> downloadStatusStream() {
    return downloadService.downloadStatusStream;
  }

  @override
  void dispose() {
    downloadService.dispose();
    logger.i('DownloadRepository disposed');
  }

  @override
  void startListeningToDownloads() {
    downloadService.startListeningToDownloads();
    logger.i('Started listening to download updates');
  }
}
