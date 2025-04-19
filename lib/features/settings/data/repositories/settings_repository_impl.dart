import 'package:dartz/dartz.dart';

import '../../../../core/constants/model_type.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, ModelType>> getModelTypePreference() async {
    try {
      final modelType = await localDataSource.getModelTypePreference();
      return Right(modelType);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> saveModelTypePreference(
    ModelType modelType,
  ) async {
    try {
      final result = await localDataSource.saveModelTypePreference(modelType);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String?>> getApiKey(ModelType modelType) async {
    try {
      final apiKey = await localDataSource.getApiKey(modelType);
      return Right(apiKey);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> saveApiKey(
    String apiKey,
    ModelType modelType,
  ) async {
    try {
      final result = await localDataSource.saveApiKey(apiKey, modelType);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String?>> getModelName(ModelType modelType) async {
    try {
      final modelName = await localDataSource.getModelName(modelType);
      return Right(modelName);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> saveModelName(
    String modelName,
    ModelType modelType,
  ) async {
    try {
      final result = await localDataSource.saveModelName(modelName, modelType);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
