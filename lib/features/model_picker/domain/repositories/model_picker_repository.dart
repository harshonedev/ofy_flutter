import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class ModelPickerRepository {
  Future<Either<Failure, String?>> getModelPath();
  Future<Either<Failure, bool>> saveModelPath(String modelPath);
}
