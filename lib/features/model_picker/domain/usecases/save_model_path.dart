import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/model_picker_repository.dart';

class SaveModelPath implements UseCase<bool, SaveModelPathParams> {
  final ModelPickerRepository repository;

  SaveModelPath(this.repository);

  @override
  Future<Either<Failure, bool>> call(SaveModelPathParams params) async {
    return await repository.saveModelPath(params.modelPath);
  }
}

class SaveModelPathParams extends Equatable {
  final String modelPath;

  const SaveModelPathParams({required this.modelPath});

  @override
  List<Object> get props => [modelPath];
}
