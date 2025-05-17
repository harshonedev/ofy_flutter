import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/error/exceptions.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/features/download_manager/data/datasources/download_service.dart';
import 'package:llm_cpp_chat_app/features/download_manager/data/datasources/hugging_face_api.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/file_size_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/repository/download_repository.dart';
import 'package:logger/web.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  final HuggingFaceApi huggingFaceApi;
  final DownloadService downloadService;
  final Logger logger = Logger();

  DownloadRepositoryImpl({required this.huggingFaceApi, required this.downloadService});
  @override
  Future<void> cancelDownload(String taskId) async {
    try {
      await downloadService.cancelDownload(taskId);
      logger.i('Download cancelled');
    } catch (e) {
      logger.e('Error cancelling download: $e');
      throw Exception('Failed to cancel download');
    }
  }

  @override
  Future<String?> downloadModel(String fileUrl, String fileName) async{
    try {
      return await downloadService.downloadFile(
        fileUrl,
        fileName,
      );
    } catch (e) {
      logger.e('Error downloading model: $e');
      throw Exception('Failed to download model');
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
  Stream<Either<Failure, FileSizeDetails>> getFileSize(List<FileDetails> files) async* {
    try {
      for (var file in files) {
        final fileSize = await huggingFaceApi.getFileSize(file.downloadUrl);
        if (fileSize != null) {
          final formattedSize = _calculateFileSize(fileSize);
          yield Right(FileSizeDetails(
            formattedSize: formattedSize,
            fileIndex: files.indexOf(file)
          ));
        } else {
          yield Right(FileSizeDetails(
            formattedSize: "File size not available",
            fileIndex: files.indexOf(file)
          ));
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
  Future<void> pauseDownload(String taskId) {
    try {
      return downloadService.pauseDownload(taskId);
    } catch (e) {
      logger.e('Error pausing download: $e');
      throw Exception('Failed to pause download');
    }
  }
  
  @override
  Future<String?> resumeDownload(String taskId) {
    try {
      return downloadService.resumeDownload(taskId);
    } catch (e) {
      logger.e('Error resuming download: $e');
      throw Exception('Failed to resume download');
    }
  }
}
