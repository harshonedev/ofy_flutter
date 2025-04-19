import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/model_type.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

class GetModelName implements UseCase<String?, GetModelNameParams> {
  final SettingsRepository repository;

  GetModelName(this.repository);

  @override
  Future<Either<Failure, String?>> call(GetModelNameParams params) async {
    return await repository.getModelName(params.modelType);
  }
}

class GetModelNameParams extends Equatable {
  final ModelType modelType;

  const GetModelNameParams({required this.modelType});

  @override
  List<Object> get props => [modelType];
}
