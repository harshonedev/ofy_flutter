import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/model_picker_repository.dart';

class GetModelPath implements UseCase<String?, NoParams> {
  final ModelPickerRepository repository;

  GetModelPath(this.repository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    return await repository.getModelPath();
  }
}
