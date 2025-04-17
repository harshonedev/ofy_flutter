import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/model_type.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

class SaveModelTypePreference implements UseCase<bool, SaveModelTypeParams> {
  final SettingsRepository repository;

  SaveModelTypePreference(this.repository);

  @override
  Future<Either<Failure, bool>> call(SaveModelTypeParams params) async {
    return await repository.saveModelTypePreference(params.modelType);
  }
}

class SaveModelTypeParams extends Equatable {
  final ModelType modelType;

  const SaveModelTypeParams({required this.modelType});

  @override
  List<Object> get props => [modelType];
}
