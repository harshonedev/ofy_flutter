import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message); 

  @override
  List<dynamic> get props => [message];
}

// General failures
class ServerFailure extends Failure {
 
  const ServerFailure(super.message);

}

class DownloadFailure extends Failure {
  const DownloadFailure(super.message);
}

class ModelResponseFailure extends Failure {
  const ModelResponseFailure(super.message);
}

class CacheFailure extends Failure {

  const CacheFailure(super.message);

}

class UnknownFailure extends Failure {

  const UnknownFailure(super.message);

}

// Feature specific failures
class ModelLoadFailure extends Failure {

  const ModelLoadFailure(super.message);
}

class NoConnectionFailure extends Failure {
  const NoConnectionFailure(super.message);

}
