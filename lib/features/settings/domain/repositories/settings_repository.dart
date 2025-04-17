import 'package:dartz/dartz.dart';

import '../../../../core/constants/model_type.dart';
import '../../../../core/error/failures.dart';

abstract class SettingsRepository {
  Future<Either<Failure, ModelType>> getModelTypePreference();
  Future<Either<Failure, bool>> saveModelTypePreference(ModelType modelType);
  Future<Either<Failure, String?>> getApiKey();
  Future<Either<Failure, bool>> saveApiKey(String apiKey);
}
