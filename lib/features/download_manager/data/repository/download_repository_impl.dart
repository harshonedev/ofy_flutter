import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:llm_cpp_chat_app/core/constants/app_constants.dart';
import 'package:llm_cpp_chat_app/core/error/exceptions.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
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
  Future<Either<Failure, void>> cancelDownload(String taskId) async {
    try {
      await downloadService.cancelDownload(taskId);
      logger.i('Download cancelled');
      return const Right(null);
    } catch (e) {
      logger.e('Error cancelling download: $e');
      return const Left(DownloadFailure('Failed to cancel download'));
    }
  }

  @override
  Future<Either<Failure, String>> downloadModel(
    String fileUrl,
    String fileName,
  ) async {
    try {
      // if file already exists
      final file = File("${AppConstants.defaultDownloadPath}/$fileName");
      if (await file.exists()) {
        logger.i('File already exists: $fileName');
        return const Left(
          DownloadFailure(
            'File already exists in ${AppConstants.defaultDownloadPath}',
          ),
        );
      }
      final taskId = await downloadService.downloadFile(fileUrl, fileName);
      if (taskId != null) {
        logger.i('Download started: $taskId');
        return Right(taskId);
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

  String _calculateFileSize(int sizeInBytes) {
    // Convert bytes to KB, MB, GB, etc.
    if (sizeInBytes >= 1024 * 1024 * 1024) {
      final sizeInGB = sizeInBytes / (1024 * 1024 * 1024);
      logger.d('File size: ${sizeInGB.toStringAsFixed(2)} GB');
      return '${sizeInGB.toStringAsFixed(2)} GB';
    } else if (sizeInBytes >= 1024 * 1024) {
      final sizeInMB = sizeInBytes / (1024 * 1024);
      logger.d('File size: ${sizeInMB.toStringAsFixed(2)} MB');
      return '${sizeInMB.toStringAsFixed(2)} MB';
    } else if (sizeInBytes >= 1024) {
      final sizeInKB = sizeInBytes / 1024;
      logger.d('File size: ${sizeInKB.toStringAsFixed(2)} KB');
      return '${sizeInKB.toStringAsFixed(2)} KB';
    } else {
      logger.d('File size: $sizeInBytes bytes');
      return '$sizeInBytes bytes';
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
          final formattedSize = _calculateFileSize(fileSize);
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
  Future<Either<Failure, void>> pauseDownload(String taskId) async {
    try {
      await downloadService.pauseDownload(taskId);
      return const Right(null);
    } catch (e) {
      logger.e('Error pausing download: $e');
      return const Left(DownloadFailure('Failed to pause download'));
    }
  }

  @override
  Future<Either<Failure, String>> resumeDownload(String taskId) async {
    try {
      final newTaskId = await downloadService.resumeDownload(taskId);
      if (newTaskId != null) {
        logger.i('Download resumed: $newTaskId');
        return Right(newTaskId);
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
      final tasks = await downloadService.loadDownlaods();
      if (tasks == null || tasks.isEmpty) {
        return const Right([]);
      }
      final downloadModels =
          tasks.map((task) {
            return DownloadModelData.fromDownloadTask(task);
          }).toList();
      return Right(downloadModels);
    } catch (e) {
      logger.e('Error getting active downloads: $e');
      return const Left(DownloadFailure('Failed to get active downloads'));
    }
  }

  @override
  Future<Either<Failure, List<ModelFile>>> getAvailableModels() async {
    try {
      final tasks = await downloadService.loadDownlaods();
      if (tasks == null || tasks.isEmpty) {
        return const Right([]);
      }
      final downloadedTasks =
          tasks.where((task) {
            return task.status == DownloadTaskStatus.complete;
          }).toList();
      List<ModelFile> modelFiles = [];
      for (var task in downloadedTasks) {
        final filePath = "${task.savedDir}/${task.filename}";
        final file = File(filePath);
        if (await file.exists()) {
          final fileSize = await file.length();
          final modelFile = ModelFile(
            taskId: task.taskId,
            fileName: task.filename ?? 'Unknown',
            filePath: filePath,
            fileSize: _calculateFileSize(fileSize),
          );
          modelFiles.add(modelFile);
        }
      }
      return Right(modelFiles);
    } catch (e) {
      logger.e('Error getting available models: $e');
      return const Left(DownloadFailure('Failed to get available models'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDownload(String taskId) async {
    try {
      await downloadService.deleteDownload(taskId);
      logger.i('Download deleted');
      return const Right(null);
    } catch (e) {
      logger.e('Error deleting download: $e');
      return const Left(DownloadFailure('Failed to delete download'));
    }
  }
}
