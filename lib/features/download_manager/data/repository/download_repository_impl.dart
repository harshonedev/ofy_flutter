import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/error/exceptions.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/features/download_manager/data/datasources/hugging_face_api.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model_details.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/repository/download_repository.dart';
import 'package:logger/web.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  final HuggingFaceApi huggingFaceApi;
  final Logger logger = Logger();
  DownloadRepositoryImpl({required this.huggingFaceApi});
  @override
  Future<void> cancelDownload() {
    throw UnimplementedError();
  }

  @override
  Future<void> downloadModel(String modelFileName) {
    throw UnimplementedError();
  }

  @override
  Stream<int> getDownloadProgress() {
    throw UnimplementedError();
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
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
