import 'package:equatable/equatable.dart';

class ModelDetails extends Equatable {
  final String id;
  final String? pipeline;
  final String? author;
  final List<String>? files;

  const ModelDetails({
    required this.id,
    required this.pipeline,
    required this.author,
    this.files,
  });

  @override
  List<Object?> get props => [id, pipeline, author, files];
}
