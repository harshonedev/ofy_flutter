import 'package:dartz/dartz.dart';
import 'package:llm_cpp_chat_app/core/error/failures.dart';
import 'package:llm_cpp_chat_app/features/download_manager/data/datasources/hugging_face_api.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/entities/model.dart';
import 'package:llm_cpp_chat_app/features/download_manager/domain/repository/download_repository.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  final HuggingFaceApi huggingFaceApi;
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
      return Right(models);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Model>> getModelDetails(String modelId) {
    // TODO: implement getModelDetails
    throw UnimplementedError();
  }
}
