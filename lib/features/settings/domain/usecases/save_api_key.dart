import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/model_type.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

class SaveApiKey implements UseCase<bool, SaveApiKeyParams> {
  final SettingsRepository repository;

  SaveApiKey(this.repository);

  @override
  Future<Either<Failure, bool>> call(SaveApiKeyParams params) async {
    return await repository.saveApiKey(params.apiKey, params.modelType);
  }
}

class SaveApiKeyParams extends Equatable {
  final String apiKey;
  final ModelType modelType;

  const SaveApiKeyParams({required this.apiKey, required this.modelType});

  @override
  List<Object> get props => [apiKey, modelType];
}
