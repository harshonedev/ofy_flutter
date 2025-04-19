import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/model_type.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

class GetApiKey implements UseCase<String?, GetApiKeyParams> {
  final SettingsRepository repository;

  GetApiKey(this.repository);

  @override
  Future<Either<Failure, String?>> call(GetApiKeyParams params) async {
    return await repository.getApiKey(params.modelType);
  }
}

class GetApiKeyParams extends Equatable {
  final ModelType modelType;

  const GetApiKeyParams({required this.modelType});

  @override
  List<Object> get props => [modelType];
}
