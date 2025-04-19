import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/model_picker_repository.dart';
import '../datasources/model_picker_local_datasource.dart';

class ModelPickerRepositoryImpl implements ModelPickerRepository {
  final ModelPickerLocalDataSource localDataSource;

  ModelPickerRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, String?>> getModelPath() async {
    try {
      final modelPath = await localDataSource.getModelPath();
      return Right(modelPath);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> saveModelPath(String modelPath) async {
    try {
      final result = await localDataSource.saveModelPath(modelPath);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
