import 'package:dartz/dartz.dart';

import '../../../../core/constants/model_type.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

class GetModelTypePreference implements UseCase<ModelType, NoParams> {
  final SettingsRepository repository;

  GetModelTypePreference(this.repository);

  @override
  Future<Either<Failure, ModelType>> call(NoParams params) async {
    return await repository.getModelTypePreference();
  }
}
