import 'package:equatable/equatable.dart';

class Model extends Equatable {
  final String id;
  final String pipeline;
  final String? author;
  final List<String>? files;

  const Model({
    required this.id,
    required this.pipeline,
    this.author,
    this.files,
  });

  @override
  List<Object?> get props => [
        id,
        pipeline,
        author,
        files,
      ];
}