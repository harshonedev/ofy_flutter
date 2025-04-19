import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/model_type.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

class SaveModelName implements UseCase<bool, SaveModelNameParams> {
  final SettingsRepository repository;

  SaveModelName(this.repository);

  @override
  Future<Either<Failure, bool>> call(SaveModelNameParams params) async {
    return await repository.saveModelName(params.modelName, params.modelType);
  }
}

class SaveModelNameParams extends Equatable {
  final String modelName;
  final ModelType modelType;

  const SaveModelNameParams({required this.modelName, required this.modelType});

  @override
  List<Object> get props => [modelName, modelType];
}
