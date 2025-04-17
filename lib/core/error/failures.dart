import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final List<dynamic> properties;

  const Failure([this.properties = const <dynamic>[]]);

  @override
  List<dynamic> get props => properties;
}

// General failures
class ServerFailure extends Failure {
  final String message;

  const ServerFailure({this.message = 'Server Failure'});

  @override
  List<dynamic> get props => [message];
}

class CacheFailure extends Failure {
  final String message;

  const CacheFailure({this.message = 'Cache Failure'});

  @override
  List<dynamic> get props => [message];
}

// Feature specific failures
class ModelLoadFailure extends Failure {
  final String message;

  const ModelLoadFailure({this.message = 'Failed to load model'});

  @override
  List<dynamic> get props => [message];
}

class NoConnectionFailure extends Failure {
  const NoConnectionFailure();

  @override
  List<dynamic> get props => ['No Internet Connection'];
}
