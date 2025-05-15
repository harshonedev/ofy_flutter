import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';

abstract class DownloadRepository {
  Future<Either<Failure, List<Model>>> getGGUFModels();
  Future<Either<Failure, ModelDetails>> getModelDetails(String modelId);
  Future<void> downloadModel(String modelFileName);
  Stream<int> getDownloadProgress();
  Future<void> cancelDownload();
}
