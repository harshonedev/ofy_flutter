import 'package:equatable/equatable.dart';

class Model extends Equatable {
  final String id;
  final String? pipeline;

  const Model({
    required this.id,
    required this.pipeline
  });

  @override
  List<Object?> get props => [
        id,
        pipeline,
      ];
}